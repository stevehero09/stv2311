/**
* Revisions:	11-Nov-2022	- Stephen Manning	- Added Task.ActivityDate and Case.DueDate__c to Tasks/Cases instantiated in "getTasks",
	to fix testing errors introduced by TaskDueDate ValidationRule in R-0000085.
**/ 

@isTest(seeAllData = true)
public class ActivityClassTest {
    
    static testMethod void getTasks(){
        
         Account acc = new Account();
        acc.Name = 'Some Account';
        insert acc;
        String accId = [ SELECT id, Name FROM Account WHERE name = 'Some Account'].id;
        system.debug('inserted account with ID: '+accId);

        Contact cnt = new Contact();
        cnt.FirstName = 'Sne';
        cnt.LastName = 'Sme name';
        insert cnt;
        String contactId = [ SELECT id, FirstName FROM Contact WHERE FirstName = 'Sne'].id;
        system.debug ('inserted contact with ID: ' + contactId);
        
        Case cs1 = new Case();
        cs1.Priority = 'High';
        cs1.Summary__c = 'Random1';
        cs1.Description = 'Some Random';
        cs1.Origin = 'Web';
        cs1.AccountId = acc.Id;
        cs1.ContactId = cnt.id;
        cs1.RecordTypeId  = [select id from recordtype where name = 'Foundation Meetings' and sobjecttype = 'Case'].Id;
        cs1.Reason ='Winzip Received';
        cs1.Due_Date__c = system.today();
        insert cs1;
        Case thisCase = [ SELECT id, Reason, Summary__c FROM Case WHERE Summary__c = 'Random1' LIMIT 1];
        system.debug ('inserted Case: ' + thisCase.Reason + ' ' + thisCase.Summary__c );

        Case cs = new Case();
        cs.Priority = 'High';
        cs.Summary__c = 'Random2';
        cs.Description = 'Some Random2';
        cs.Origin = 'Web';
        cs.AccountId = acc.Id;
        cs.ContactId = cnt.id;
        cs.RecordTypeId  = [select id from recordtype where name = 'PMAs' and sobjecttype = 'Case'].Id;
        cs.Reason ='Winzip Received';
        cs.ParentId = cs1.id;
        cs.due_date__c = system.today();
        insert cs;
        Case thisCase2 = [ SELECT id, Reason, Summary__c FROM Case WHERE Summary__c = 'Random2' LIMIT 1];
        system.debug ('inserted Case: ' + thisCase2.Reason + ' ' + thisCase2.Summary__c );        
        
        Task tsk = new Task();
        tsk.WhatId = cs.Id;
        tsk.whoid = cnt.id;
		tsk.ActivityDate = system.today();
        insert tsk;
        Task thisTask = [ SELECT id, whatId, whoId, activityDate FROM Task WHERE WhatId = :thisCase2.id];
        system.debug ('inserted Case: ' + thisCase.Reason + ' ' + thisCase.Summary__c );        
        
        
        
        List<id> ids = new List<id>();
        ids.add(tsk.id);
        system.debug(ids);
        
        List <Task> result = ActivityClass.getActivity(cs.Id);
        system.debug(result);
		
        Task tsk2 = new Task();
        tsk2.WhatId = cs.Id;
        tsk2.whoid = cnt.id;
        tsk2.ActivityDate = system.today();
        insert tsk2;
        
        ActivityClass.UpdateActivity(ids, 'Completed');
        ActivityClass.deleteActivity(ids);
    }

}