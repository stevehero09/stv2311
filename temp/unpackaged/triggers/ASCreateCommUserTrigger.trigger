/*
* @author: Elly Dan Harvey L. Mahinay
* @date: Febuary 12, 2020
* @trigger name: ASCreateCommUserTrigger
* @description: trigger for creating a community User
* Jira Ticket: APSFSP-18
* @parameter(s): 
* @return: none
* @updated : No
* @updated by: 
* @updated Date:
* @description of the update:
*/
trigger ASCreateCommUserTrigger on npe5__Affiliation__c (after insert, after update) {
    
    if(trigger.isAfter) {
        if(trigger.isInsert || trigger.isUpdate) {
            if(!ASCreateCommUserTriggerHandler.runOnce) {

                ASCreateCommUserTriggerHandler.runOnce = true;
                ASCreateCommUserTriggerHandler.checkPortalContact(trigger.new);
            }
        }
    } 
}