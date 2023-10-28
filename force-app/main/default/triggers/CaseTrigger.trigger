/**
 * Revisions:	
 * 23-Jan-2023 - Stephen Manning
 * Added afterUpdate trigger for Case #00025165
 */

trigger CaseTrigger on Case (after insert, after update) {
    
    if(trigger.isInsert && trigger.isAfter)
    {
        caseUtility.afterInsert(Trigger.new,Trigger.Old,Trigger.newMap,Trigger.OldMap);
    }
    
    if(trigger.isUpdate && trigger.isAfter)
    {
        caseUtility.afterUpdate(Trigger.new, Trigger.old, Trigger.NewMap, Trigger.OldMap);
    }
}