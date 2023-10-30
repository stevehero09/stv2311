public class ASMonthEndNotificationController {
    
    @AuraEnabled
    public static void notify(String investmentOption) {
        
        ASMonthEndNotificationBatch monthEndNotificationBatch = new ASMonthEndNotificationBatch(investmentOption);
        Database.executeBatch(monthEndNotificationBatch);
    }
}