//Modified from the AS_ExceptionHandlerTest class created by Jase Brandhon Gerona @ Alphasys on 09/08/2021.

@isTest
public class ExceptionHandlerTest {

    @isTest static void testCreateException() {
        
      Exception except;
        try{
            Integer sample;
            System.debug(sample + 1);
        } catch(Exception ex){
            ExceptionHandler.createNewException( ex,'DatabaseUpdate', 'batchContactPhoneUpdate' ); 
            except =  ex;
        }
        
        AS_Exception__c lastInsertedRecord = [ Select AS_Function_Executed__c, AS_Trigger_Class__c,AS_Error_Encountered__c,AS_Full_Error__c from AS_Exception__c order by AS_DateTime__c desc limit 1 ];

        System.assertEquals( 'DatabaseUpdate' , lastInsertedRecord.AS_Function_Executed__c );
        System.assertEquals( 'batchContactPhoneUpdate' , lastInsertedRecord.AS_Trigger_Class__c );
        System.assertEquals( except.getMessage() , lastInsertedRecord.AS_Error_Encountered__c );
        System.assertEquals( except.getMessage() + ' - ' + except.getStackTraceString() , lastInsertedRecord.AS_Full_Error__c );

        
    }
    
}