@isTest(SeeAllData=true)
public class RHX_TEST_AS_Month_End {
static testMethod void RHX_Testmethod() {

       List<sObject> sourceList = [SELECT Id, Name, Effective_Date__c, Total_Valuation__c

     FROM AS_Month_End__c ORDER BY LastModifiedDate DESC LIMIT 1];
    
    System.debug('sourceList '+sourceList);

       if(sourceList.size() == 0) {

           sourceList.add(

                   new AS_Month_End__c(
                        Name = 'Month End name Test',
                        Effective_Date__c = date.Today().addMonths(-1),
                        Total_Valuation__c = 10000000
                   )

           );

       }

     rh2.ParentUtil.UpsertRollupTestRecords( sourceList );



Sobject testdel = [SELECT Id FROM AS_Month_End__c ORDER BY LastModifiedDate DESC LIMIT 1];

delete(testdel);

   }

 

}