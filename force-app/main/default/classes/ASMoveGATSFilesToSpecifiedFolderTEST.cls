/**
* Created by Jase Brandhon Gerona 09/17/21.
* Testclass for ASMoveGATSFilesToSpecifiedFolder
*/ 
@isTest
private class ASMoveGATSFilesToSpecifiedFolderTEST{
    
    @testSetup
    private static void createTestData() {
        //Create Workspace
        ContentWorkspace testWorkspace = new ContentWorkspace(Name='TEST CLASS', DeveloperName='TEST_CLASS');
        insert testWorkspace;
    }
    
    static testMethod void validateSMoveGATSFilesToSpecifiedFolder() {
        
        //Create Folder inside the workspace
        ContentWorkspace testWorkspace = [Select Id from ContentWorkspace where Name = 'TEST CLASS' ];

        ContentFolder workspaceFolder = [Select Id from ContentFolder where Name =: testWorkspace.Id];
    
        ContentFolder testFolderRecord = new ContentFolder(Name='Annual Activity Statement ', ParentContentFolderId=workspaceFolder.Id);
        insert testFolderRecord;
        //System.debug('testFolderRecord'+testFolderRecord);
        
      //Create Content document for file upload
    	ContentVersion  AsContentVersion = new ContentVersion();
            AsContentVersion.Title = 'JB CORP Annual Statement';
            AsContentVersion.PathOnClient = 'JB CORP Annual Statement.doc';
            AsContentVersion.VersionData = Blob.valueOf('Test Content');
            AsContentVersion.IsMajorVersion = true;
        insert AsContentVersion;
        System.assertEquals( true, AsContentVersion.Title.contains('Annual Statement') );
        
        ContentVersion contentVersionSelect = [SELECT Id, Title, ContentDocumentId FROM ContentVersion WHERE Id = :AsContentVersion.Id LIMIT 1];
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        
        List<ContentDocumentLink> conDocList = new List<ContentDocumentLink>();
        ContentDocumentLink AsContentLink = new ContentDocumentLink();
            AsContentLink.LinkedEntityId = testWorkspace.Id;
            AsContentLink.ShareType = 'I';
            AsContentLink.ContentDocumentId = documents[0].Id;
            AsContentLink.Visibility = 'AllUsers'; 
        conDocList.add(AsContentLink);
        insert conDocList;
        
        Test.startTest();
      		ASMoveGATSFilesToSpecifiedFolder bcn = new ASMoveGATSFilesToSpecifiedFolder() ;
			Database.executeBatch(bcn, 100);
        Test.stopTest();
         
        // Retrieve the record
       List<ContentDocumentLink> annualStatementRec = [SELECT ContentDocumentId,LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId =:testWorkspace.Id LIMIT 1];
       System.assertEquals(annualStatementRec[0].LinkedEntityId, testWorkspace.Id);
       System.assertEquals(annualStatementRec[0].ContentDocumentId, documents[0].Id);
		
    }
}