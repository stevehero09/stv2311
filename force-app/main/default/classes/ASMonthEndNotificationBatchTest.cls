@isTest
public class ASMonthEndNotificationBatchTest {

    @TestSetup
    static void setup(){

        Id orgRT = Schema.SObjectType.Account.getRecordTypeInfosByName().get('APS Foundation Giving Fund').getRecordTypeId();
        Id orgRT2 = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Non - Profits').getRecordTypeId();
        Id donationRT = Schema.SObjectType.AS_Transaction__c.getRecordTypeInfosByName().get('Donation').getRecordTypeId();
        Id giftRT = Schema.SObjectType.AS_Transaction__c.getRecordTypeInfosByName().get('Gift').getRecordTypeId();
        Id adjustmentRT = Schema.SObjectType.AS_Transaction__c.getRecordTypeInfosByName().get('Adjustment').getRecordTypeId();

        Profile prof = [
            SELECT  
                Id, Name 
            FROM Profile 
            WHERE
                Name = 'Customer Community Plus Login User (Custom)'
        ];
        
        List<Account> accountList = new List<Account>();
        Account acc1 = new Account(
            RecordTypeId = orgRT,
            Name = 'Test Giving Fund 1',
            Balance__c = 20000000,
            Status__c = 'Active',
            AS_Previous_Month_End_Balance__c = 2000000000, 
            Investment_Portfolio__c = 'General Portfolio'
        );
        accountList.add(acc1);
        Account acc2 = new Account(
            RecordTypeId = orgRT,
            Name = 'Test Giving Fund 2',
            Balance__c = 25000000,
            Status__c = 'Active',
            AS_Previous_Month_End_Balance__c = 250000000, 
            Investment_Portfolio__c = 'Focused Portfolio'
        );
        accountList.add(acc2);
        Account acc3 = new Account(
            RecordTypeId = orgRT,
            Name = 'Test Non Profit',
            Status__c = 'Active',
            AS_Previous_Month_End_Balance__c = 300000000, 
            Investment_Portfolio__c = 'General Portfolio'
        );
        accountList.add(acc3);
        insert accountList;
        
        List<Contact> contactList = new List<Contact>();
        Contact con1 = new Contact(
            FirstName = 'Test FirstName 1',
            LastName = 'Test LastName 1',
            Preferred_Name__c = 'Test Preferred 1',
            Email = 'test@email.com',
            AccountId = acc1.Id
        );
        contactList.add(con1);
        Contact con2 = new Contact(
            FirstName = 'Test FirstName 2',
            LastName = 'Test LastName 2',
            Preferred_Name__c = 'Test Preferred 2',
            Email = 'test2@email.com',
            AccountId = acc2.Id
        );
        contactList.add(con2);
        Contact con3 = new Contact(
            FirstName = 'Test FirstName 3',
            LastName = 'Test LastName 3',
            Preferred_Name__c = 'Test Preferred 3',
            Email = 'test3@email.com',
            AccountId = acc3.Id
        );
        contactList.add(con3);
        insert contactList;

        List<User> testUsersToInsert = new List<User>();
        User user1 = new User(
            FirstName = 'Test FirstName 1', 
            LastName = 'Test LastName 1', 
            Email = 'test1@email.com', 
            Alias = 'test1', 
            Username = 'test1@email.com', 
            CommunityNickname = 'Test FirstName 1', 
            ProfileId = prof.Id, 
            TimeZoneSidKey = 'Australia/Sydney', 
            LocaleSidKey = 'en_US', 
            EmailEncodingKey = 'UTF-8', 
            LanguageLocaleKey = 'en_US', 
            ContactId = con1.Id
        );
        testUsersToInsert.add(user1);
        User user2 = new User(
            FirstName = 'Test FirstName 2', 
            LastName = 'Test LastName 2', 
            Email = 'test2@email.com', 
            Alias = 'test2', 
            Username = 'test2@email.com', 
            CommunityNickname = 'Test FirstName 2', 
            ProfileId = prof.Id, 
            TimeZoneSidKey = 'Australia/Sydney', 
            LocaleSidKey = 'en_US', 
            EmailEncodingKey = 'UTF-8', 
            LanguageLocaleKey = 'en_US', 
            ContactId = con2.Id
        );
        testUsersToInsert.add(user2);
        User user3 = new User(
            FirstName = 'Test FirstName 3', 
            LastName = 'Test LastName 3', 
            Email = 'test3@email.com', 
            Alias = 'test3', 
            Username = 'test3@email.com', 
            CommunityNickname = 'Test FirstName 3', 
            ProfileId = prof.Id, 
            TimeZoneSidKey = 'Australia/Sydney', 
            LocaleSidKey = 'en_US', 
            EmailEncodingKey = 'UTF-8', 
            LanguageLocaleKey = 'en_US', 
            ContactId = con3.Id
        );
        testUsersToInsert.add(user3);
        insert testUsersToInsert;

        List<npe5__Affiliation__c> testAffiliationsToInsert = new List<npe5__Affiliation__c>();
        npe5__Affiliation__c newAff1 = new npe5__Affiliation__c(
            Key_Contact__c = true,
            Portal_Contact__c = true,
            Position__c = 'Director',
            npe5__Organization__c = acc1.Id,
            npe5__Contact__c = con1.Id
        );
        testAffiliationsToInsert.add(newAff1);
        npe5__Affiliation__c newAff2 = new npe5__Affiliation__c(
            Key_Contact__c = true,
            Portal_Contact__c = true,
            Position__c = 'Director',
            npe5__Organization__c = acc2.Id,
            npe5__Contact__c = con2.Id
        );
        testAffiliationsToInsert.add(newAff2);
        npe5__Affiliation__c newAff3 = new npe5__Affiliation__c(
            Key_Contact__c = true,
            Portal_Contact__c = true,
            Position__c = 'Director',
            npe5__Organization__c = acc3.Id,
            npe5__Contact__c = con3.Id
        );
        testAffiliationsToInsert.add(newAff3);
        insert newAff1;
    }

    @IsTest
    static void testMonthEndNotificationBatchGeneralOption(){
        
        Test.startTest();

        System.runAs (new User(Id = UserInfo.getUserId()) ){
            EmailTemplate testEmailTemplate = new EmailTemplate();
            testEmailTemplate.isActive = true;
            testEmailTemplate.Name = 'Balance Update Notification';
            testEmailTemplate.DeveloperName = 'Balance_Update_Notification';
            testEmailTemplate.TemplateType = 'text';
            testEmailTemplate.FolderId = UserInfo.getUserId();
            insert testEmailTemplate;
        }

        Database.executeBatch(new ASMonthEndNotificationBatch('General Portfolio'));

        Test.stopTest();
        
    }

    @IsTest
    static void testMonthEndNotificationBatchFocusedOption(){
        
        Test.startTest();

        System.runAs (new User(Id = UserInfo.getUserId()) ){
            EmailTemplate testEmailTemplate = new EmailTemplate();
            testEmailTemplate.isActive = true;
            testEmailTemplate.Name = 'Balance Update Notification';
            testEmailTemplate.DeveloperName = 'Balance_Update_Notification';
            testEmailTemplate.TemplateType = 'text';
            testEmailTemplate.FolderId = UserInfo.getUserId();
            insert testEmailTemplate;
        }

        Database.executeBatch(new ASMonthEndNotificationBatch('Focused Portfolio'));

        Test.stopTest();
        
    }

    @IsTest
    static void testMonthEndNotificationBatchBothOption(){
        
        Test.startTest();

        System.runAs (new User(Id = UserInfo.getUserId()) ){
            EmailTemplate testEmailTemplate = new EmailTemplate();
            testEmailTemplate.isActive = true;
            testEmailTemplate.Name = 'Balance Update Notification';
            testEmailTemplate.DeveloperName = 'Balance_Update_Notification';
            testEmailTemplate.TemplateType = 'text';
            testEmailTemplate.FolderId = UserInfo.getUserId();
            insert testEmailTemplate;
        }

        Database.executeBatch(new ASMonthEndNotificationBatch('Both'));

        Test.stopTest();
        
    }
}