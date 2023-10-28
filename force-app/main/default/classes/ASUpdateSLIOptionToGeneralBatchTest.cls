/** 
* @description       : Test class for batch ASUpdateSLIOptionToGeneralBatch
* @author            : Aine A. Legaspi
* @group             : 
* @last modified on  : 03-06-2022
* @last modified by  :  
* Modifications Log 
* Ver   Date         Author                 Modification
**/

@isTest
public class ASUpdateSLIOptionToGeneralBatchTest {

    @testSetup
    static void setup(){
        
        //create record for Month end object
        AS_Month_End__c tesMonth2 = new AS_Month_End__c();
        tesMonth2.Name = 'Month End May 2022';
        tesMonth2.Effective_Date__c = Date.Today();
        tesMonth2.Total_Valuation__c = 1200.00;
        tesMonth2.AS_Investment_Option__c = 'GENERAL Portfolio';
        insert tesMonth2;   
        
        
        //create record for Statement line Item object
        AS_Statement_Line_Item__c testStatement = new AS_Statement_Line_Item__c();
        testStatement.AS_Type__c = 'Donation';
        testStatement.AS_Month_End__c = tesMonth2.Id;
        testStatement.AS_Investment_Option__c = NULL;
        insert testStatement;
        
       // testStatement.AS_Investment_Option__c = 'General Portfolio';
        //update testStatement;
    }
    
    @isTest
    static void getUpdateSLIOption(){
        
        List<AS_Month_End__c> month = [SELECT Id, Name,AS_Investment_Option__c  FROM AS_Month_End__c];
        System.debug('month =' + month);
        
        Test.startTest();
        
        ASUpdateSLIOptionToGeneralBatch btch = new ASUpdateSLIOptionToGeneralBatch();
        Database.executeBatch(btch);
        
        Test.stopTest();
    }
}