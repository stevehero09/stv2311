/**
* @description       : Apex Batch to Update Investment Option to General Portfolio
* @author            : Aine A. Legaspi
* @group             :
* @last modified on  : 03-06-2022
* @last modified by  :
* Modifications Log
* Ver   Date         Author                 Modification
**/

global class ASUpdateSLIOptionToGeneralBatch implements Database.Batchable<sObject>, Database.Stateful{

    global Database.QueryLocator start (Database.BatchableContext BC){
        
        String query = 'SELECT Id, AS_Type__c, AS_Amount__c, AS_Month_End__c, AS_Investment_Option__c,AS_Fund__c,AS_Fund__r.Investment_Portfolio__c FROM AS_Statement_Line_Item__c  WHERE AS_Investment_Option__c = NULL';
        return Database.getQueryLocator(query);
        
    }
    global void execute(Database.BatchableContext BC, List<AS_Statement_Line_Item__c> scope){
       
        //store new updated field value
        List<AS_Statement_Line_Item__c> sliToUpdate = new   List<AS_Statement_Line_Item__c>();
        
        //loop through Statement Line Item object and update Investment Option field
        for(AS_Statement_Line_Item__c sli: scope){
             System.debug('sli =' + sli);
            if( sli.AS_Fund__r.Investment_Portfolio__c == 'Focused Portfolio' ){
            	sli.AS_Investment_Option__c = 'Focused Portfolio';   
            }else{
                sli.AS_Investment_Option__c = 'General Portfolio';
            }
             
             sliToUpdate.add(sli);
             System.debug('sliToUpdate =' + sliToUpdate);
        }
        
         if(sliToUpdate.size() != 0) {
            Database.SaveResult[] updateResults = Database.update(sliToUpdate, false);
            for(Database.SaveResult sr:updateResults){
                system.debug(sr);
                if(!sr.isSuccess()){ Database.Error err = sr.getErrors()[0]; }
            }
        }
        
    }
    global void finish(Database.BatchableContext BC){
        
        //call the batch ASUpdateTransOptionToGeneralBatch
        Database.executeBatch(new ASUpdateTransOptionToGeneralBatch());
    }
}