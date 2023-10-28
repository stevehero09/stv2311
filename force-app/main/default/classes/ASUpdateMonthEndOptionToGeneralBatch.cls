/** 
* @description       : Apex Batch to Update Investment Option to General Portfolio
* @author            : Aine A. Legaspi
* @group             : 
* @last modified on  : 03-06-2022
* @last modified by  :  
* Modifications Log 
* Ver   Date         Author                 Modification
**/

global class ASUpdateMonthEndOptionToGeneralBatch implements Database.Batchable<sObject>, Database.Stateful {
    
    global Database.QueryLocator start (Database.BatchableContext BC){
        
        String query = ' Select Id, Name,AS_Investment_Option__c  FROM AS_Month_End__c WHERE AS_Investment_Option__c = NULL';
        return Database.getQueryLocator(query);
    } 
    
    global void execute(Database.BatchableContext BC, List<AS_Month_End__c> scope){
        System.debug('scope =' + scope);
            
        List<AS_Month_End__c> monthToUpdate = new List<AS_Month_End__c>();
       
        //loop through Month End object and update Investment Option field
        for(AS_Month_End__c month: scope){
                System.debug('month =' + month);
                
            	month.AS_Investment_Option__c ='General Portfolio';
                monthToUpdate.add(month); 
                System.debug('allMonthList =' + monthToUpdate);
        }
         
         if(monthToUpdate.size() != 0) {
            Database.SaveResult[] updateResults = Database.update(monthToUpdate, false);
            for(Database.SaveResult sr:updateResults){
                system.debug(sr);
                if(!sr.isSuccess()){ Database.Error err = sr.getErrors()[0]; }
            }
        }
    }
    
     global void finish(Database.BatchableContext BC){
 
         //call the batch ASUPdateSLIOptionToGenerateBatch
          Database.executeBatch(new ASUpdateSLIOptionToGeneralBatch());
    }
    

}