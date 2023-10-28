/*
* @author: Jan Dainis C. Saren
* @date: February 6, 2020
* @Class Name: ASRunMonthEndCTRL
* @description: Apex Controller for ASRunMonthEnd Lightning Component.
* @updated : No
* @updated by: 
* @updated Date:
* @description of the update:
*/
public class ASRunMonthEndCTRL {
    
	/*
    * @author: Jan Dainis C. Saren
    * @date: February 6, 2020
    * @Method Name: saveRecord
    * @description: Method for Save the Data for the Rcord on the Month End.
    * @updated : 
    * @updated by: 
    * @updated Date: 
    * @description of the update: 
    */
    @AuraEnabled
    public static Map<String,String> saveRecord(AS_Month_End__c simplenewMonthEnd) {
         Map<String,String> returnMap = new Map<String,String>();
        
        try{
            //Insert AS_Month_End__c Record
            insert simplenewMonthEnd;

            //APSFB-13/APSFB-24 - Call the Month End generation process
            ASMonthEndBatch batch = new ASMonthEndBatch(simplenewMonthEnd);
            Database.executeBatch(batch);

            returnMap.put('Message','Month End process is now running!');
            returnMap.put('IsSuccess','yes');
        }catch(DmlException e) {
            //get DML exception message
            //throw new AuraHandledException(e.getDmlMessage());
            returnMap.put('Message',String.valueOf(e.getDmlMessage(0)));
            returnMap.put('IsSuccess','no');
        }
        return returnMap;
    }
}