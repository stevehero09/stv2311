@isTest
public with sharing class ManageReleaseChangeItemTest {
  @isTest
  public static void ManageReleaseChangeItemTest() {
    Projects__c p = TestDataFactory.createProject();
    Case c = TestDataFactory.createCase(p.Id);
    Releases__c r = TestDataFactory.createRelease();
    Change_Items__c ci = TestDataFactory.createChangeItem(c.id, r.id);

    Test.startTest();
    PageReference pg = Page.ManageReleaseChangeItems;
    Test.setCurrentPage(pg);

    ApexPages.StandardController controller = new ApexPages.StandardController(
      r
    );

    ManageReleaseChangeItem ciTest = new ManageReleaseChangeItem(controller);

    ciTest.loadItems();
    ciTest.addItem();
    ciTest.saveItem();

    Change_Items__c cDel = new Change_Items__c();
    cDel.Releases__c = r.Id;
    ciTest.ciList.add(cDel);
    Change_Items__c cDel1 = new Change_Items__c();
    cDel1.Releases__c = r.Id;
    ciTest.ciList.add(cDel1);

    ciTest.saveItem();
    ciTest.loadItems();

    ciTest.deletionId = cDel.Id;
    ciTest.indexNo = '0';
    ciTest.deleteItem();
    ciTest.deleteItem();
    ciTest.cancelItem();

    String savePage = ciTest.saveItem().getUrl();
    String cancelPage = ciTest.cancelItem().getUrl();

    Test.stopTest();
  }
}