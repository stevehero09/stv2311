public with sharing class ASUpdateMinorBalancesController {

    @AuraEnabled
    public static List<Id> executeBatchJob(){
        //ASMinorBalanceUpdatesBatch batch = new ASMinorBalanceUpdatesBatch('General Portfolio');
        //Id batchJobId = Database.executeBatch(batch);

        List<Id> batchIds = new List<Id>();
        ASMinorBalanceUpdatesBatchv2 focusedbatch = new ASMinorBalanceUpdatesBatchv2('Focused Portfolio');
        Id focused = Database.executeBatch(focusedbatch,10);
        batchIds.add(focused);

        ASMinorBalanceUpdatesBatchv2 generalbatch = new ASMinorBalanceUpdatesBatchv2('General Portfolio');
        Id general = Database.executeBatch(generalbatch,10);
        batchIds.add(general);

        return batchIds;
    }

    @AuraEnabled
    public static List<AsyncApexJob> getBatchJobStatus(List<Id> jobIds){
        List<AsyncApexJob> jobInfo = [SELECT Status, NumberOfErrors,JobItemsProcessed,TotalJobItems FROM AsyncApexJob WHERE Id IN:jobIds];
        return jobInfo;
    }
}