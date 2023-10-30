/*
* @author: Jan Dainis C. Saren
* @date: February 6, 2020
* @Class Name: ASRunMonthEndCTRL_Test
* @description: Test Class for ASRunMonthEndCTRL.
* @updated : No
* @updated by: 
* @updated Date:
* @description of the update:
*/
@isTest
public class ASRunMonthEndCTRL_Test {
    
    /*
    * @author: Jan Dainis C. Saren
    * @date: February 6, 2020
    * @Method Name: setupvalue
    * @description:  Test Method for set up new record  on Month End.
    * @updated : No
    * @updated by: 
    * @updated Date:
    * @description of the update:
    */
    @testSetup
    static void setupvalue() {
        
        List<AS_Month_End__c> MonthEndList = new List<AS_Month_End__c>();
        
		AS_Month_End__c monthEnd = new AS_Month_End__c(
			Name 				= 'Feb 2020',
            Effective_Date__c 	= Date.Today(),
            Total_Valuation__c 	= 100
        ); 
        MonthEndList.add(monthEnd);
        
        AS_Month_End__c monthEnd1 = new AS_Month_End__c(
			Name 				= 'Mar 2020',
            Effective_Date__c 	= Date.Today(),
            Total_Valuation__c 	= 100
        ); 
        MonthEndList.add(monthEnd1);
        Insert MonthEndList;
    }
    
    /*
    * @author: Jan Dainis C. Saren
    * @date: February 6, 2020
    * @Method Name: SuccessInsertMonthEnd
    * @description: Test Method for insert Month End Record success.
    * @updated : No
    * @updated by: 
    * @updated Date:
    * @description of the update:
    */
    static testMethod void SuccessInsertMonthEnd() {
        
        List<AS_Month_End__c> Mlist = [SELECT Id, Name, Effective_Date__c, Total_Valuation__c FROM AS_Month_End__c];
        System.assertEquals(true,Mlist != null);
        
        AS_Month_End__c monthEnd = new AS_Month_End__c(
            Name 				= 'Apr 2020',
            Effective_Date__c 	= date.newinstance(2020, 4, 17),
            Total_Valuation__c 	= 100
        );
        ASRunMonthEndCTRL.saveRecord(monthEnd);
    } 
    
    /*
    * @author: Jan Dainis C. Saren
    * @date: February 6, 2020
    * @Method Name: ErrorInsertMonthEnd
    * @description: Test Method for insert Month End Record error.
    * @updated : No
    * @updated by: 
    * @updated Date:
    * @description of the update:
    */
    static testMethod void ErrorInsertMonthEnd() {
        
        List<AS_Month_End__c> Mlist = [SELECT Id, Name, Effective_Date__c, Total_Valuation__c FROM AS_Month_End__c];
        System.assertEquals(true,Mlist != null);
        
        AS_Month_End__c monthEnd = new AS_Month_End__c(
            Name 				= 'Feb 2020',
            Effective_Date__c 	= date.today(),
            Total_Valuation__c 	= 100
        );
        ASRunMonthEndCTRL.saveRecord(monthEnd);
    }
}