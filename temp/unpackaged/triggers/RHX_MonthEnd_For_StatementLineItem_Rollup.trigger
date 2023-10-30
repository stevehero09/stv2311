trigger RHX_MonthEnd_For_StatementLineItem_Rollup on AS_Month_End__c (after insert, after update, after delete, after undelete, before delete) {

Type rollClass = System.Type.forName('rh2', 'ParentUtil');

    if(rollClass != null) {

          rh2.ParentUtil pu = (rh2.ParentUtil) rollClass.newInstance();

          if (trigger.isAfter) {

                      pu.performTriggerRollups(trigger.oldMap, trigger.newMap, new String[]{'AS_Statement_Line_Item__c'}, null);   

          }else if (trigger.isBefore) {

                  if(trigger.isDelete) {

                          pu.prepareTriggerRollups(trigger.oldMap, trigger.newMap, new String[]{'AS_Statement_Line_Item__c'}, null);        

                  }

          }

}

}