/*
- Function Name: ASMonthEndTrigger
- Author: Butch B. Enerio
- Date Created: February 6, 2020
- Short Description: trigger for Month End object.
- Long Description
- Jira Ticket: APSFSP-43
*/
trigger ASMonthEndTrigger on AS_Month_End__c (before insert, after insert, before delete) {
    if(ASMonthEndTriggerHandler.runTrigger){
        if(trigger.isInsert){
            if(trigger.isBefore){
                List<AS_Month_End__c> triggerNew = trigger.new;
                ASMonthEndTriggerHandler.checkExistingMonthEnd(triggerNew);
                ASMonthEndTriggerHandler.renameMonthEnd(triggerNew);
            }
            //APSFB-13 - Use batch instead of trigger for Month End process
            // else if(trigger.isAfter) ASMonthEndTriggerHandler.generateMonthEndRecords(trigger.new);
        }

        //APSFB-14 - Use batch instead of trigger for Month End Roll Back
        // /**
        //  * Function Name: ASMonthEndTrigger
        //  * Author: Romnick Hilot
        //  * Date Created: April 20, 2020
        //  * Description: Update Account when month end delete
        //  * @return   return description
        //  * Jira Ticket: https://jira.alphasys.com.au/browse/APSFSP-54
        //  */
        // if( trigger.isDelete ) {
        //     if( trigger.isBefore ){
        //         ASMonthEndTriggerHandler.AsUpdateAccountOnDeletedMonthEnd( trigger.old );
        //     }
        // }
    }
}