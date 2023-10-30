/**
* Created by Jimson Rudinas on 2/12/2020.
* Controller for the Account Summary and Activity Detail Components
* Test Class: ASAccountSummaryCTRL_Test
*/
public with sharing class ASAccountSummaryCTRL {
 
    /**
     * Retrieves values from account fields of the current user
     *
     * @param 
     *
     * @return Returns Current User Account
     */
    @AuraEnabled
    public static Account getAccountRecord() {
        
        String userId = UserInfo.getUserId();
        Id accId;
        Account acc;
    
        List<User> u = [SELECT Name, AccountId FROM User WHERE Id = :userId];
       
        if(!u.isEmpty()) {
            Id id = u[0].AccountId;
            if ( id != null ) {
                accId = id;
            }
        }
        
         acc = [SELECT Owner.Name,Name,Balance__c,AS_Available_Balance__c,AS_CAN__c,Status__c,Date_Joined_APS__c,AS_Adjustments_YTD__c,AS_Donations_YTD__c,AS_Gifts_YTD__c,AS_Investment_Returns_YTD__c,AS_Adjustments_Since_Inception__c,AS_Donations_Since_Inception__c,AS_Gifts_Since_Inception__c,AS_Investment_Returns_Since_Inception__c,AS_Balances_Last_Updated__c,AS_Last_Run_Month_End__r.Name FROM Account WHERE Id=:accId limit 1];
            
        return acc;

    }
}