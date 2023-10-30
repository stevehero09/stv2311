//Updated effective date on month end due to field validation errors on deployments
//SR - 27/06/2022 - added investment option to account create due to new Investment options validation rule

@isTest(SeeAllData=true)
public class RHX_TEST_AS_Statement_Line_Item {
    static testMethod void RHX_Testmethod() {
        
        Id orgRT = Schema.SObjectType.Account.getRecordTypeInfosByName().get('APS Foundation Giving Fund').getRecordTypeId();
        
        Account acc = new Account(
            RecordTypeId = orgRT,
            Name = 'Test Giving Fund 1',
            Balance__c = 20000000,
            Status__c = 'Active',
            AS_Previous_Month_End_Balance__c = 2000000000,
            Investment_Portfolio__c = 'General Portfolio'
        );
        insert acc;
        AS_Month_End__c monthEnd = new AS_Month_End__c(
            Name = 'Month End name Test',
           // Effective_Date__c = date.Today().addMonths(-1),
            Effective_Date__c = date.Today(),
            Total_Valuation__c = 10000000
        );
        insert monthEnd;
        
        List<sObject> sourceList = [SELECT Id, AS_Type__c, AS_Month_End__c
            FROM AS_Statement_Line_Item__c LIMIT 1];
        
        if(sourceList.size() == 0) {
            sourceList.add(
                    new AS_Statement_Line_Item__c(
                        AS_Type__c = 'Gift',
                        AS_Month_End__c = monthEnd.Id,
                        AS_Amount__c = 2500.00,
                        AS_Fund__c = acc.Id
                    )
            );
        }
        rh2.ParentUtil.UpsertRollupTestRecords( sourceList );
    }
}