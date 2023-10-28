/**
 * Revisions:
 * 16-06-2023 - Stephen Manning - Case#00025048 - Write FM Number to FM field of FM tasks.
 * -
 * 10-Feb-2023 - Stephen Manning - Case#00025165
 * 1. Refactored 'enrichTask' to assign correct dueDate offset upon initial FM Task Creation
 * 2. Added 'afterUpdate' method to offload compute for FM CASES from ManjuPB
 * 3. CaseFMLookup populated for new cases of type PMA/Subcase in 'newSubCase' method [ previosly handled by FM_TRG_AfterCreate_AfterUpdate Flow]
 * -       
 * 31-Aug-2022	- Stephen Manning - Case#00019903 
 * 1. Added code to populate Related_To1 field on FM Tasks, in 'newTask' method
 */ 

public without sharing class caseUtility 
{
    public static void afterInsert(List<Case> newTrigger, List<Case> oldTrigger, Map<id,Case> newTriggerMap, Map<id,Case> oldTriggerMap)
    {    
        system.debug('entering caseUtility.afterInsert');
        
        Map<String,List<Case_Task_Template__mdt>> taskTemplatesMap = new Map<String,List<Case_Task_Template__mdt>>();
        List<Task> tasks = new List<Task>();
        List<Case> subCases = new List<Case>();
        Map<String,Id> RecordTypeNameIdMap = new Map<String,Id>();
        Map<String,Id> QueueNameIdMap = new Map<String,Id>();
        Map<String,String> IdRecTypeMap = new Map<String,String>();
        
        for(Group queue : [select id,name from Group where Type = 'Queue'])
        {
            QueueNameIdMap.put(queue.name,queue.id);    
        } //end for
        
        for(RecordType rtype : [select id,Name from RecordType where sObjecttype = 'Case' and IsActive = true])
        {    
            RecordTypeNameIdMap.put(rtype.Name,rtype.Id);
            IdRecTypeMap.put(rtype.Id,rtype.Name);   
        } //end for
        
        
        for(Case_Task_Template__mdt ctt : [select Case_Category__c ,Case_Reason__c, Case_Record_Type__c,
                                           Description__c,Due_Date__c,Estimated_Time_Required__c,Object_API__c,Origin__c,
                                           Priority__c,Status__c,Subject__c,Child_Object_RecordType_Name__c,
                                           Child_Case_Reason__c ,Active__c,Summary__c,Category__c,
                                           Owner_Queue__c from Case_Task_Template__mdt where active__c = true])
        {                                    
        	if(!taskTemplatesMap.containsKey(ctt.Case_Record_Type__c))
                taskTemplatesMap.put(ctt.Case_Record_Type__c, new List<Case_Task_Template__mdt>());
                                               
         	taskTemplatesMap.get(ctt.Case_Record_Type__c).add(ctt);                                     
       	} //end for
        
        for(Case c : newTrigger)
        {
            if(taskTemplatesMap.get(IdRecTypeMap.get(c.RecordTypeId)) != null)
            {
                for(Case_Task_Template__mdt cttObj : taskTemplatesMap.get(IdRecTypeMap.get(c.RecordTypeId)))
                {
                    if(cttObj.Object_API__c == 'Task')
                    {
                       
                        Task t = newTask(c,cttObj);
                        if(t != null)
                        {
                            //system.debug(t);
                            tasks.add(t);
                        }
                            
                    }
                    else if(cttObj.Object_API__c == 'Case' && (cttObj.Case_Reason__c != null && c.Reason == cttObj.Case_Reason__c))
                    {
                       subCases.add(newSubCase(c,cttObj,RecordTypeNameIdMap,QueueNameIdMap));
                    } 
			
            	} //end for    
            } //end if
         } //end for 
        
        if(!tasks.isEmpty())
        {
            system.debug('CaseUtility.afterInsert - inserting ' + tasks.size() + 'tasks.');
            //system.debug(tasks);
            insert tasks;
        }
        
        if(!subCases.isEmpty())
        {
            system.debug('CaseUtility.afterInsert - inserting ' + subCases.size() + ' subcases/PMAs.');
            insert subCases;
        }
        
    }
    
    public static Task newTask(Case parentCase,Case_Task_Template__mdt taskTemplate){

	    //system.debug('entering caseUtility.newTask');
        Task t;
        if(taskTemplate.Case_Reason__c != null && taskTemplate.Case_Reason__c == parentCase.Reason 
           && taskTemplate.Case_Category__c != null && taskTemplate.Case_Category__c  == parentCase.category__c)
        {
               
            t = new Task();
            t.WhatId = parentCase.id;
            if(parentCase.Assigned_to__c != null) {
                t.OwnerId = parentCase.Assigned_to__c;
            }
            if(taskTemplate.Category__c.contains('Foundation') && (parentCase.AccountId != NULL))
            // CASE#00019903 - Populate "Related_To1__c"
        	t.Related_To1__c =  parentCase.AccountId;

            // CASE #00025048 - Populate Foundation Meeting on FM Tasks
            if (parentCase.Case_FM_Lookup__c != NULL)
            {
            	t.Foundation_Meeting_in_task__c = parentCase.Case_FM_lookup__c;
            }

            enrichTask(t,parentCase,taskTemplate);
            return t;  
        } //end if
        else if(taskTemplate.Case_Reason__c == null && taskTemplate.Case_Record_Type__c != null){
           t = new Task();
           t.WhatId = parentCase.id;
            if(parentCase.Assigned_to__c != null) {
                t.OwnerId = parentCase.Assigned_to__c;
            }
           enrichTask(t,parentCase,taskTemplate);
           return t;
        }
        
        return null;
        
    }
    
    private static Task enrichTask(Task t, Case parentCase, Case_Task_Template__mdt taskTemplate)
    {
        //Description
            if(taskTemplate.Description__c != null)
            {
                /*if(taskTemplate.Description__c.contains('[Case]'))
                    
                {
               		
                    t.Description = (String)parentCase.get(taskTemplate.Description__c.split(']')[1]);
				}
                else*/
                {
            		t.Description = taskTemplate.Description__c;        
                }      
            }
        // Due Date
           	if(taskTemplate.Due_Date__c != null && parentCase.Due_Date__c != null){     
				//ActivityDate = parentCase.Due_Date__c.addDays((Integer)taskTemplate.Due_Date__c);
        		// SM - CASE#00025165
                t.ActivityDate = parentCase.Due_Date__c;
            }
        //else if(taskTemplate.Due_Date__c != null && parentCase.Due_Date__c == null){
        else if(taskTemplate.Due_Date__c != null && parentCase.FM_meeting_date__c == null){
            DateTime dT = System.now();
			Date myDate = date.newinstance(dT.year(), dT.month(), dT.day());
            t.ActivityDate = (myDate).addDays((Integer)taskTemplate.Due_Date__c);
    	}
        // Subject   
            if(taskTemplate.Subject__c != null){
                
               /* if(taskTemplate.Subject__c.contains('[Case]'))
                {
               			t.Subject = (String)parentCase.get(taskTemplate.Subject__c.split(']')[1]);
				}
                else*/
                {
            			t.Subject = taskTemplate.Subject__c;        
                }
                
            }
        
        // Status
        	if(taskTemplate.Status__c != null){
                
                /*if(taskTemplate.Status__c.contains('[Case]'))
                {
               			t.Status = (String)parentCase.get(taskTemplate.Status__c.split(']')[1]);
				}
                else*/
                {
            			t.Status = taskTemplate.Status__c;        
                }
                
            }
        // Priority
        	if(taskTemplate.Priority__c != null){
                
                /*if(taskTemplate.Priority__c.contains('[Case]'))
                {
               			t.Priority = (String)parentCase.get(taskTemplate.Priority__c.split(']')[1]);
				}
                else*/
                {
            			t.Priority = taskTemplate.Priority__c;        
                }
                
            }
        // Origin
        	if(taskTemplate.Origin__c != null){
                
               /* if(taskTemplate.Origin__c.contains('[Case]'))
                {
               			t.Origin__c = (String)parentCase.get(taskTemplate.Origin__c.split(']')[1]);
				}
                else*/
                {
            			t.Origin__c = taskTemplate.Origin__c;        
                }
                
            }
        // Estimated Time 
        if(taskTemplate.Estimated_Time_Required__c != null){
            t.Estimated_Time_Required__c = taskTemplate.Estimated_Time_Required__c;
        }
        
        //Category
            if(taskTemplate.Category__c != null)
            {
                if(taskTemplate.Category__c.contains('[Case]'))
                    
                {
               		
                    t.Category__c = (String)parentCase.get(taskTemplate.Category__c.split(']')[1]);
				}
                else
                {
            		t.Category__c = taskTemplate.Category__c;        
                }      
            }
            return t;
    }
    
    public static Case newSubCase(Case parentCase, Case_Task_Template__mdt taskTemplate,Map<String,Id> recTypeMap,Map<String,Id> QueueNameIdMap){
        
        Case c = new Case();
        c.AccountId = ParentCase.AccountId;
        //Parent Case
        c.ParentId = parentcase.Id;
        // Assignment
        if(parentCase.Assigned_to__c != null)
        	c.Assigned_to__c = parentCase.Assigned_to__c;
        // Record Type
        if(taskTemplate.Child_Object_RecordType_Name__c != null && recTypeMap.get(taskTemplate.Child_Object_RecordType_Name__c) != null)
        	c.RecordTypeId = recTypeMap.get(taskTemplate.Child_Object_RecordType_Name__c);
        
        // Owner
        if(taskTemplate.Owner_Queue__c != null){
            c.OwnerId = QueueNameIdMap.get(taskTemplate.Owner_Queue__c);
        }
        else if(parentCase.Assigned_to__c != null)  {
            c.OwnerId = parentCase.Assigned_to__c;
        }
        else c.OwnerId = UserInfo.getUserId();
        
        
        //Reason
        if(taskTemplate.Child_Case_Reason__c != null){
            c.Reason = taskTemplate.Child_Case_Reason__c;
        }
        //Status
        if(taskTemplate.Status__c != null){
                
                if(taskTemplate.Status__c.contains('[Case]'))
                {
               			c.Status = (String)parentCase.get(taskTemplate.Status__c.split(']')[1]);
				}
                else
                {
            			c.Status = taskTemplate.Status__c;        
                }
                
         }
        //Description
            if(taskTemplate.Description__c != null)
            {
                if(taskTemplate.Description__c.contains('[Case]'))
                    
                {
               		
                    c.Description = (String)parentCase.get(taskTemplate.Description__c.split(']')[1]);
				}
                else
                {
            		c.Description = taskTemplate.Description__c;        
                }      
            }
        // Priority
        	if(taskTemplate.Priority__c != null){
                
                if(taskTemplate.Priority__c.contains('[Case]'))
                {
               			c.Priority = (String)parentCase.get(taskTemplate.Priority__c.split(']')[1]);
				}
                else
                {
            			c.Priority = taskTemplate.Priority__c;        
                }
                
            }
        // Subject   
           if(taskTemplate.Subject__c != null){
                
                if(taskTemplate.Subject__c.contains('[Case]'))
                {
               			c.Subject = (String)parentCase.get(taskTemplate.Subject__c.split(']')[1]);
				}
                else
                {
            			c.Subject = taskTemplate.Subject__c;        
                }
                
            }
        // Origin
        	if(taskTemplate.Origin__c != null){
                
                if(taskTemplate.Origin__c.contains('[Case]'))
                {
               			c.Origin = (String)parentCase.get(taskTemplate.Origin__c.split(']')[1]);
				}
                else
                {
            			c.Origin = taskTemplate.Origin__c;        
                }
                
            }
        // Due Date
         if(taskTemplate.Due_Date__c != null && parentCase.Due_Date__c != null){
                
                	c.Due_Date__c  = parentCase.FM_meeting_date__c.addDays((Integer)taskTemplate.Due_Date__c);
			
            }
        //Estimated Time
        if(taskTemplate.Estimated_Time_Required__c != null){
            c.Estimated_time_for_case__c = taskTemplate.Estimated_Time_Required__c;
        }
        
        // Category 
           if(taskTemplate.Category__c != null){
                
                if(taskTemplate.Category__c.contains('[Case]'))
                {
               			c.Category__c = (String)parentCase.get(taskTemplate.Category__c.split(']')[1]);
				}
                else
                {
            			c.Category__c = taskTemplate.Category__c;        
                }
                
            }
        
        /* 
         * SM - CASE#00025165
         * Add CaseFMLookup for NEW Cases of type PMA or Subcase (Currently handled by CASE_TRG_AfterCreate_AfterUpdate- V1)
         */ 
        c.Case_FM_lookup__c = parentCase.Case_FM_lookup__c;	

        return c;    
    }

    
    public static void afterUpdate(List<Case> newTrigger, List<Case> oldTrigger, Map<id,Case> newTriggerMap, Map<id,Case> oldTriggerMap)
    {
        string RTID_SubCases 	= Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Subcases').getRecordTypeId();
        string RTID_PMAs		= Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('PMAs').getRecordTypeId();
        string RTID_FMs			= Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Foundation_Meetings').getRecordTypeId();

        system.debug('Entering CaseUtility.afterUpdate...'); 
        Set<Case>	casesToUpdateSet 	= new Set <Case>();
		Set<Task> 	tasksToUpdateSet 	= new Set <Task>();

        // Get list of all subcases/pmas linked to records in trigger.new
        List<Case>	allSubCasesList		= new list <Case>([ SELECT id, reason, due_Date__c, assigned_to__c, recordtypeid, parentid
                                                        FROM case WHERE (recordtypeid = :RTID_SubCases or recordtypeid = :RTID_PMAs)
                                                        AND parentId in :newTrigger ]);
        Set<Case> 	allSubCasesSet 		= new Set<Case>(allSubCasesList); 

        for ( case c : newTrigger )
        {
			/********************************************************************************************************************
            * SCENARIO #1 - CASES BEING UPDATED in TRIGGER.NEW ARE FM PARENT CASES.
			* Previously handled by ManjuPB[Node 4 of 14] - "IF DueDate changes on ParentCase, THEN Update Due date on SubCases "
            *********************************************************************************************************************/

            if ((c.RecordTypeId == RTID_FMs) && (newTriggermap.get(c.id).Due_Date__c != oldTriggerMap.get(c.id).Due_Date__c))
            {
                Set<Case> 	SubCasesForThisFM_Set = new Set <Case>();				 			// Holds subcases/PMAs linked to current FM Parent Case
                for (case subCase : allSubCasesSet) 											// FOREACH Subcase/PMA...(there will be 5 or 6 per FM ParentCase,
                    																			// depending on whether there is a change of FM Meeting Date subcase)
                {
                    if (subCase.parentId == c.id) 												
                        SubCasesForThisFM_Set.add(subCase);										// Each of the 5-6 subcases will have a different "Reason" (e.g., 'Distribution')
                }
                if ((SubCasesForThisFM_Set.size() != 0) && (SubCasesForThisFM_Set != NULL))		// If there were ParentCases (and thus, related subcases/PMAs) in trigger.new...
                {
                    for ( case c2 : SubCasesForThisFM_Set )
                    {
                        switch on c2.reason  {
                            when 'Winzip Received' 			{ c2.Due_Date__c = c.Due_Date__c-14; }
                            when 'Agenda to Adviser'		{ c2.Due_Date__c = c.Due_Date__c-14; }
                            when 'Distribution'				{ c2.Due_Date__c = c.Due_Date__c-7; }
                            when 'Meeting Date'				{ c2.Due_Date__c = c.Due_Date__c; }
                            when 'PMAs'						{ c2.Due_Date__c = c.Due_Date__c+ 7; }
                            when 'Change of Meeting Date'	{ c2.Due_Date__c = c.Due_Date__c; }
                        }//end switch
                    }
                    
                    /*SubCasesForThisFM_Map.get('Winzip Received').Due_Date__c 	= c.Due_Date__c-14;
                    SubCasesForThisFM_Map.get('Agenda to Adviser').Due_Date__c 	= c.Due_Date__c-14; 
                    SubCasesForThisFM_Map.get(''Agenda to Adviser').Due_Date__c 		= c.Due_Date__c-7;
                    SubCasesForThisFM_Map.get('Agenda to Adviser'.Due_Date__c 		= c.Due_Date__c;
                    SubCasesForThisFM_Map.get('PMAs').Due_Date__c 				= c.Due_Date__c+7;
                    if (SubCasesForThisFM_Map.containsKey('Change of Meeting Date'))
                    {
                        SubCasesForThisFM_Map.get('Change of Meeting Date').Due_Date__c	= c.Due_Date__c;
                    }*/
                } // end if

               	casesToUpdateSet.addall(SubCasesForThisFM_Set);
            }//end if 
                    
            /*********************************************************************************************************** 
		 	* SCENARIO #2 - CASES BEING UPDATED in TRIGGER.NEW ARE FM PARENT CASES
			* Manju PB, Node 13/14- "IF 'AssignedTo' changes on ParentCase, THEN Update AssignedTo on SubCases"
			* NOTE: 'AssignedTo' on FM Parent Case corresponds to 'Paper Author' on FM
			************************************************************************************************************/ 
		    if ((c.RecordTypeId == RTID_FMS) && (newTriggermap.get(c.id).Assigned_To__c != oldTriggerMap.get(c.id).Assigned_To__c) && (c.Assigned_To__c != NULL))
            {
				for (case subCase : allSubCasesSet )
                {
                	subCase.Assigned_To__c = c.Assigned_To__c;
                    casesToUpdateSet.add(subCase);
                }
            } // end if 
                
            /**********************************************************************************************************
            * SCENARIO #3-4 - CASES BEING UPDATED in TRIGGER.NEW ARE SUBCASES/PMAS
            * Manju PB, Node 5,6 and 7 /14 - "IF DueDate or AssignedTo has changed on SubCase/PMA, THEN update on Tasks "
            ***********************************************************************************************************/
            if 
            (
                ((c.RecordTypeId == RTID_Subcases) || (c.RecordTypeId == RTID_PMAs))
                && 
                (
                    (newTriggermap.get(c.id).Due_Date__c != oldTriggerMap.get(c.id).Due_Date__c)
                    ||
                    (newTriggermap.get(c.id).Assigned_To__c != oldTriggerMap.get(c.id).Assigned_To__c)
                )
            )    
           	{
            	for (task t:[ SELECT id, WhatId, ActivityDate, Description FROM Task WHERE WhatId = :c.id])
               	{
                	t.ActivityDate 	= c.Due_Date__c;
					t.OwnerId 		= c.Assigned_To__c;
                    tasksToUpdateSet.add(t);
                    //system.debug('DATE updated on task: ' + t.Id + ' - ' + t.Description);
                    //system.debug('OWNER updated on task: ' + t.Id + ' - ' + t.Ownerid);
               	}
           	}//end if 

            /*****************************************************
            * Manju_PB_Node_9-14 - Update STAGE of Parent Case 
            ****************************************************/
            if (
                ((c.RecordTypeId == RTID_Subcases) || (c.RecordTypeId == RTID_PMAs))
                && (newTriggerMap.get(c.id).status != oldTriggerMap.get(c.id).status)
                && (c.Status == 'Closed')
               )
            {
                system.debug('Manju_PB_Node_9-14 - Update STAGE of Parent Case ');
                case parentCase = [ SELECT id, status, reason FROM case WHERE id = :c.ParentId];
                switch on c.Reason
                {
                    when 'Winzip Received' 
                    	{ parentCase.status = 'Agenda to Adviser'; }
                    when 'Agenda to Adviser' 
                    	{ system.debug('Case Reason: '+c.reason);
                            parentCase.status = 'Distribution'; }
                    when 'Distribution' 
                    	{ parentCase.status = 'Meeting Date'; }
                    when 'Meeting Date' 
                    	{ parentCase.status = 'PMAs'; }
                } //end switch
            	casesToUpdateSet.add(parentCase);                
            }
        } //end for

        if ((casesToUpdateSet!=NULL) && (casesToUpdateSet.size()!=0) && (CaseUtilityHandler.CasesNotUpdatedYet))
        {
        	system.debug('CaseUtilityHandler.casesNotUpdatedYet = ' + CaseUtilityHandler.casesNotUpdatedYet + '. caseUtility will now invoke the CaseUtilityHandler.CaseHandler method...');
            CaseUtilityHandler.CaseHandlerMethod(CasesToUpdateSet);            //Avoid error "DML statement cannot operate on trigger.new or trigger.old"   
        }
        if ((tasksToUpdateSet!=NULL) && (tasksToUpdateSet.size()!=0) && (CaseUtilityHandler.TasksNotUpdatedYet))
        {
            system.debug('CaseUtilityHandler.tasksNotUpdatedYet = ' + CaseUtilityHandler.tasksNotUpdatedYet + '. caseUtility will now invoke the CaseUtilityHandler.TaskHandler method...');
            CaseUtilityHandler.TaskHandlerMethod(tasksToUpdateSet);
        }
    } //end afterUpdate
} //end CaseUtility




/*****************************************************
* BELOW MUST BE MOVED TO FLOW, OR TASKUTIITY *
* 2c - Manju_PB_Node - 8/14 - Update Subcases to CLOSED
****************************************************/
/*
if 
(
((c.RecordTypeId == RTID_Subcases) || (c.RecordTypeId == RTID_PMAs)) &&
(newTriggermap.get(c.id).Pending_Task_Count__c != oldTriggermap.get(c.id).Pending_Task_Count__c) &&
(newTriggermap.get(c.id).Pending_Task_Count__c == 0)
)
{
c.Status = 'Closed';
casesToUpdate.add(c);
}*/