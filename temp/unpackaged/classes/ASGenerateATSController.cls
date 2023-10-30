public class ASGenerateATSController {

    private final static String urlFieldName = 'Generate_Annual_Tax_Statements__c';
    private String partnerServerUrl;
    private ApexPages.StandardSetController controller;
    private List<Id> recordIds = new List<Id>();

    
    public ASGenerateATSController(ApexPages.StandardSetController controller) {
        this.controller = controller;
        
        for (sObject sObj : controller.getSelected()){
            recordIds.add(sObj.Id);
        }
        partnerServerUrl = System.URL.getOrgDomainUrl().toExternalForm()+'/services/Soap/u/26.0/'+UserInfo.getOrganizationId();
        System.debug(partnerServerUrl);
    } 

    public PageReference generateATS() {
        PageReference conductorUrl = new PageReference('https://conductor.congamerge.com?');
        conductorUrl.getParameters().put('MOID', String.join(new List<Id>(recordIds),','));
        conductorUrl.getParameters().put('SessionId',  UserInfo.getSessionID());
        conductorUrl.getParameters().put('ServerUrl',  partnerServerUrl);
        conductorUrl.getParameters().put('UrlFieldName',  urlFieldName);
        
        System.debug(conductorUrl);

        return conductorUrl;
    }
}