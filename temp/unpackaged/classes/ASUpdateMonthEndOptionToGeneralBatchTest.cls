/** 
* @description       : Test class for batch ASUpdateMonthEndOptionToGeneralBatch
* @author            : Aine A. Legaspi
* @group             : 
* @last modified on  : 03-06-2022
* @last modified by  :  
* Modifications Log 
* Ver   Date         Author                 Modification
**/

@isTest
public class ASUpdateMonthEndOptionToGeneralBatchTest {

    @testSetup
    static void setup(){
      
     //create Month End record
     AS_Month_End__c tesMonth = new AS_Month_End__c();
     tesMonth.Name = 'Month End May 2022';
     tesMonth.Effective_Date__c = Date.Today();
   	 tesMonth.Total_Valuation__c = 1200.00;
     tesMonth.AS_Investment_Option__c = NULL;
     insert tesMonth;   
     
     //update AS_Investment_Option__c
     tesMonth.AS_Investment_Option__c = 'General Portfolio';   
    }
        
    @isTest
    static void testGetMonthEndOption(){
        
        Test.startTest();
        
        ASUpdateMonthEndOptionToGeneralBatch batch = new ASUpdateMonthEndOptionToGeneralBatch();
        Database.executeBatch(batch);
        
        Test.stopTest();
    }
     
}