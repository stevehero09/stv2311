public with sharing class TestDataFactory {
  public static Projects__c createProject() {
    Projects__c pj = new Projects__c();
    pj.Name = 'TEST PRJ 1';
    insert pj;
    return pj;
  }

  public static Case createCase(String projId) {
    Case c = new case();
    c.Project__c = projId;
    c.Status = 'New';
    c.Description = 'Description';
    c.Reason = 'Other Admin';
    c.Origin = 'Internal';
    insert c;
    return c;
  }

  public static Releases__c createRelease() {
    Releases__c r = new Releases__c();
    //   r.Name = 'Test Release';
    insert r;
    return r;
  }

  public static Change_Items__c createChangeItem(
    String caseId,
    String releaseId
  ) {
    Change_Items__c ci = new Change_Items__c();
    ci.Change_Name__c = 'Test Change Item';
    ci.Case__c = caseId;
    ci.Releases__c = releaseId;
    insert ci;
    return ci;
  }
}