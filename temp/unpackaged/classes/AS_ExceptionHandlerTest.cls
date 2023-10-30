/**
* Created by Jase Brandhon Gerona on 09/08/2021.
* Description : Apex test class for AS_ExceptionHandler apex class
*/ 
@isTest
public class AS_ExceptionHandlerTest {

    @isTest static void testCreateException() {
        AS_Month_End__c newMonthE = new AS_Month_End__c(

            Name = 'Feb Feb',
            Effective_Date__c = Date.today(),
            Total_Valuation__c = 33
        );
        insert newMonthE;
        
      Exception except;
        try{
            Integer sample;
            System.debug(sample + 1);
        } catch(Exception ex){
            AS_ExceptionHandler.createException( ex, 'Month End', 'ASMonthEndTriggerHandler', newMonthE.Id ); 
            except =  ex;
        }
        
        AS_Exception__c lastInsertedRecord = [ Select AS_Function_Executed__c, AS_Trigger_Class__c,AS_Error_Encountered__c,AS_Full_Error__c from AS_Exception__c order by AS_DateTime__c desc limit 1 ];

        System.assertEquals( 'Month End' , lastInsertedRecord.AS_Function_Executed__c );
        System.assertEquals( 'ASMonthEndTriggerHandler' , lastInsertedRecord.AS_Trigger_Class__c );
        System.assertEquals( except.getMessage() , lastInsertedRecord.AS_Error_Encountered__c );
        System.assertEquals( except.getMessage() + ' - ' + except.getStackTraceString() , lastInsertedRecord.AS_Full_Error__c );

        
    }
    @isTest static void testCreateException2() {
        Id orgRT = Schema.SObjectType.Account.getRecordTypeInfosByName().get('APS Foundation Giving Fund').getRecordTypeId();

        List<Account> accountList = new List<Account>();
        Account acc1 = new Account(
            RecordTypeId = orgRT,
            Name = 'Test Giving Fund 1',
            Balance__c = 20000000,
            Status__c = 'Active',
            AS_Previous_Month_End_Balance__c = 2000000000, 
            Investment_Portfolio__c = 'General Portfolio'
        );
        accountList.add(acc1);
        Account acc2 = new Account(
            RecordTypeId = orgRT,
            Name = 'Test Giving Fund 2',
            Balance__c = 25000000,
            Status__c = 'Active',
            AS_Previous_Month_End_Balance__c = 250000000, 
            Investment_Portfolio__c = 'Focused Portfolio'
        );
        accountList.add(acc2);
        insert accountList;

        List<Id> accIds = new List<Id>();

        for(Account acc : accountList) {
            accIds.add(acc.Id);
        }

        Exception except;
        try{
            Integer sample;
            System.debug(sample + 1);
        } catch(Exception ex){
            AS_ExceptionHandler.createExceptionRecord( ex, 'Update Giving', 'ASUpdateGivingFundGoalBatch', accIds ); 
            except =  ex;
        }
    }
    
}