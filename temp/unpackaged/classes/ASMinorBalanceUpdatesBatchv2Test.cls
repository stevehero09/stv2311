/**
 * Created by Liezel Dela Peña on June 16, 2022
 * This tests the ASMinorBalanceUpdatesBatchv2 class
 */
@isTest
public with sharing class ASMinorBalanceUpdatesBatchv2Test {

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
            Investment_Portfolio__c = 'General Portfolio',
            AS_June_30_Balance__c = 10000
        );
        accountList.add(acc1);
        Account acc2 = new Account(
            RecordTypeId = orgRT,
            Name = 'Test Giving Fund 2',
            Balance__c = 25000000,
            Status__c = 'Active',
            AS_Previous_Month_End_Balance__c = 250000000, 
            Investment_Portfolio__c = 'Focused Portfolio'
        );
        accountList.add(acc2);

        Account acc3 = new Account(
            RecordTypeId = orgRT,
            Name = 'Test Charity',
            Balance__c = 25000000,
            Status__c = 'Active',
            AS_Previous_Month_End_Balance__c = 250000000, 
            Investment_Portfolio__c = 'General Portfolio'
        );
        accountList.add(acc3);
        insert accountList;


        List<AS_Month_End__c> monthEndList = new List<AS_Month_End__c>();
        AS_Month_End__c monthEnd1= new AS_Month_End__c(
            Name = 'monthEnd',
            Effective_Date__c = date.newInstance(2022, 7, 7),
            Total_Valuation__c = 10000000, 
            AS_Investment_Option__c = 'General Portfolio'
        );
        monthEndList.add(monthEnd1);

        AS_Month_End__c monthEnd2 = new AS_Month_End__c(
            Name = 'monthEndPFY',
            Effective_Date__c =  date.newInstance(2022, 6, 30),
            Total_Valuation__c = 10000000, 
            AS_Investment_Option__c = 'Focused Portfolio'
        );
        monthEndList.add(monthEnd2);

        AS_Month_End__c monthEnd3 = new AS_Month_End__c(
            Name = 'monthEndYTD',
            Effective_Date__c = Date.newInstance(2021, 6, 30),
            Total_Valuation__c = 10000000, 
            AS_Investment_Option__c = 'Focused Portfolio'
        );
        monthEndList.add(monthEnd3);

        insert monthEndList;

        //Create SLI
        List<AS_Statement_Line_Item__c> lineItemList = new List<AS_Statement_Line_Item__c>();

        AS_Statement_Line_Item__c lineItem1 = new AS_Statement_Line_Item__c(
            AS_Type__c = 'Gift',
            AS_Amount__c = 10,
            AS_Balance__c = 2000,
            AS_Investment_Option__c = 'General Portfolio',
            AS_Month_End__c = monthEnd1.Id,
            AS_Fund__c = acc1.Id
            
        );
        lineItemList.add(lineItem1);
        
        AS_Statement_Line_Item__c lineItem2 = new AS_Statement_Line_Item__c(
            AS_Type__c = 'Donation',
            AS_Amount__c = 10,
            AS_Balance__c = 2000,
            AS_Investment_Option__c = 'General Portfolio',
            AS_Month_End__c = monthEnd1.Id,
            AS_Fund__c = acc1.Id
        );
        lineItemList.add(lineItem2);
        
        AS_Statement_Line_Item__c lineItem3 = new AS_Statement_Line_Item__c(
            AS_Type__c = 'Adjustment',
            AS_Amount__c = 10,
            AS_Balance__c = 2000,
            AS_Investment_Option__c = 'General Portfolio',
            AS_Month_End__c = monthEnd1.Id,
            AS_Fund__c = acc1.Id
        );
        lineItemList.add(lineItem3);

        AS_Statement_Line_Item__c lineItem4 = new AS_Statement_Line_Item__c(
            AS_Type__c = 'Investment Return',
            AS_Amount__c = 10,
            AS_Balance__c = 2000,
            AS_Investment_Option__c = 'General Portfolio',
            AS_Month_End__c = monthEnd1.Id,
            AS_Fund__c = acc1.Id
        );
        lineItemList.add(lineItem4);
        
        AS_Statement_Line_Item__c lineItem5 = new AS_Statement_Line_Item__c(
            AS_Type__c = 'Gift',
            AS_Amount__c = 10,
            AS_Balance__c = 2000,
            AS_Investment_Option__c = 'General Portfolio',
            AS_Month_End__c = monthEnd1.Id,
            AS_Fund__c = acc1.Id
        );
        lineItemList.add(lineItem5);
        
        AS_Statement_Line_Item__c lineItem6 = new AS_Statement_Line_Item__c(
            AS_Type__c = 'Donation',
            AS_Amount__c = 10,
            AS_Balance__c = 2000,
            AS_Investment_Option__c = 'General Portfolio',
            AS_Month_End__c = monthEnd1.Id,
            AS_Fund__c = acc1.Id
        );
        lineItemList.add(lineItem6);
        
        AS_Statement_Line_Item__c lineItem7 = new AS_Statement_Line_Item__c(
            AS_Type__c = 'Adjustment',
            AS_Amount__c = 10,
            AS_Balance__c = 2000,
            AS_Investment_Option__c = 'General Portfolio',
            AS_Month_End__c = monthEnd1.Id,
            AS_Fund__c = acc1.Id
        );
        lineItemList.add(lineItem7);

        AS_Statement_Line_Item__c lineItem8 = new AS_Statement_Line_Item__c(
            AS_Type__c = 'Investment Return',
            AS_Amount__c = 10,
            AS_Investment_Option__c = 'General Portfolio',
            AS_Month_End__c = monthEnd1.Id,
            AS_Fund__c = acc1.Id
        );
        lineItemList.add(lineItem8);


        
        AS_Statement_Line_Item__c monthEnd21 = new AS_Statement_Line_Item__c(
            AS_Type__c = 'Gift',
            AS_Amount__c = 10,
            AS_Balance__c = 2000,
            AS_Investment_Option__c = 'General Portfolio',
            AS_Month_End__c = monthEnd2.Id,
            AS_Fund__c = acc1.Id
        );
        lineItemList.add(monthEnd21);

        AS_Statement_Line_Item__c monthEnd22 = new AS_Statement_Line_Item__c(
            AS_Type__c = 'Donation',
            AS_Amount__c = 10,
            AS_Balance__c = 2000,
            AS_Investment_Option__c = 'General Portfolio',
            AS_Month_End__c = monthEnd2.Id,
            AS_Fund__c = acc1.Id
        );
        lineItemList.add(monthEnd22);

        AS_Statement_Line_Item__c monthEnd23 = new AS_Statement_Line_Item__c(
            AS_Type__c = 'Adjustment',
            AS_Amount__c = 10,
            AS_Balance__c = 2000,
            AS_Investment_Option__c = 'General Portfolio',
            AS_Month_End__c = monthEnd2.Id,
            AS_Fund__c = acc1.Id
        );
        lineItemList.add(monthEnd23);

        AS_Statement_Line_Item__c monthEnd24 = new AS_Statement_Line_Item__c(
            AS_Type__c = 'Gift',
            AS_Amount__c = 10,
            AS_Balance__c = 2000,
            AS_Investment_Option__c = 'General Portfolio',
            AS_Month_End__c = monthEnd2.Id,
            AS_Fund__c = acc1.Id
        );
        lineItemList.add(monthEnd24);

        AS_Statement_Line_Item__c monthEnd25 = new AS_Statement_Line_Item__c(
            AS_Type__c = 'Donation',
            AS_Amount__c = 10,
            AS_Balance__c = 2000,
            AS_Investment_Option__c = 'General Portfolio',
            AS_Month_End__c = monthEnd2.Id,
            AS_Fund__c = acc1.Id
        );
        lineItemList.add(monthEnd25);

        AS_Statement_Line_Item__c monthEnd26 = new AS_Statement_Line_Item__c(
            AS_Type__c = 'Adjustment',
            AS_Amount__c = 10,
            AS_Balance__c = 2000,
            AS_Investment_Option__c = 'General Portfolio',
            AS_Month_End__c = monthEnd2.Id,
            AS_Fund__c = acc1.Id
        );
        lineItemList.add(monthEnd26);

        AS_Statement_Line_Item__c monthEnd27 = new AS_Statement_Line_Item__c(
            AS_Type__c = 'Investment Return',
            AS_Amount__c = 10,
            AS_Balance__c = 2000,
            AS_Investment_Option__c = 'General Portfolio',
            AS_Month_End__c = monthEnd2.Id,
            AS_Fund__c = acc1.Id
        );
        lineItemList.add(monthEnd27);

        AS_Statement_Line_Item__c monthEnd28 = new AS_Statement_Line_Item__c(
            AS_Type__c = 'Investment Return',
            AS_Amount__c = 10,
            AS_Balance__c = 2000,
            AS_Investment_Option__c = 'General Portfolio',
            AS_Month_End__c = monthEnd2.Id,
            AS_Fund__c = acc1.Id
        );
        lineItemList.add(monthEnd28);

        AS_Statement_Line_Item__c monthEnd31 = new AS_Statement_Line_Item__c(
            AS_Type__c = 'Investment Return',
            AS_Amount__c = 10,
            AS_Balance__c = 2000,
            AS_Investment_Option__c = 'General Portfolio',
            AS_Month_End__c = monthEnd3.Id,
            AS_Fund__c = acc1.Id
        );
        lineItemList.add(monthEnd31);
        insert lineItemList;

        //Create Transactions
        List<AS_Transaction__c> transactionList = new List<AS_Transaction__c>();
        AS_Transaction__c trans1 = new AS_Transaction__c(
            RecordTypeId = donationRT,
            AS_Fund__c = acc1.Id,
            AS_Amount__c = 500000,
            AS_Status__c = 'Reconciled',
            AS_Date__c = date.Today(),
            AS_Statement_Line_Item__c = null
        );
        transactionList.add(trans1);

        AS_Transaction__c trans2 = new AS_Transaction__c(
            RecordTypeId = giftRT,
            AS_Fund__c = acc1.Id,
            AS_Charity__c = acc3.Id,
            AS_Amount__c = 100000,
            AS_Status__c = 'Approved',
            AS_Date__c = date.Today(),
            AS_Statement_Line_Item__c = null
        );
        transactionList.add(trans2);

        AS_Transaction__c trans3 = new AS_Transaction__c(
            RecordTypeId = donationRT,
            AS_Fund__c = acc1.Id,
            AS_Amount__c = 500000,
            AS_Status__c = 'Reconciled',
            AS_Date__c = date.Today(),
            AS_Statement_Line_Item__c = null
        );
        transactionList.add(trans3);

        AS_Transaction__c trans4 = new AS_Transaction__c(
            RecordTypeId = adjustmentRT,
            AS_Fund__c = acc2.Id,
            AS_Amount__c = -1000,
            AS_Status__c = 'Approved',
            AS_Date__c = date.Today()
        );
        transactionList.add(trans4);
        insert transactionList;

    }

    @isTest
    static void test1(){
        List<Id> accIds = new List<Id>();

        List<Account> accounts = [SELECT Id, Name, Investment_Portfolio__c, AS_June_30_Balance__c FROM Account WHERE Name = 'Test Giving Fund 1'];
        System.debug(accounts);
        Account acc = accounts[0];
        String investmentOption = acc.Investment_Portfolio__c;

        Test.startTest();
        ASMinorBalanceUpdatesBatchv2 batch = new ASMinorBalanceUpdatesBatchv2(investmentOption);
        Database.executeBatch(batch);
        
        Test.stopTest();


    }
    
     @isTest
    static void test2(){
        List<Id> accIds = new List<Id>();

        
        List<Account> accounts2 = [SELECT Id, Name, Investment_Portfolio__c, AS_June_30_Balance__c FROM Account WHERE Name = 'Test Giving Fund 2'];
        System.debug(accounts2);
        Account acc2 = accounts2[0];
        String investmentOption2 = acc2.Investment_Portfolio__c;
        
        Test.startTest();
        ASMinorBalanceUpdatesBatchv2 batch2 = new ASMinorBalanceUpdatesBatchv2(investmentOption2);
        Database.executeBatch(batch2);
        Test.stopTest();


    }
}