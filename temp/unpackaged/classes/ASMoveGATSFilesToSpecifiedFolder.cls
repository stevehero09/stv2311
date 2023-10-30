/**
* Created by Jase Brandhon Gerona 09/17/21.
* a batch that arranges Annual Statement files
* Test Class: ASMoveGATSFilesToSpecifiedFolderTEST
*/
global class ASMoveGATSFilesToSpecifiedFolder implements Database.Batchable<sObject>{
    public Map<String, String> folderIds = new  Map<String, String>(); 
    
    public ASMoveGATSFilesToSpecifiedFolder(){
        folderIds = getAllFolders();
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        Set<Id> workspaceIds = new Set<Id>();
        
        system.debug('folderIds');
        system.debug(folderIds);
        for(String workspaceId : folderIds.keySet()){
            //system.debug(workspaceId);
            workspaceIds.add(workspaceId);
        }
      
        // collect the batches of records or objects to be passed to execute
		String ASGTAS_str = 'Annual Statement';   
        String query = 'SELECT Id,ParentId,Title FROM ContentDocument WHERE ParentId IN:workspaceIds AND Title LIKE \'%'+ ASGTAS_str +'%\'';
        //System.debug('query string'+query);  
        return Database.getQueryLocator(query);
    }
     
    global void execute(Database.BatchableContext BC, List<ContentDocument> ContentDocumentList) {
        
        System.debug( 'ContentDocumentList=>' + ContentDocumentList);
        
        try {
            List<ContentFolderMember> cnt = new List<ContentFolderMember>();

            // process each batch of records default size is 200
            for(ContentDocument ContentDocument_rec : ContentDocumentList) { 
                List<ContentFolderMember> ContentFolderMember_rec_list  = [SELECT ChildRecordId,Id,ParentContentFolderId FROM ContentFolderMember WHERE ChildRecordId =:ContentDocument_rec.Id ORDER BY LastModifiedDate DESC LIMIT 1];

                System.debug('folderIds.get(ContentDocument_rec.ParentId) = ' + folderIds.get(ContentDocument_rec.ParentId));
				
                ContentFolderMember ContentFolderMember_rec = new ContentFolderMember();
                ContentFolderMember_rec.Id = ContentFolderMember_rec_list[0].Id;
                ContentFolderMember_rec.ParentContentFolderId = folderIds.get(ContentDocument_rec.ParentId);
                //ContentFolderMember_rec.ParentContentFolderId = folderIds.get(ContentFolderMember_rec_list[0].ParentContentFolderId);
                //system.debug(ContentFolderMember_rec);
                //system.debug(folderIds);
                //system.debug(ContentFolderMember_rec_list[0].ParentContentFolderId);
                //system.debug(folderIds.get(ContentDocument_rec.ParentId));
                //ContentFolderMember_rec[0].ContentFolderMember_rec_list = folderIds.get(ContentFolderMember_rec_list[0].ParentContentFolderId);        	

                System.debug('ContentFolderMember_rec = ' + ContentFolderMember_rec);
			
                cnt.add(ContentFolderMember_rec);
                
            }
            System.debug('cnt =>' + cnt);
            // Update the Account Record
            // update cnt;

            List<Database.SaveResult> saveResults = Database.update(cnt);
            for (Database.SaveResult saveResult : saveResults) {
                if (saveResult.isSuccess()) {
                    System.debug('Successfully created ' + saveResult.getId());
                } else {
                    System.debug('Error: ' + saveResult.getErrors().get(0));
                }
            }
         
        } catch(Exception e) {
            System.debug(e);
        }
         
    }   
     
    global void finish(Database.BatchableContext BC) {
        // execute any post-processing operations like sending email
    }
    
    public Map<String, String> getAllFolders(){

        Map<String, String> FolderIds = new  Map<String, String>();
        Map<Id, Id> contentFolderWorkspaceMap = new Map<Id, Id>();
        Set<Id> parentContentFolderIdsSet = new Set<Id>();

        for(ContentWorkspace ContentWorkspace_rec: [SELECT DeveloperName,Id,Name,RootContentFolderId FROM ContentWorkspace]) {

            contentFolderWorkspaceMap.put(ContentWorkspace_rec.RootContentFolderId, ContentWorkspace_rec.Id);
            parentContentFolderIdsSet.add(ContentWorkspace_rec.RootContentFolderId);
            // List<ContentFolder> ContentFolder_rec = [SELECT Id, Name, ParentContentFolderId FROM ContentFolder WHERE ParentContentFolderId=:ContentWorkspace_rec.RootContentFolderId AND Name = 'Annual Activity Statement'];
            /*
            if(ContentFolder_rec.size() > 0){
                FolderIds.put(ContentWorkspace_rec.Id,ContentFolder_rec[0].Id);
            }
            */
        }

        for (ContentFolder contentFolder : [
            SELECT 
                Id, Name, ParentContentFolderId 
            FROM ContentFolder 
            WHERE 
                ParentContentFolderId IN: parentContentFolderIdsSet AND 
                Name = 'Annual Activity Statement'
        ]) {

            Id contentWorkspaceId = contentFolderWorkspaceMap.get(contentFolder.ParentContentFolderId);
            FolderIds.put(contentWorkspaceId, contentFolder.Id);
        }

       	return FolderIds;
    }
    
}