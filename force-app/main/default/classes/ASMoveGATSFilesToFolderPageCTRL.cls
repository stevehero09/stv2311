public without sharing class ASMoveGATSFilesToFolderPageCTRL {
    private ApexPages.StandardSetController standardController;          
    String keyPrefix;

    public ASMoveGATSFilesToFolderPageCTRL(ApexPages.StandardSetController standardController) {
        this.standardController = standardController;
        Schema.DescribeSObjectResult r = Account.sObjectType.getDescribe();
        this.keyPrefix = r.getKeyPrefix();
    }

    public PageReference pp {get; set;}

    public PageReference moveFiles(){
        ASMoveGATSFilesToSpecifiedFolder batch = new ASMoveGATSFilesToSpecifiedFolder();
        Database.executeBatch(batch);

        PageReference parentPage = new PageReference('/'+keyPrefix);
        parentPage.setRedirect(true);
        pp =  parentPage;
        return pp;
    }
}