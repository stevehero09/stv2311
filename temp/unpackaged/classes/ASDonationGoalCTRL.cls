/**
 * Class Name: ASDonationGoalCTRL
 * Author: Carl Ortiz
 * Date Created: February 11, 2020
 * Tickets: APSFSP-30
 * Short Description: Controllers for the Donation Goal controller.
 */
public with sharing class ASDonationGoalCTRL {

    /**
     * @author: Carl Ortiz
     * @date: February 11, 2020
     * @Method name: getDonationRecord
     * @description: 
     * @parameter(s): 
     * @return: 
     * @updated : No
     * @updated by: 
     * @updated Date: 
     * @description of the update: 
     */
    @AuraEnabled
    public static OrganisationWrapper getDonationGoalProgress() {
        OrganisationWrapper orgDetails;
        
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

        acc = [SELECT Minimum_Required_Gifts__c, Gifts_Outstanding__c, AS_Gifts_YTD__c FROM Account WHERE Id=:accId limit 1];

        orgDetails = new OrganisationWrapper(acc);

        return orgDetails;
    }

    public class OrganisationWrapper {
        @AuraEnabled
        public Decimal minimumRequired { get; set; }

        @AuraEnabled
        public Decimal gifted { get; set; }

        @AuraEnabled
        public Decimal outstanding { get; set; }

        @AuraEnabled
        public Integer progress { get; set; }

        public OrganisationWrapper(Account organisation) {
            this.minimumRequired = organisation.Minimum_Required_Gifts__c;
            this.gifted = organisation.AS_Gifts_YTD__c;
            this.outstanding = organisation.Gifts_Outstanding__c;
            this.progress = 0;
			
            System.debug ('minimumRequired: '+ this.minimumRequired);
            System.debug ('gifted: '+ this.gifted);
            
            if (this.gifted >= this.minimumRequired) {
                this.progress = 100;
            } else {
                Decimal p = 100 * (this.gifted / this.minimumRequired);
                this.progress = Integer.valueOf(Math.Round(p));
            }
        }
    }
}