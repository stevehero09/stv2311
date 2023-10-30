@isTest
public with sharing class ASGenerateATSControllerTest {
    /**
    * @description setup - test data setup method
    */
    @testSetup
    public static void setup(){
        List<Account> testAccounts = new List<Account>();

        Account a = new Account();
        a.Name = 'ABC Company, Inc.';
        testAccounts.add(a);

        Account acct = new Account();
        acct.Name = 'XYZ Company, Inc.';
        testAccounts.add(acct);

        insert testAccounts;
    }
    /**
    * @description testMethod1 - Test Happy Path of code
    */
    public static testMethod void testMethod1() {
        List<sObject> accts = (List<Account>)[Select Id From Account];
        System.debug(accts);
        ApexPages.StandardSetController ssc = new ApexPages.StandardSetController(accts);
        ssc.setSelected(accts);
        ASGenerateATSController cn = new ASGenerateATSController(ssc);
        cn.generateATS();
        Test.startTest();
        PageReference pr = cn.generateATS();
        String fieldName = pr.getParameters().get('UrlFieldName');
        System.assertEquals('Generate_Annual_Tax_Statements__c',fieldName, 'The UrlFieldName parameter is not set' );
        Test.stopTest();
    }  
}