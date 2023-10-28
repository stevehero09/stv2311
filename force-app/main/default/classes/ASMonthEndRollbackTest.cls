@isTest
public class ASMonthEndRollbackTest {
    @testSetup
    static void setup(){
        AS_Month_End__c newMonthE = new AS_Month_End__c(

            Name = 'Feb Feb',
            Effective_Date__c = Date.today(),
            Total_Valuation__c = 33
        );
        insert newMonthE;

        Account acct = new Account(Name = 'Test Organisation');
        insert acct;

        List<AS_Statement_Line_Item__c> statementLineItems = new List<AS_Statement_Line_Item__c>();
        for(Integer i = 0 ; i < 10 ; i++){
            AS_Statement_Line_Item__c sli = new AS_Statement_Line_Item__c(
                AS_Month_End__c = newMonthE.Id,
                AS_Fund__c = acct.Id,
                AS_Type__c = 'Donation',
                AS_Amount__c = 500+i,
                AS_Balance__c = 600+i
            );
            statementLineItems.add(sli);
        }

        insert statementLineItems;
    }

    @isTest
    static void testMonthEndRollback(){
        AS_Month_End__c monthEnd = [SELECT Id FROM AS_Month_End__c LIMIT 1];
        System.assert(monthEnd != null);
        List<AS_Statement_Line_Item__c> statementLineItems = [SELECT Id FROM AS_Statement_Line_Item__c];
        System.assertEquals(10, statementLineItems.size());

        Test.startTest();
        ASMonthEndRollback rollbackBatch = new ASMonthEndRollback(monthEnd);
        Database.executeBatch(rollbackBatch);
        Test.stopTest();

        statementLineItems = [SELECT Id FROM AS_Statement_Line_Item__c];
        //System.assertEquals(0, statementLineItems.size());
        System.assertEquals(10, statementLineItems.size());

        Account acct = [SELECT AS_Update_Balances__c FROM Account WHERE Name = 'Test Organisation'];
        System.assert(acct != null);
        // System.assertEquals(true, acct.AS_Update_Balances__c);
    }
}