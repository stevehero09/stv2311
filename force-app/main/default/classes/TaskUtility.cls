/**
* Revisions:
* 19-June-2023	- Stephen Manning - CASE#00026431 - Added code to exclude "Change Management" cases from afterUpdate.
* -
* 5th June 2023 - Stephen Manning - Case#00025978 - Allowed non-personal Ops tasks to be completed without a due date, for RECURRING
	tasks only. This code also replaces the Validation Rule VR_TASK_EnforceDueDate.
* -
* 14-Oct-2022	- Stephen Manning - CASE#00023304 - Added handling for "Rogue User" Uncategorised Tasks.
*/ 

public without sharing class TaskUtility{
	//Case#00025978 - Making RTID_Ops static (previously local to beforeInsert )
    public static Id RTID_Ops	= [ SELECT id, DeveloperName FROM RecordType WHERE sObjectType = 'Task' AND DeveloperName = 'Operations' LIMIT 1 ].id;
    
    public static void beforeInsert(List<Task> Tasks){
         if(!system.isBatch()){ // exclude batch invocations - e.g., MonthEndNotification
			system.debug('Entering TaskUtility.beforeInsert.tryBlock');
             try{
          		Id RTID_APSF = [ SELECT id, DeveloperName FROM RecordType WHERE sObjectType = 'Task' AND DeveloperName = 'APSF' LIMIT 1 ].id;
                //Id RTID_Ops = [ SELECT id, DeveloperName FROM RecordType WHERE sObjectType = 'Task' AND DeveloperName = 'Operations' LIMIT 1 ].id;
                String currentUserId = UserInfo.getUserId();
                 
                //Add SF id for each RU to the set RogueUserIds
                Map<String, RogueUsers__mdt> RogueUsersMap = RogueUsers__mdt.getAll(); //<-- Get RUs from CMDT
                Set<String> RUIds = new Set<String>();
                for (String cmdtId : RogueUsersMap.keySet()) { 
                    RUIds.add(RogueUsersMap.get(cmdtId).RUID__c); 
                } 
                system.debug('Size of the set RogueUserIds is: ' +RUIds.size());
                
                for (Task t : Tasks) 
                {
                    // CASE#23304: Auto-assign "APSF" record type to Ops tasks if category is NULL and TaskCreator is ROGUEUSER
                    //system.debug('taskutility.beforeInsert is processing a task: Category : ' +t.Category__c + '; RTID : ' +t.RecordTypeId);
                    if ( t.RecordTypeId == RTID_Ops && t.Category__c == NULL && RUIDs.Contains(currentUserId)) 
                    {
                        t.RecordTypeId = RTID_APSF; 
                        system.debug('A "Rogue User Task" was identified/processed.');
                	} // end if
                    // CASE#00025978: require Due Date for non-personal Ops Tasks, unless they are RECURRING.
                    checkDueDate(t);    
                }//end for
                 system.debug('Exiting TaskUtility.beforeInsert.tryBlock');
            }//end Try
            
            catch (Exception e) { 
                System.debug('There was an ERROR in TaskUtility.BeforeInsert!!: ' + e); 
            } //end catch
        } // end if
    } //end beforeInsert
        
    public static void afterUpdate(List<Task> oldTasks, List<Task> newTasks, Map<id,Task> newTaskMap, Map<id,Task> oldTaskMap)
    {
        Map <Id, recordType>RTID_Map	= 	new Map <id, recordType> (	//holds RTID=>RT for Subcases/PMAs 
                                                [ SELECT id, name, sobjectType 
                                                FROM recordtype 
                                                WHERE (name = 'PMAs' OR name = 'Subcases') 
                                                AND sobjecttype = 'Case' LIMIT 2]);
        
        set<id> 			caseIds 	= new set<id>();				// Holds id for any ParentCases referenced by whatId for tasks in trigger.new.
        //List<case> caseList 			= new List<Case>();				// Previously unused collexion. 
        
        for(Task task : newTasks) 
        {
            // CASE#00025978: require Due Date for non-personal Ops Tasks, unless they are RECURRING.
	        checkDueDate(task);

            // Loop through the all new updated tasks
            // Collect all what Ids when they are case, collect them in a set
            // Query all the cases and related all tasks from the above set
            // loop through this list
            // only if the case has tasks (irrespective of closed or open), qualify it to process else ignore
            // update the count of open tasks on the case
            // update the list            
            if(task.whatId != null  && string.valueOf(task.whatId).startsWith('500') && oldTaskMap.get(task.id).status != task.status)
            {    
                caseIds.add(task.whatId);
            } //end if 
        } //end for
        
        if(!caseIds.isEmpty())
        {
            // Old collexion declaration and SOQL query:
            // List<case> casesToUpdate 	= new List<case>
            //    							([select id,status,Pending_Task_Count__c,parentid,parent.recordtypeid,recordtypeid,Reason,(select id,Status from Tasks) 
            //                                 from Case where id in: caseIds]);
            
            // New collexion declaration and SOQL Query : CASE#26431.
            // Get Case-fields and child-Tasks, for all cases corresponding to those listed in "caseIds"... but only do this for Subcases/PMAs.            
            List <case> casesToUpdate = new list <case>( 
				// 1. GET Subcase/PMA records corresponding to the Case Ids stored in caseIds.
                [ SELECT id,status,Pending_Task_Count__c,parentid,parent.recordtypeid,recordtypeid,Reason,(select id,Status from Tasks) 
                  FROM   Case 
                  WHERE  id in :caseIds 
                  AND    recordtypeid in :RTID_Map.keySet()]);
            //Id recordtypeid = [select id from recordtype where name = 'PMAs' and sobjecttype = 'Case'].id;
            
            
            
            Id recordtypeid 			= [select id from recordtype where name = 'PMAs' and sobjecttype = 'Case'].id;
            set<case> parentCases 		= new set<case>();  // Temporary storage for the FmParentCases referenced
            												// by the subcases/PMAs (which the tasks being updated belong to). 
            for(Case cs : casesToUpdate){
               
                // 2. Update FM ParentCase accordingly and add to "Cases".
                Case parentCase;
                if(!cs.tasks.isEmpty())
                {
                    integer j = 0;
                    for(Task tsk : cs.tasks)
                    {
                        if(tsk.status != 'Completed'){
                            j++;
                        }
                    } //end for
                    
                    cs.Pending_Task_Count__c = j;
                    if(j > 0 && j != cs.tasks.size())
                    {
                        if(cs.Reason == 'Winzip Received' && cs.ParentId != null){
                            parentCase = new Case();
                            parentCase.id = cs.ParentId;
                            parentCase.Status = 'Winzip received';
                            parentCases.add(parentCase);
                        }
                        
                        cs.Status = 'In Progress';  
                    }//end if
                    
                    //if no pending FM tasks remain...
                    if(j == 0)
                    {
						//...and subcase has recordType of "PMA"...
                        if(cs.recordtypeid == recordtypeid && cs.ParentId != null){
                            parentCase = new Case();
                            parentCase.id = cs.ParentId;
                            parentCase.Status = 'Closed';//assuming PMAs are always done at the end
                            parentCases.add(parentCase);
                        }
                        cs.Status = 'Closed';
                    }
                    
                } //end if
             }
            
            for(case cs : parentCases)
            {
                casesToUpdate.add(cs);
            }
            
            update casesToUpdate;
            
        } //end if
    } //end afterUpdate
    
    public static void afterDelete(list<task> oldTasks){
        
        set<id> caseIds = new set<id>();
        List<case> caseList = new List<Case>();
        
        // Loop through the all deleted tasks
        // Collect all what Ids when they are case, collect them in a set
        // Query all the cases and related all tasks from the above set
        // loop through this list and no tasks exist no more then update the pending task count to 0
        for(Task task : oldTasks) {
            
            if(string.valueOf(task.whatId).startsWith('500')){
                
                caseIds.add(task.whatId);
                
            }
            
        }
        
        List<case> cases = new List<case>();
        cases = [select id,status,Pending_Task_Count__c ,(select id,Status from Tasks) from Case where id in: caseIds];
        
        
        for(Case cs : cases){
            
            if(cs.tasks.isEmpty()){
                // cs.Status = 'Closed';
                cs.Pending_Task_Count__c = 0;
            }
            
        }
        update cases;
        
        
    }
    
    public static void checkDueDate(task t)
   	// CASE#00025978: This method makes Due Date mandatory for non-personal Ops Tasks, unless they are RECURRING.
   	// Unable to implement this functionality using validation rules - see case notes for details.
    {
        if(t.RecordTypeId == RTID_Ops && t.Category__c != 'Personal Task' && t.ActivityDate == NULL && !t.IsRecurrence)
        {
        	t.addError('Please enter a due-date for non-personal Ops Tasks (TaskUtility.checkDueDate)'); 
        } // end if
    } // end checkDueDate
    
}