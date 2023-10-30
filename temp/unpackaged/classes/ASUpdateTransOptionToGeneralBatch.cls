/**
* @description       : Apex Batch to Update Investment Option to General Portfolio
* @author            : Aine A. Legaspi
* @group             :
* @last modified on  : 03-06-2022
* @last modified by  :
* Modifications Log
* Ver   Date         Author                 Modification
**/

global class ASUpdateTransOptionToGeneralBatch implements Database.Batchable<sObject>, Database.Stateful  {
    
    global Database.QueryLocator start (Database.BatchableContext BC){
        
        String query = 'SELECT Id, AS_Amount__c, AS_Status__c, AS_Fund__c,AS_Fund__r.Investment_Portfolio__c, AS_Investment_Option__c FROM AS_Transaction__c WHERE AS_Investment_Option__c = NULL';
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC, List<AS_Transaction__c> scope){
        
        //store new updated field value
        List<AS_Transaction__c> transToUpdate = new  List<AS_Transaction__c>();
        
        //loop through Transaction object and update Investment Option
        for(AS_Transaction__c trans : scope){
            
            if( trans.AS_Fund__r.Investment_Portfolio__c == 'Focused Portfolio' ){
            	trans.AS_Investment_Option__c = 'Focused Portfolio';   
            }else{
                trans.AS_Investment_Option__c = 'General Portfolio';
            }
            transToUpdate.add(trans);
            System.debug('transToUpdate =' + transToUpdate);
            
        }
        
        if(transToUpdate.size() != 0) {
            Database.SaveResult[] updateResults = Database.update(transToUpdate, false);
            for(Database.SaveResult sr:updateResults){
                system.debug(sr);
                if(!sr.isSuccess()){ Database.Error err = sr.getErrors()[0]; }
            }
        }
        
        
    }
    global void finish(Database.BatchableContext BC){
        
        //call the batch ASUpdateGivingFundOptionToGeneralBatch
        Database.executeBatch(new ASUpdateGivingFundOptionToGeneralBatch());
    }

}