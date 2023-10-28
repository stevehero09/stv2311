/**
 * Created by Mel-Goldwyn T. Samar on September 9, 2021
 * This tests the ASMonthEndBatch class
 */
@isTest
public class ASMonthEndBatchTest {
    /*
    * @author: Butch B. Enerio
    * @date: February 10, 2020
    * @Method name: setup
    * @description: testSetup method
    * @parameter(s): none
    * @return: none
    * @updated : No
    * @updated by: 
    * @updated Date:
    * @description of the update:
    */
    @testSetup static void setup() {
            
        Id orgRT = Schema.SObjectType.Account.getRecordTypeInfosByName().get('APS Foundation Giving Fund').getRecordTypeId();
        Id orgRT2 = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Non - Profits').getRecordTypeId();
        Id donationRT = Schema.SObjectType.AS_Transaction__c.getRecordTypeInfosByName().get('Donation').getRecordTypeId();
        Id giftRT = Schema.SObjectType.AS_Transaction__c.getRecordTypeInfosByName().get('Gift').getRecordTypeId();
        Id adjustmentRT = Schema.SObjectType.AS_Transaction__c.getRecordTypeInfosByName().get('Adjustment').getRecordTypeId();


        Period currentFiscalYearSettings = [
            SELECT 
                FiscalYearSettings.Name, 
                StartDate, 
                EndDate 
            FROM Period 
            WHERE 
                Type = 'Year' AND 
                StartDate <= TODAY AND 
                EndDate >= TODAY
        ];
        
        
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
            Investment_Portfolio__c = 'Focused Portfolio'
        );
        accountList.add(acc2);
        Account acc3 = new Account(
            RecordTypeId = orgRT2,
            Name = 'Test Non Profit',
            Status__c = 'Active',
            AS_Previous_Month_End_Balance__c = 300000000, 
            Investment_Portfolio__c = 'General Portfolio', 
            AS_Previous_FY_Option__c = 'General Portfolio'
        );
        accountList.add(acc3);
        Account acc4 = new Account(
            RecordTypeId = orgRT,
            Balance__c = 25000000,
            Name = 'Test Giving Fund 3',
            Status__c = 'Active',
            AS_Previous_Month_End_Balance__c = 350000000, 
            Investment_Portfolio__c = 'Focused Portfolio', 
            AS_Previous_FY_Option__c = 'General Portfolio'
        );
        accountList.add(acc4);
        insert accountList;
        
        List<Contact> contactList = new List<Contact>();
        Contact con1 = new Contact(
            FirstName = 'Test FirstName 1',
            LastName = 'Test LastName 1',
            Preferred_Name__c = 'Test Preferred 1',
            Email = 'test@email.com',
            AccountId = acc1.Id
        );
        contactList.add(con1);
        Contact con2 = new Contact(
            FirstName = 'Test FirstName 2',
            LastName = 'Test LastName 2',
            Preferred_Name__c = 'Test Preferred 2',
            Email = 'test2@email.com',
            AccountId = acc2.Id
        );
        contactList.add(con2);
        insert contactList;
        
        List<npe5__Affiliation__c> affliationList = new List<npe5__Affiliation__c>();
        npe5__Affiliation__c affliate1 = new npe5__Affiliation__c(
            Key_Contact__c = true,
            Portal_Contact__c = true,
            Position__c = 'Director',
            npe5__Organization__c = acc1.Id,
            npe5__Contact__c = con1.Id
        );
        affliationList.add(affliate1);
        npe5__Affiliation__c affliate2 = new npe5__Affiliation__c(
            Key_Contact__c = true,
            Portal_Contact__c = true,
            Position__c = 'Director',
            npe5__Organization__c = acc2.Id,
            npe5__Contact__c = con2.Id
        );
        affliationList.add(affliate2);
        insert affliationList;
        
        List<AS_Transaction__c> transactionList = new List<AS_Transaction__c>();
        AS_Transaction__c trans1 = new AS_Transaction__c(
            RecordTypeId = donationRT,
            AS_Fund__c = acc1.Id,
            Requested_By__c = con1.Id,
            AS_Amount__c = 500000,
            AS_Status__c = '',
            AS_Date__c = date.Today()
        );
        transactionList.add(trans1);
        AS_Transaction__c trans2 = new AS_Transaction__c(
            RecordTypeId = giftRT,
            AS_Fund__c = acc1.Id,
            Requested_By__c = con1.Id,
            AS_Charity__c = acc3.Id,
            AS_Amount__c = 100000,
            AS_Status__c = '',
            AS_Date__c = date.Today()
        );
        transactionList.add(trans2);
        AS_Transaction__c trans2b = new AS_Transaction__c(
            RecordTypeId = giftRT,
            AS_Fund__c = acc1.Id,
            Requested_By__c = con1.Id,
            AS_Charity__c = acc3.Id,
            AS_Amount__c = -300000,
            AS_Status__c = '',
            AS_Date__c = date.Today()
        );
        transactionList.add(trans2b);
        AS_Transaction__c trans3 = new AS_Transaction__c(
            RecordTypeId = adjustmentRT,
            AS_Fund__c = acc1.Id,
            AS_Amount__c = -1000,
            AS_Status__c = '',
            AS_Date__c = currentFiscalYearSettings.StartDate.addDays(-5)
        );
        transactionList.add(trans3);
        AS_Transaction__c trans4 = new AS_Transaction__c(
            RecordTypeId = donationRT,
            AS_Fund__c = acc2.Id,
            Requested_By__c = con2.Id,
            AS_Amount__c = 500000,
            AS_Status__c = '',
            AS_Date__c = currentFiscalYearSettings.StartDate.addDays(-5)
        );
        transactionList.add(trans4);
        AS_Transaction__c trans5 = new AS_Transaction__c(
            RecordTypeId = giftRT,
            AS_Fund__c = acc2.Id,
            Requested_By__c = con2.Id,
            AS_Charity__c = acc3.Id,
            AS_Amount__c = 100000,
            AS_Status__c = '',
            AS_Date__c = currentFiscalYearSettings.StartDate.addDays(-5)
        );
        transactionList.add(trans5);
        AS_Transaction__c trans6 = new AS_Transaction__c(
            RecordTypeId = adjustmentRT,
            AS_Fund__c = acc2.Id,
            AS_Amount__c = -1000,
            AS_Status__c = '',
            AS_Date__c = currentFiscalYearSettings.StartDate.addDays(-5)
        );
        transactionList.add(trans6);
        
        
        
        AS_Transaction__c trans7 = new AS_Transaction__c(
            RecordTypeId = adjustmentRT,
            AS_Fund__c = acc2.Id,
            AS_Amount__c = -1000,
            AS_Status__c = '',
            AS_Date__c = date.Today()
        );
        transactionList.add(trans7);
        
        AS_Transaction__c trans8 = new AS_Transaction__c(
            RecordTypeId = donationRT,
            AS_Fund__c = acc2.Id,
            AS_Amount__c = -1000,
            AS_Status__c = '',
            AS_Date__c = date.Today()
        );
        transactionList.add(trans8);
        
        AS_Transaction__c trans9 = new AS_Transaction__c(
            RecordTypeId = giftRT,
            AS_Fund__c = acc2.Id,
            AS_Amount__c = -1000,
            AS_Charity__c = acc3.Id,
            AS_Status__c = '',
            AS_Date__c = date.Today()
        );
        transactionList.add(trans9);
        
        
        insert transactionList;
        
        
        
        List<AS_Month_End__c> monthEndList = new List<AS_Month_End__c>();
        AS_Month_End__c monthEnd = new AS_Month_End__c(
            Name = 'Month End name Test',
            Effective_Date__c = date.Today().addMonths(-1),
            Total_Valuation__c = 10000000, 
            AS_Investment_Option__c = 'General Portfolio'
        );
        monthEndList.add(monthEnd);
        insert monthEndList;
    }

    /*
    * @author: Butch B. Enerio
    * @date: February 11, 2020
    * @Method name: testGenerateMonthEnd1
    * @description: test scenario 1 for generating month end records
    * @parameter(s): none
    * @return: none
    * @updated : No
    * @updated by: 
    * @updated Date:
    * @description of the update:
    */
    @isTest
    static void testGenerateMonthEndCurrentFiscalYear(){
        
        ASMonthEndTriggerHandler monthEndTriggerHandler = new ASMonthEndTriggerHandler();
        
        List<AS_Month_End__c> monthEndList = new List<AS_Month_End__c>();
        AS_Month_End__c monthEnd = new AS_Month_End__c(
            Name = 'Month End name Test',
            Effective_Date__c = date.Today(),
            Total_Valuation__c = 10500000, 
            AS_Investment_Option__c = 'General Portfolio'
        );
        monthEndList.add(monthEnd);
        insert monthEndList;

        Test.startTest();
        Database.executeBatch(new ASMonthEndBatch(monthEndList[0]));
        Test.stopTest();
        
        AS_Month_End__c newMonthEnd = [SELECT Id, Name,(SELECT Id FROM Statement_Line_Items__r) FROM AS_Month_End__c WHERE Id =: monthEnd.Id Limit 1];
        system.assertEquals(newMonthEnd != null, true);
        system.assertEquals(newMonthEnd.Statement_Line_Items__r.size()>0, true);
    }

    @isTest
    static void testGenerateMonthEndPreviousFiscalYear(){

        Period currentFiscalYearSettings = [
            SELECT 
                FiscalYearSettings.Name, 
                StartDate, 
                EndDate 
            FROM Period 
            WHERE 
                Type = 'Year' AND 
                StartDate <= TODAY AND 
                EndDate >= TODAY
        ];
        
        ASMonthEndTriggerHandler monthEndTriggerHandler = new ASMonthEndTriggerHandler();
        
        List<AS_Month_End__c> monthEndList = new List<AS_Month_End__c>();
        AS_Month_End__c monthEnd = new AS_Month_End__c(
            Name = 'Month End name Test',
            Effective_Date__c = currentFiscalYearSettings.StartDate.addMonths(-5),
            Total_Valuation__c = 10500000, 
            AS_Investment_Option__c = 'General Portfolio'
        );
        monthEndList.add(monthEnd);
        insert monthEndList;

        Test.startTest();
        Database.executeBatch(new ASMonthEndBatch(monthEndList[0]));
        Test.stopTest();
        
        AS_Month_End__c newMonthEnd = [SELECT Id, Name,(SELECT Id FROM Statement_Line_Items__r) FROM AS_Month_End__c WHERE Id =: monthEnd.Id Limit 1];
        system.assertEquals(newMonthEnd != null, true);
        system.assertEquals(newMonthEnd.Statement_Line_Items__r.size()>0, false);
    }
}