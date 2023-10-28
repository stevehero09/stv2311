@IsTest (seeAllData = true)
public class CaseUtilityTest {
    
    static testMethod void createFoundationMeeting() {
        Account acc = new Account();
        acc.Name = 'Some Account';
        insert acc;

        Contact cnt = new Contact();
        cnt.FirstName = 'Sne';
        cnt.LastName = 'Sme name';
        insert cnt;

        Foundation_Meeting__c FM = new Foundation_Meeting__c();
        FM.Paper_Author__c = UserInfo.getUserId();
        FM.Organisation_Name__c = acc.Id;
        FM.Meeting_type__c = 'Annual';
        FM.Date_of_Meeting__c = System.today();
        insert FM;
    }
     static testMethod void UpdateFoundationMeetingDate() {
        Account acc = new Account();
        acc.Name = 'Some Account';
        insert acc;

        Contact cnt = new Contact();
        cnt.FirstName = 'Sne';
        cnt.LastName = 'Sme name';
        insert cnt;

        Foundation_Meeting__c FM = new Foundation_Meeting__c();
        FM.Organisation_Name__c = acc.Id;
        FM.Meeting_type__c = 'Annual';
        FM.Date_of_Meeting__c = System.today();
        insert FM;

        FM.Date_of_Meeting__c = System.today() + 10;
        update FM;
    }

    static testMethod void PersonalCase() {

        Account acc = new Account();
        acc.Name = 'Some Account';
        insert acc;

        Contact cnt = new Contact();
        cnt.FirstName = 'Sne';
        cnt.LastName = 'Sme name';
        insert cnt;

        Case cs = new Case();
        cs.Priority = 'High';
        cs.Summary__c = 'Random';
        cs.Description = 'Some Random';
        cs.Origin = 'Web';
        cs.AccountId = acc.Id;
        cs.ContactId = cnt.id;
        cs.RecordTypeId = [select id from Recordtype where sObjecttype = 'Case' and IsActive = true and name = 'Personal'].Id;
        cs.Reason = 'Analytics';
        insert cs;

    }

}