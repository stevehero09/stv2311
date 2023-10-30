/**
 * Test class for the trigger class ASCorrespondenceNotification and handler class ASCorrenspondenceNotificationHandler
 * 
 * @author Von Sienard Vibar
 * @LastUpdated September 30, 2020
 */
@isTest (SeeAllData = true)
public class ASCorrespondenceNotification_Test {

    /**
     * Test method for testing the Correspondence Notification
     */
    @IsTest
    private static void testCorrespondanceNotification(){

        Id apsFoundationGivingFundRT = Schema.SObjectType.Account.getRecordTypeInfosByName().get('APS Foundation Giving Fund').getRecordTypeId();

        Account acc = new Account();
        acc.Name = 'Test Organisation';
        insert acc;

        ContentVersion version = new ContentVersion();
        version.Title = 'Test';
        version.PathOnClient = 'test.jpg';
        version.VersionData = Blob.valueOf('Test Content');
        version.IsMajorVersion = true;
        insert version;
        
        Test.startTest();

        version.Related_Fund__c = acc.Id;
        update version;

        Test.stopTest();
        
    }
}