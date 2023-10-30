@isTest(SeeAllData=true)
public class RHX_TEST_AS_Transaction {
	static testMethod void RHX_Testmethod() {
        List<sObject> sourceList = [SELECT Id 
			FROM AS_Transaction__c LIMIT 1];
        if(sourceList.size() == 0) {
            sourceList.add(
                    new AS_Transaction__c()
            );
        }
    	rh2.ParentUtil.UpsertRollupTestRecords( sourceList );
    }
}