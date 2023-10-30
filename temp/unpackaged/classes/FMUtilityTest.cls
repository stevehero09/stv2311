/*
 * Title	: FMUtilityTest
 * Author	: SM
 * Date		: 20230105
 * Descr	: Test class for FMUtility
 */
 
@IsTest
public class FMUtilityTest 
{
    static Foundation_Meeting__c fm1 = new Foundation_Meeting__c();
   /* static Foundation_Meeting__c fm2 = new Foundation_Meeting__c();
    static Foundation_Meeting__c fm3 = new Foundation_Meeting__c();
    static Foundation_Meeting__c fm4 = new Foundation_Meeting__c();
    static Foundation_Meeting__c fm5 = new Foundation_Meeting__c();
    static Foundation_Meeting__c fm6 = new Foundation_Meeting__c();
    static Foundation_Meeting__c fm7 = new Foundation_Meeting__c();        
    static Foundation_Meeting__c fm8 = new Foundation_Meeting__c();
    */
    static List<Foundation_Meeting__c> fms = new List<Foundation_Meeting__c>();
    
    @testSetup static void setup() 
    {
        Account acc1 	= new Account();
        acc1.Name 		= 'Alfred E. Neumann Foundation, The';
        insert acc1;
    } //end setup
    
    static testMethod void createFoundationMeeting() 
    {
        Account acc = [ SELECT id, Name 
                        FROM Account 
                        WHERE Name = 'Alfred E. Neumann Foundation, The' 
                        LIMIT 1 ];

        //DATA FOR TESTING EXPECTED INPUTS
        fm1.Paper_Author__c 		= UserInfo.getUserId();
        fm1.Organisation_Name__c 	= acc.Id;
        fm1.Meeting_type__c 		= 'Annual';
        fm1.Date_of_Meeting__c 		= System.today();
        fms.add(fm1);
    /*               
        fm2.Paper_Author__c 		= UserInfo.getUserId();
        fm2.Organisation_Name__c 	= acc.Id;
        fm2.Meeting_type__c 		= 'Initial Trustee';
        fm2.Date_of_Meeting__c 		= System.today();
        fms.add(fm2);
        
        fm3.Paper_Author__c 		= UserInfo.getUserId();
        fm3.Organisation_Name__c 	= acc.Id;
        fm3.Meeting_type__c 		= 'ITM/AM Mash';
        fm3.Date_of_Meeting__c 		= System.today();
        fms.add(fm3);
        
        fm4.Paper_Author__c 		= UserInfo.getUserId();
        fm4.Organisation_Name__c 	= acc.Id;
        fm4.Meeting_type__c 		= 'Mid Year Meeting';
        fm4.Date_of_Meeting__c 		= System.today(); 
        fms.add(fm4);
        
        fm5.Paper_Author__c 		= UserInfo.getUserId();
        fm5.Organisation_Name__c 	= acc.Id;
        fm5.Meeting_type__c 		= 'Wind Up';
        fm5.Date_of_Meeting__c 		= System.today();
		fms.add(fm5);
        
        fm6.Paper_Author__c 		= UserInfo.getUserId();
        fm6.Organisation_Name__c 	= acc.Id;
        fm6.Meeting_type__c 		= 'Exiting';
        fm6.Date_of_Meeting__c 		= System.today();
		fms.add(fm6);
        
        //DATA FOR TESTING UNEXPECTED LEGAL INPUTS
        fm7.Paper_Author__c 		= UserInfo.getUserId();
        fm7.Organisation_Name__c 	= acc.Id;
        fm7.Meeting_type__c 		= 'Mid Year Review';
        fm7.Date_of_Meeting__c 		= System.today();
        fms.add(fm7);
        
        fm8.Paper_Author__c 		= UserInfo.getUserId();
        fm8.Organisation_Name__c 	= acc.Id;
        fm8.Meeting_type__c 		= 'Giving Conversation';
        fm8.Date_of_Meeting__c 		= System.today();
        fms.add(fm8);
       */ 
        Test.StartTest(); 	// Gathers any asyncronous methods to be called
        insert(fms); 		   
        Test.StopTest(); 	// Runs asyncronous methods syncronously, to allow system.assert to function properly

        Case parentCase1 = [ SELECT id, Case_FM_Lookup__c, Category__c FROM Case WHERE Case_FM_Lookup__c = :fm1.id LIMIT 1]; 
        /*
        Case parentCase2 = [ SELECT id, Case_FM_Lookup__c, Category__c FROM Case WHERE Case_FM_Lookup__c = :fm2.id LIMIT 1];
        Case parentCase3 = [ SELECT id, Case_FM_Lookup__c, Category__c FROM Case WHERE Case_FM_Lookup__c = :fm3.id LIMIT 1];
        Case parentCase4 = [ SELECT id, Case_FM_Lookup__c, Category__c FROM Case WHERE Case_FM_Lookup__c = :fm4.id LIMIT 1]; 
        Case parentCase5 = [ SELECT id, Case_FM_Lookup__c, Category__c FROM Case WHERE Case_FM_Lookup__c = :fm5.id LIMIT 1];
        Case parentCase6 = [ SELECT id, Case_FM_Lookup__c, Category__c FROM Case WHERE Case_FM_Lookup__c = :fm6.id LIMIT 1];
*/
        system.Assert(parentCase1.Category__c == 'Foundation Meeting - AM');

/*
        system.Assert(parentCase2.Category__c == 'Foundation Meeting - ITM');
        system.Assert(parentCase3.Category__c == 'Foundation Meeting - MASH');
        system.Assert(parentCase4.Category__c == 'Foundation Meeting - MYM');
        system.Assert(parentCase5.Category__c == 'Foundation Meeting - Wind Up');
        System.Assert(parentCase6.Category__c == 'Foundation Meeting - Exiting');
*/
    }// end createFoundationMeeting

     static testMethod void UpdateFoundationMeetingDate() 
     {
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
     } //End UpdateFoundationMeetingDate */
} //End FMUtilityTest