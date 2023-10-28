/**
* @description       : Apex Batch to Update Investment Option and Previous FY Option to General Portfolio
* @author            : Aine A. Legaspi
* @group             :
* @last modified on  : 03-06-2022
* @last modified by  :
* Modifications Log
* Ver   Date         Author                 Modification
**/

global class ASUpdateGivingFundOptionToGeneralBatch implements Database.Batchable<sObject>{
    
     private Account recordTypeName;
    
    global Database.QueryLocator start (Database.BatchableContext BC){
        
       Date targetDate = Date.newInstance(2022, 6, 1); // Date.parse('06/01/2022');
       
       	Id devRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('APS Foundation Giving Fund').getRecordTypeId();
        
        
        String query = 'SELECT Id, Name, Status__c, CreatedDate, RecordTypeId, Investment_Portfolio__c, AS_Previous_FY_Option__c FROM Account WHERE CreatedDate < :targetDate AND RecordTypeId = :devRecordTypeId AND Investment_Portfolio__c = NULL';
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC, List<Account> scope){
        
        System.debug('scope = ' + scope);
      
        //store new updated field value
        List<Account> accountToUpdate = new  List<Account>();
        
        //loop Month Ends and update Investment Option and Previous FY Option field
        for(Account acc : scope){
               System.debug('acc =' + acc); 
               System.debug(acc.Investment_Portfolio__c); 
               acc.Investment_Portfolio__c = 'General Portfolio';
               acc.AS_Previous_FY_Option__c = 'General Portfolio';
               accountToUpdate.add(acc);
               System.debug('accountToUpdate =' + accountToUpdate); 
        }
        
         if(accountToUpdate.size() != 0) {
            Database.SaveResult[] updateResults = Database.update(accountToUpdate, false);
            for(Database.SaveResult sr:updateResults){
                system.debug(sr);
                if(!sr.isSuccess()){ Database.Error err = sr.getErrors()[0]; }
            }
        }
    }
    global void finish(Database.BatchableContext BC){
        
    }

}