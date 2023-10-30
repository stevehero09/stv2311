public with sharing class ManageReleaseChangeItem {
  Releases__c sourceRelease;
  public List<Change_Items__c> ciList { get; set; }
  public String deletionId { get; set; }
  public String indexNo { get; set; }
  public Integer idxno;

  public ManageReleaseChangeItem(ApexPages.StandardController stdController) {
    sourceRelease = (Releases__c) stdController.getRecord();

    if (sourceRelease != null) {
      loadItems();
    }
  }

  public void loadItems() {
    ciList = new List<Change_Items__c>();

    for (Change_Items__c c : [
      SELECT
        Id,
        Case__c,
        Change_Made__c,
        Change_Type__c,
        Object__c,
        Change_Name__c,
        Change_owner__c,
        Releases__c,
        Manual_Change__c,
        Status__c
      FROM Change_Items__c
      WHERE Releases__c = :this.sourceRelease.Id AND isDeleted = :false
    ]) {
      ciList.add(c);
    }
  }

  public void addItem() {
    Change_Items__c c = new Change_Items__c();
    c.Releases__c = sourceRelease.Id;
    ciList.add(c);
  }

  public Pagereference saveItem() {
    try {
      upsert ciList;
    } catch (DmlException e) {
      System.debug('****DML Error*** ' + e.getMessage());
    }

    PageReference pg = new ApexPages.StandardController(this.sourceRelease)
      .view();
    pg.setRedirect(true);
    return pg;
  }

  public Pagereference cancelItem() {
    PageReference pg = new ApexPages.StandardController(this.sourceRelease)
      .view();
    pg.setRedirect(true);
    return pg;
  }

  public void deleteItem() {
    System.debug('********Delete function called********');

    Change_Items__c delCi = null;
    idxno = Integer.valueof(indexNo);

    if (deletionId != null && deletionId.length() > 0) {
      System.debug(
        '*****ID of the record to delete before loop***** ' + deletionId
      );
      for (Change_Items__c delItem : ciList) {
        if (delItem.Id == deletionId) {
          delCi = delItem;
          break;
        }
      }
    } else {
      System.debug('******Index No is***** ' + indexNo);
      try {
        System.debug('******Idx No is***** ' + idxno);
        ciList.remove(idxno);
      } catch (exception e) {
        System.debug('****List deletion error*** ' + e.getMessage());
      }
    }

    if (delCi != null) {
      System.debug('*****ID of the record to delete after loop***** ' + delCi);
      ciList.remove(idxno);
      try {
        delete delCi;
      } catch (DmlException e) {
        System.debug('****DML Error*** ' + e.getMessage());
      }
    }
  }
}