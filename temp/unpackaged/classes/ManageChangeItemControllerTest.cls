@isTest
public with sharing class ManageChangeItemControllerTest {
  @isTest
  public static void ManageChangeItemControllerTest() {
    Projects__c p = TestDataFactory.createProject();
    Case c = TestDataFactory.createCase(p.Id);

    Test.startTest();

    PageReference pg = Page.ManageChangeItemsCase;
    Test.setCurrentPage(pg);

    ApexPages.StandardController controller = new ApexPages.StandardController(
      c
    );

    ManageChangeItemController ciTest = new ManageChangeItemController(
      controller
    );

    ciTest.addItem();
    ciTest.saveItem();

    Change_Items__c cDel = new Change_Items__c();
    cDel.Case__c = c.Id;
    ciTest.ciList.add(cDel);
    Change_Items__c cDel1 = new Change_Items__c();
    cDel1.Case__c = c.Id;
    ciTest.ciList.add(cDel1);

    ciTest.saveItem();

    ciTest.loadItems();
    ciTest.cancelItem();
    ciTest.loadItems();
    ciTest.deletionId = cDel.Id;
    ciTest.indexNo = '0';
    ciTest.deleteItem();
    ciTest.deleteItem();

    String savePage = ciTest.saveItem().getUrl();
    String cancelPage = ciTest.cancelItem().getUrl();

    Test.stopTest();
  }
}