/**
 * Created by John Rendhon Gerona on June 22, 2022
 * This tests the ASUpdateMinorBalancesController class
 */
@isTest
public class ASMinorBalanceSchedulerTest {
	@isTest
    static void testschedule(){
    	SchedulableContext sc = null;
        ASMinorBalanceScheduler tsc = new ASMinorBalanceScheduler();
        tsc.execute(sc);
    }
}