@isTest
public class ASAccountSummaryCTRL_Test {
    @testsetup
    static void createRecords(){
        createUserWithRole();     
    }
    
    private static User createUserWithRole() {
        
        UserRole adminRole = new UserRole(DeveloperName = 'TestRole', Name = 'Test Role');
        insert adminRole;
        
        Profile adminprofile = [SELECT Id,name from Profile WHERE Name = 'System Administrator' LIMIT 1];
        
        User adminUser = new User(Alias = 'Testrole', 
                                  Email='test' + math.random() + '@test.com', 
                                  UserRoleId = adminRole.Id, 
                                  EmailEncodingKey='UTF-8',
                                  LastName='TestRole-Last', 
                                  LanguageLocaleKey='en_US', 
                                  LocaleSidKey='en_US',
                                  ProfileId = adminprofile.Id, 
                                  TimeZoneSidKey = 'Australia/Sydney', 
                                  UserName = 'test_' + math.random() + '@test.com',
                                  CompanyName = 'Test Australian Philanthropic Services'); //added CompanyName since this is a required in lookup filter for Account Owner SUP - 4316);
        
        system.runAs(adminUser){
            createPartnerUser();
        }
        
        return adminUser;
    }
    
    private static User createPartnerUser() {
        Profile p = [Select ID, Name from Profile Where Name = 'Customer Community Plus Login User (Custom)'];
        RecordType rType = [SELECT Id FROM RecordType WHERE DeveloperName = 'APS_Foundation_Sub_Fund'];
        
        Account a = New Account(Name = 'TestPortalAccount', RecordTypeId = rType.Id);
        insert a;
        
        Contact c = New Contact( FirstName = 'Portal', LastName = 'Test', AccountID = a.id, Email = 'test' + math.random() + '@test.com' );
        insert c;
        
        system.debug('profile' + c);
        
        user u = New User(
            UserName = 'test_' + math.random() + '@test.com',
            FirstName = 'Test-First',
            LastName = 'Test-Last',
            Alias = 'test',
            email = 'test' + math.random() + '@test.com',
            CommunityNickName = string.valueOf(math.random()).substring(0,6),
            ProfileID = p.id,
            TimeZoneSidKey = 'Australia/Sydney', 
            LocaleSidKey = 'en_US', 
            EmailEncodingKey = 'UTF-8', 
            LanguageLocaleKey = 'en_US',
            ContactID = c.id);
        
        insert u;
        
        return u;
        
    }
    
     @isTest static void testgetAccountRecord() {
        	User portalUser = [Select Id from User where LastName = 'Test-Last'];
        
        	system.runAs(portalUser){
                Account getUserAccount = ASAccountSummaryCTRL.getAccountRecord();
                // Perform some testing
                System.assert( getUserAccount != null, 'getAccountRecord method is empty' );
            }
    }
    
}