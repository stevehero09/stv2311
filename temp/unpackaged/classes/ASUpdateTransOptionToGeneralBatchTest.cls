/** 
* @description       : Test class for batch ASUpdateTransOptionToGeneralBatch
* @author            : Aine A. Legaspi
* @group             : 
* @last modified on  : 03-06-2022
* @last modified by  :  
* Modifications Log 
* Ver   Date         Author                 Modification
**/

@isTest
public class ASUpdateTransOptionToGeneralBatchTest {

    @testsetup
    static void setup(){
        
        //create record for Account object
        Account testAcc = new  Account();
        testAcc.Name = 'Test Fund Holder';
        testAcc.Status__c = 'Active';
        //testAcc.AS_Investment_Option__c = ' Focused Portfolio';
        testAcc.Investment_Portfolio__c = NULL;
        testAcc.AS_Previous_FY_Option__c = 'Focused Portfolio';
        insert testAcc;
        
              
        //create record for Transaction object
        AS_Transaction__c testTrans = new AS_Transaction__c();
        testTrans.AS_Status__c = 'Draft';
        testTrans.AS_Investment_Option__c = NULL;
        testTrans.AS_Fund__c = testAcc.Id;
        insert testTrans; 
        
                 
    }
    @isTest
    static void getUpdateTransOption(){
        
        Test.startTest();
        
        ASUpdateTransOptionToGeneralBatch batch = new ASUpdateTransOptionToGeneralBatch();
        Database.executeBatch(batch);
        
        Test.stopTest();
    }
         
      
    
}