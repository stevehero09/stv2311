/*
* @author: Elly Dan Harvey L Mahinay
* @date: Febuary 5, 2020
* @Class name: AS_DeleteRecentMonthEndController
* @description: Controller class for DeleteRecentMonthEndController
* Jira Ticket: APSFSP-13
* @parameter(s): none
* @return: none
* @updated : Yes
* @updated by: Rob Alexander
* @updated Date: April 27, 2020
* @description of the update: changed 'with sharing' to 'without sharing' to bypass sharing rules for non-system admin users without delete permissions
*/
public without sharing class AS_DeleteRecentMonthEndController {
    private ApexPages.StandardSetController standardController;          
    String keyPrefix;

    public AS_DeleteRecentMonthEndController(ApexPages.StandardSetController standardController) {
        this.standardController = standardController;
        Schema.DescribeSObjectResult r = AS_Month_End__c.sObjectType.getDescribe();
        keyPrefix = r.getKeyPrefix();
    }

    public PageReference pp {get; set;}
    public List<SelectOption> investmentOption{set;} 
    public List<Account> accList {get;set;}
    public String selectedOption{get;set;}
    public String rollbacknote{get;set;}
    public PageReference deleteRecord() {
        if(Test.isRunningTest()){
        	selectedOption = 'General Portfolio';    
        }
        
        List<AS_Month_End__c> monthEndList = [SELECT Id, Name, Effective_Date__c,AS_Investment_Option__c from AS_Month_End__c  WHERE AS_Investment_Option__c = :selectedOption AND archived__c = false Order by Effective_Date__c DESC limit 1];
		
        //Add note to the monthend
        if(monthEndList.size() > 0 ) {
            monthEndList[0].Roll_Back_Note__c = rollbacknote;
            monthEndList[0].archived__c = true;
            update monthEndList;
            
            //APSFB-14 - Use batch instead of trigger for Month End Roll Back
            ASMonthEndRollback batch = new ASMonthEndRollback(monthEndList[0]);
            Database.executeBatch(batch);
        }
        
        
        
        

        PageReference parentPage = new PageReference('/'+keyPrefix);
        parentPage.setRedirect(true);
        pp =  parentPage;
        return pp;
    }
    
    
    public List<SelectOption> getAccountOption () {
        Schema.DescribeFieldResult F = AS_Month_End__c.AS_Investment_Option__c.getDescribe();
        Schema.sObjectField T = F.getSObjectField();
        List<PicklistEntry> entries = T.getDescribe().getPicklistValues();
        List<SelectOption> options = new List<SelectOption>();
         options.add(new SelectOption('','-- Select Investment Option --'));
        for(PicklistEntry entry : entries) {
            options.add(new SelectOption(entry.getValue(),entry.getValue()));
        }
        return options;
    }
    
    
}