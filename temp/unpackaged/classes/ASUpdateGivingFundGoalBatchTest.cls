/**
 * Created by Liezel Dela Peña on June 08, 2022
 * This tests the ASUpdateGivingFundGoalBatch class
 */
@isTest
public with sharing class ASUpdateGivingFundGoalBatchTest {

    @testSetup static void setup() {
            
        Id orgRT = Schema.SObjectType.Account.getRecordTypeInfosByName().get('APS Foundation Giving Fund').getRecordTypeId();
        Id orgRT2 = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Non - Profits').getRecordTypeId();
        Id donationRT = Schema.SObjectType.AS_Transaction__c.getRecordTypeInfosByName().get('Donation').getRecordTypeId();
        Id giftRT = Schema.SObjectType.AS_Transaction__c.getRecordTypeInfosByName().get('Gift').getRecordTypeId();
        Id adjustmentRT = Schema.SObjectType.AS_Transaction__c.getRecordTypeInfosByName().get('Adjustment').getRecordTypeId();

        List<Account> accountList = new List<Account>();
        Account acc1 = new Account(
            RecordTypeId = orgRT,
            Name = 'Test Giving Fund 1',
            Balance__c = 20000000,
            Status__c = 'Active',
            AS_Previous_Month_End_Balance__c = 2000000000, 
            Investment_Portfolio__c = 'General Portfolio'
        );
        accountList.add(acc1);
        Account acc2 = new Account(
            RecordTypeId = orgRT,
            Name = 'Test Giving Fund 2',
            Balance__c = 25000000,
            Status__c = 'Active',
            AS_Previous_Month_End_Balance__c = 250000000, 
            Investment_Portfolio__c = 'General Portfolio'
        );
        accountList.add(acc2);
        
        Account acc3 = new Account(
            RecordTypeId = orgRT,
            Name = 'Test Giving Fund 3',
            Balance__c = 25000000,
            Status__c = 'Active',
            AS_Previous_Month_End_Balance__c = 250000000, 
            Investment_Portfolio__c = 'Focused Portfolio'
        );
        accountList.add(acc3);
        
        Account acc4 = new Account(
            RecordTypeId = orgRT,
            Name = 'Test Giving Fund 4',
            Balance__c = 20000000,
            Status__c = 'Active',
            AS_Previous_Month_End_Balance__c = 2000000000, 
            Investment_Portfolio__c = 'Focused Portfolio'
        );
        accountList.add(acc4);
        
        Account acc5 = new Account(
            RecordTypeId = orgRT,
            Name = 'Test Giving Fund 5',
            Balance__c = 20000000,
            Status__c = 'Active',
            AS_Previous_Month_End_Balance__c = 2000000000,
            Investment_Portfolio__c = 'Focused Portfolio'
        );
        accountList.add(acc5);
        insert accountList;

        List<AS_Month_End__c> monthEndList = new List<AS_Month_End__c>();
        AS_Month_End__c monthEnd1 = new AS_Month_End__c(
            Name = 'Month End name Test',
            Effective_Date__c = date.Today(),
            Total_Valuation__c = 10000000, 
            AS_Investment_Option__c = 'General Portfolio',
            archived__c = FALSE
        );
        monthEndList.add(monthEnd1);

        AS_Month_End__c monthEnd2 = new AS_Month_End__c(
            Name = 'Month End name Test',
            Effective_Date__c = date.Today(),
            Total_Valuation__c = 10000000, 
            AS_Investment_Option__c = 'Focused Portfolio',
            archived__c = FALSE
        );
        monthEndList.add(monthEnd2);
        insert monthEndList;


        List<AS_Statement_Line_Item__c> lineItemList = new List<AS_Statement_Line_Item__c>();
        AS_Statement_Line_Item__c lineItem1 = new AS_Statement_Line_Item__c(
            AS_Type__c = 'Gift',
            AS_Amount__c = 10,
            AS_Investment_Option__c = 'General Portfolio',
            AS_Month_End__c = monthEnd1.Id,
            AS_Fund__c = acc1.Id
        );
        lineItemList.add(lineItem1);
        
        AS_Statement_Line_Item__c lineItem2 = new AS_Statement_Line_Item__c(
            AS_Type__c = 'Gift',
            AS_Amount__c = 10,
            AS_Investment_Option__c = 'General Portfolio',
            AS_Month_End__c = monthEnd1.Id,
            AS_Fund__c = acc2.Id
        );
        lineItemList.add(lineItem2);
        
        AS_Statement_Line_Item__c lineItem3 = new AS_Statement_Line_Item__c(
            AS_Type__c = 'Gift',
            AS_Amount__c = 10,
            AS_Investment_Option__c = 'Focused Portfolio',
            AS_Month_End__c = monthEnd2.Id,
            AS_Fund__c = acc3.Id
        );
        lineItemList.add(lineItem3);

        AS_Statement_Line_Item__c lineItem4 = new AS_Statement_Line_Item__c(
            AS_Type__c = 'Gift',
            AS_Amount__c = 10,
            AS_Investment_Option__c = 'Focused Portfolio',
            AS_Month_End__c = monthEnd2.Id,
            AS_Fund__c = acc4.Id
        );
        lineItemList.add(lineItem4);
        
        AS_Statement_Line_Item__c lineItem5 = new AS_Statement_Line_Item__c(
            AS_Type__c = 'Gift',
            AS_Amount__c = 10,
            AS_Investment_Option__c = 'General Portfolio',
            AS_Month_End__c = monthEnd1.Id,
            AS_Fund__c = acc1.Id
        );
        lineItemList.add(lineItem5);
        insert lineItemList;
    }

    @isTest
    static void testUpdateGivingBtach(){
        List<Id> accIds = new List<Id>();

        List<Account> accounts = [SELECT Id, Name FROM Account WHERE Name = 'Test Giving Fund 1' OR Name = 'Test Giving Fund 2' OR Name = 'Test Giving Fund 5'];
        System.debug(accounts);

        for(Account acc : accounts) {
            accIds.add(acc.Id);
        }

        Test.startTest();
        ASUpdateGivingFundGoalBatch batch = new ASUpdateGivingFundGoalBatch(accIds);
        Database.executeBatch(batch);
        Test.stopTest();

    }
}