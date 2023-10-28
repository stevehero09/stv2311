/**
 * Created by Liezel Dela Peña on June 08, 2022
 * This tests the ASUpdateMinorBalancesController class
 */
@isTest
public with sharing class ASUpdateMinorBalancesControllerTest {
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
        insert lineItemList;
    }

    @isTest
    static void test1(){
        List<Id> batchIds = new List<Id>();

        Test.startTest();
        
        ASUpdateMinorBalancesController.executeBatchJob();
        //ASUpdateMinorBalancesController.executeBatchJob(batchIds);
        
        Test.stopTest();


    }

    
}