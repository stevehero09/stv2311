trigger FoundationMeeting on Foundation_Meeting__c (after insert,after update,before insert) {

    // Call utility class after insert
    // 
    if(trigger.isInsert && trigger.isbefore){
        FMUtility.beforeInsert(trigger.new);
    }
    if(trigger.isinsert && trigger.isafter){
    system.debug('test');
        FMUtility.AfterInsert(trigger.newMap.keySet());
    }
    
    if(trigger.isUpdate && trigger.isafter){
        FMUtility.afterUpdate(trigger.newMap.keySet(),trigger.newMap,trigger.oldMap);
    }
    
    


}