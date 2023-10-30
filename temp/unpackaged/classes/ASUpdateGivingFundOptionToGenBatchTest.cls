/** 
* @description       : Test class for batch ASUpdateGivingFundOptionToGeneralBatch
* @author            : Aine A. Legaspi
* @group             : 
* @last modified on  : 03-06-2022
* @last modified by  :  
* Modifications Log 
* Ver   Date         Author                 Modification
**/

@isTest
public class ASUpdateGivingFundOptionToGenBatchTest {

    @testsetup
    static void setup(){
        
        //retrieve recordtypeid that has a APS Foundation Giving Fund recordtype name 
        Id RecordTypeIdAccount= Schema.SObjectType.Account.getRecordTypeInfosByName().get('APS Foundation Giving Fund').getRecordTypeId();

        //create record for Account object
        Account testAcc = new  Account();
        testAcc.Name = ' Test Foundation Fund Holder';
        testAcc.State__c = 'Active';
        testAcc.Investment_Portfolio__c = NULL;
        testAcc.AS_Previous_FY_Option__c = NULL;
        testAcc.RecordTypeId = RecordTypeIdAccount;
        insert testAcc;
        
        //testAcc.Investment_Portfolio__c = 'GENERAL Portfolio';
        //testAcc.Investment_Portfolio__c = 'GENERAL Portfolio';
        //update testAcc;
        
       
        
        
        //set the Created Date field
        Test.setCreatedDate(testAcc.Id, DateTime.newInstance(2022, 6, 1) );
        
    }
    @isTest
    static void getUpdateGivingFundToGeneralOption(){
        
        List<Account> acc = [SELECT Id, Name,Investment_Portfolio__c  FROM Account];
        System.debug('acc =' + acc);
        
        Test.startTest();
        
         
        ASUpdateGivingFundOptionToGeneralBatch btch = new ASUpdateGivingFundOptionToGeneralBatch();
        Database.executeBatch(btch);
        
        Test.stopTest();
    }
}