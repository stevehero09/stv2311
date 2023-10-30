/**
 * Class Name: ASMyGivingFundCTRL
 * Author: Rowelle Gem Daguman
 * Date Created: June 3, 2020
 * Tickets: APSFSP-63
 * Short Description: Controllers for the My Giving Fund Component.
 */
public with sharing class ASMyGivingFundCTRL {
    /**
     * @author: Rowelle
     * @date: June 3, 2020
     * @Method name: getAccountRecord
     * @description: 
     * @parameter(s): 
     * @return: 
     * @updated : No
     * @updated by: 
     * @updated Date: 
     * @description of the update: 
     */
    @AuraEnabled
    public static AccountRecordWrapper getAccountRecord() {
        
        AccountRecordWrapper record;
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
        
         acc = [SELECT Name, AS_CAN__c,AS_Previous_Month_End_Balance__c, Balance__c, Investment_Portfolio__c, AS_Available_Balance__c, AS_Last_Run_Month_End__r.Name
                FROM Account 
                WHERE Id=:accId 
                limit 1];

        record = new AccountRecordWrapper(acc);
        return record;
    }
    
    public class AccountRecordWrapper {
        @AuraEnabled
        public Decimal recordBalance { get; set; }
        
        @AuraEnabled
        public Decimal recordAvailBalance { get; set; }
        
        @AuraEnabled
        public String recordName { get; set; }
        
        @AuraEnabled
        public String recordCAN { get; set; }
        
        @AuraEnabled
        public String monthEnd { get;set; }
        
        @AuraEnabled
        public String investment_option { get;set; }
             
        public AccountRecordWrapper( Account accData ) {
            this.recordBalance = accData.AS_Previous_Month_End_Balance__c;
            this.recordAvailBalance = accData.AS_Available_Balance__c;
            this.recordName = accData.Name;
            this.recordCAN = accData.AS_CAN__c;
            this.monthEnd = accData.AS_Last_Run_Month_End__r.Name;
            this.investment_option = accData.Investment_Portfolio__c;
        }
    }
}