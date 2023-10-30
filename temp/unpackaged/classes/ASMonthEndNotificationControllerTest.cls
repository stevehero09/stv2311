@isTest
public class ASMonthEndNotificationControllerTest {

    @IsTest
    static void testNotify(){
        
        Test.startTest();

        ASMonthEndNotificationController.notify('General Portfolio');

        Test.stopTest();
        
    }
}