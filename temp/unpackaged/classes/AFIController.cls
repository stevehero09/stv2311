// AFIController.cls
public with sharing class AFIController {
    @AuraEnabled(cacheable=true)
    public static Annual_Financials__c getMostRecentAFI(String accountId) {
        return [SELECT FUM__c, FUM_at_Date__c
                FROM Annual_Financials__c
                WHERE Organisation__c = :accountId
                ORDER BY CreatedDate DESC
                LIMIT 1];
    }
}