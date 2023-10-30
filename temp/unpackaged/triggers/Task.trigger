// This is generic trigger and must be extended to include all events
// 
/*****
* Revisions:    15-Oct-2022 - Stephen Manning   - Added handling for beforeInsert event - CASE#23304
******/ 

trigger Task on Task (before insert, after update,after delete) {
    
    if (trigger.isbefore && trigger.isInsert){
        TaskUtility.beforeInsert(trigger.new);
    }  
    
    if(trigger.isafter && trigger.isUpdate){
        TaskUtility.afterUpdate(trigger.old,trigger.new,trigger.newMap,trigger.OldMap);
    }
    
    if(trigger.isafter && trigger.isDelete){
        TaskUtility.afterDelete(trigger.old);
    }
    
}