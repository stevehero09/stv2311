public with sharing class DeleteRecentMonthEndController {
    private ApexPages.StandardSetController standardController;
    String keyPrefix;

    public DeleteRecentMonthEndController(ApexPages.StandardSetController standardController) {
        this.standardController = standardController;
        Schema.DescribeSObjectResult r = AS_Month_End__c.sObjectType.getDescribe();
        keyPrefix = r.getKeyPrefix();
    }

    public PageReference pp {get; set;}
    
    public PageReference deleteRecord() {
        
        
        List<AS_Month_End__c> monthEndList = [SELECT Id, Name, Effective_Date__c from AS_Month_End__c Order by Effective_Date__c DESC limit 1];
        if(monthEndList.size()>0) {
            Delete monthEndList;
        }
        System.debug('e_debueg');


        PageReference parentPage = new PageReference('/'+keyPrefix);
        parentPage.setRedirect(true);
        pp =  parentPage;
        return pp;
    }
}