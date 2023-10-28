/*
* @author: Elly Dan Harvey L Mahinay
* @date: Febuary 6, 2020
* @Class name: AS_DeleteRecentMonthEndControllerTest
* @description: test class for DeleteRecentMonthEndController
* Jira Ticket: APSFSP-13
* @parameter(s): none
* @return: none
* @updated : No
* @updated by: 
* @updated Date:
* @description of the update:
*/
@isTest
public class AS_DeleteRecentMonthEndControllerTest {

    /*
    * @author: Elly Dan Harvey L Mahinay
    * @date: Febuary 6, 2020
    * @method name: setup
    * @description: insertion of needed data for AS_Month_End__c
    * Jira Ticket: APSFSP-13
    * @parameter(s): none
    * @return: none
    * @updated : 
    * @updated by: 
    * @updated Date:
    * @description of the update:
    */
    @testSetup static void setup() {

        AS_Month_End__c newMonthE = new AS_Month_End__c(

            Name = 'Feb Feb',
            Effective_Date__c = Date.today(),
            Total_Valuation__c = 33,
            archived__c = false,
            AS_Investment_Option__c = 'General Portfolio'
            
        );
        insert newMonthE;
        
    }

    /*
    * @author: Elly Dan Harvey L Mahinay
    * @date: Febuary 6, 2020
    * @method name: UpdateCharteredUrlControllerTest_1
    * @description: to run the controller
    * Jira Ticket: APSFSP-13
    * @parameter(s): none
    * @return: none
    * @updated : 
    * @updated by: 
    * @updated Date:
    * @description of the update:
    */
    static testMethod void AS_DeleteRecentMonthEndControllerTest_1() {

        Schema.DescribeSObjectResult r = AS_Month_End__c.sObjectType.getDescribe();
        String keyPrefix = r.getKeyPrefix();

        ApexPages.currentPage().getParameters().put('id', keyPrefix);

        AS_DeleteRecentMonthEndController testAccPlan = new AS_DeleteRecentMonthEndController(null);
		testAccPlan.getAccountOption();
        testAccPlan.deleteRecord();
	}
}