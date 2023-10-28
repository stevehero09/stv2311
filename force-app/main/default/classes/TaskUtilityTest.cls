/**
 * Created by Stephen Manning on November 10, 2022.
 * This code tests the TaskUtility class.
 */
/* Minor update by SR on 24/04/23 - as we're removing the AS support user, changing the 'rogue user' ru in testAsRogueUserOpsTask() tto sysadmin.
Also changing the hardcoded Ops user in testAsNormalUserOpsTaskNonPersonal() to a query, rather than rely on a particular record.
Note, users could be created in test, but as the main class relies on Custom Mdata recordsa, will query from existing instead.
*/

@isTest
private class TaskUtilityTest {
	/*
 	 * @isTest static void testCMDT(){
	 *	Map<string, RogueUsers__mdt> ruMap = RogueUsers__mdt.getAll();
     *	system.AssertNotEquals ( 0, ruMap.size());
   } */

    @testSetup static void setup(){
        //Create parent case
        Case c = new Case(Subject='TEST PARENT CASE');
        insert c;
        Case pc = [ SELECT id, Subject FROM case WHERE Subject = 'TEST PARENT CASE'];
    } //end setup


    @isTest static void testAsRogueUserOpsTask(){
        User ru			= [SELECT id FROM User WHERE alias = 'sysadmin' AND IsActive = true LIMIT 1];
        Id RTID_APSF	= [SELECT id FROM RecordType WHERE developername = 'APSF' and SObjectType = 'Task' LIMIT 1].id;

        // The following code runs as a ROGUE USER and tests RTID assignment for uncategorised non-personal Ops tasks
        System.runAs(ru) {
    		System.debug('Rogue User: ' + UserInfo.getUserName());

            // Create a task and insert it
            // VR_TASK validation rules don't apply to non-personal ops tasks created by a RogueUser
            Task t 				= new Task(Description__c = 'CASE#23304_RogueUser');
            insert (t);

            // Query the task that was inserted.
            Task testTask = [SELECT Id, Description__c, RecordTypeId, activityDate, whatId FROM Task
                            WHERE Description__c = 'CASE#23304_RogueUser' LIMIT 1];

            system.debug('RTID of test task is: ' +testTask.RecordTypeId);
            system.AssertEquals ( RTID_APSF, testTask.RecordTypeId);
            system.AssertEquals	( testTask.activityDate, NULL);
            system.AssertEquals	( testTask.whatId, NULL);
            }//end RunAs
    }//end testAsRogueUser


    @isTest static void testAsNormalUserOpsTaskNonPersonal(){
        // The following code runs as a NORMAL USER and tests RTID assignment for uncategorised non-personal Ops tasks
        User nu			= [SELECT id FROM User WHERE UserRoleId = '00E6F000001egg3' AND IsActive = true LIMIT 1];
        Id RTID_Ops	= [SELECT id FROM RecordType WHERE developername = 'Operations' and SObjectType = 'Task' LIMIT 1].id;

        System.runAs(nu) {
            //Get Parent Case
            Case pc = [ SELECT id, Subject FROM case WHERE Subject = 'TEST PARENT CASE'];

            //System.debug('Current User: ' + UserInfo.getUserName());
            Task t 				= new Task();
            t.ActivityDate 		= System.today();
            t.Description__c	= 'CASE#23304_NormalUser';
            t.whatid			= pc.id;
            insert (t);

            // Query the task that was inserted.
            Task testTask2 = [SELECT Id, Description__c, RecordTypeId FROM Task
                             WHERE Description__c = 'CASE#23304_NormalUser' LIMIT 1];

            system.debug('RTID of test task is: ' +testTask2.RecordTypeId);
            system.AssertEquals ( RTID_Ops, testTask2.RecordTypeId);
        }
    }

   @isTest static void testAsNormalUserOpsTaskPERSONAL(){
        // The following code runs as a NORMAL USER and tests RTID assignment for uncategorised non-personal Ops tasks
        User nu			= [SELECT id FROM User WHERE UserRoleId = '00E6F000001egg3' AND IsActive = true LIMIT 1];
        Id RTID_Ops		= [SELECT id FROM RecordType WHERE developername = 'Operations' and SObjectType = 'Task' LIMIT 1].id;

        System.runAs(nu) {
            //Get Parent Case
            Case pc = [ SELECT id, Subject FROM case WHERE Subject = 'TEST PARENT CASE'];

            Task t 				= new Task();
            t.Category__c		= 'Personal Task';
            t.Description__c	= 'CASE#23304_NormalUser_PERSONALTASK';
            insert (t);

            // Query the task that was inserted.
            Task npTask = [SELECT Id, Description__c, RecordTypeId
                           FROM Task
                           WHERE Description__c = 'CASE#23304_NormalUser_PERSONALTASK'
                           LIMIT 1];

            system.debug('RTID of test task is: ' +npTask.RecordTypeId);
            system.AssertEquals ( RTID_Ops, npTask.RecordTypeId);
        }
    }

    @isTest static void testAsRogueUserNonOpstask(){
        User ru			= [SELECT id FROM User WHERE alias = 'sysadmin' AND IsActive = true LIMIT 1];
        Id RTID_Giving	= [SELECT id FROM RecordType WHERE developername = 'Giving_Team' and SObjectType = 'Task' LIMIT 1].id;

        //Get Parent Case
        Case pc = [ SELECT id, Subject FROM case WHERE Subject = 'TEST PARENT CASE'];

        system.runas(ru){
            //System.debug('Current User: ' + UserInfo.getUserName());
            Task t 				= new Task();
            t.Description__c	= 'CASE#23304_RU_GIVING-TASK';
            t.RecordTypeId		= RTID_Giving;
            insert (t);

            // Query the task that was inserted.
            Task testTask3 = [SELECT Id, Description__c, RecordTypeId
                              FROM Task
                              WHERE Description__c = 'CASE#23304_RU_GIVING-TASK'
                              LIMIT 1];

            system.debug('RTID of test task is: ' +testTask3.RecordTypeId);
            system.AssertEquals ( RTID_Giving, testTask3.RecordTypeId);
        }  //end runas
    }//end test_NONOPS_task

    @isTest static void ExceptionTestRU(){
		User u	= [SELECT id FROM User WHERE alias = 'sysadmin' AND IsActive = true LIMIT 1];
        System.runas(u)   {
            try {
    			task t = new task (recordtypeid='invalidId');
				//insert t;
    		}//end try
    		catch (Exception ex) {
                system.debug(ex.getMessage()) ;
		        system.assertEquals('Invalid id: invalidId', ex.getMessage());
     		} //end catch
        } //end runas
	}//end ExceptionTest

    /*@isTest static void exceptionTestNU(){
        // The following tests VALIDATION RULES for NORMAL USER for uncategorised non-personal Ops tasks
        User nu			= [SELECT id FROM User WHERE alias = 'espi' LIMIT 1];
        Id RTID_Ops		= [SELECT id FROM RecordType WHERE developername = 'Operations' and SObjectType = 'Task' LIMIT 1].id;

        System.runAs(nu) {
            //System.debug('Current User: ' + UserInfo.getUserName());
            try{
                Task t 				= new Task();
            	//t.ActivityDate 		= System.today();
            	t.Description__c	= 'CASE#23304_NormalUser_BADTASK';
            	//t.whatid			= pc.id;
            	insert (t);
            } //end try

            catch(exception e){
                system.debug('Normal-User task could NOT be inserted, due to TASK VALIDATION RULES!!');
                system.assertEquals('Insert failed. First exception on row 0; first error: FIELD_CUSTOM_VALIDATION_EXCEPTION, Due-date must be populated for non-personal Ops tasks [ VR_TASK_EnforceDueDate ].: [ActivityDate]', e.getMessage());
            } //end catch
        } // end runas
    }//end exceptionTestNU
*/

}//end TaskUtilityTest