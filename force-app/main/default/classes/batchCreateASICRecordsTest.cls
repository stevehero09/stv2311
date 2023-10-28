@isTest
public class batchCreateASICRecordsTest {
  @testSetup
  public static void testSetup() {
    List<Account> accList = new List<Account>();
    Date todayDate = date.Today();
    Date renewalDue = date.newInstance(
      todayDate.year(),
      todayDate.month() + 1,
      1
    );
    Date renewalNotDue = date.newInstance(
      todayDate.year(),
      todayDate.month() + 3,
      1
    );

    Id accRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName()
      .get('APS Private Ancillary Funds')
      .getRecordTypeId();

    Account a = new Account();
    a.Name = 'Test account Renewal Due';
    a.RecordTypeId = accRecordTypeId;
    a.Date_of_Renewal__c = renewalDue;
    accList.add(a);

    Account b = new Account();
    b.Name = 'Test account Renewal Not Due';
    b.RecordTypeId = accRecordTypeId;
    b.Date_of_Renewal__c = renewalNotDue;
    accList.add(b);

    Account c = new Account();
    c.Name = 'Has open asic record';
    c.RecordTypeId = accRecordTypeId;
    c.Date_of_Renewal__c = date.today();
    accList.add(c);

    insert accList;

    System.debug(
      'Renewal due account ' +
      a.Id +
      'Renewal not due account ' +
      b.Id +
      'Has open asic record account ' +
      c.Id
    );

    ASIC_Solvency_Declaration__c asd = new ASIC_Solvency_Declaration__c();
    asd.Organisation_Name__c = c.Id;
    asd.ASIC_Renewal_Date__c = c.Next_Renewal_Date__c;
    asd.Status__c = 'Upcoming Renewal';
    insert asd;

    System.debug(
      'Asic Record created - Id is ' +
      asd.Id +
      ' and account Id is ' +
      asd.Organisation_Name__c
    );
  }

  static testMethod void test() {
    Test.startTest();
    batchCreateASICRecords bc = new batchCreateASICRecords();
    List<Account> testList = [
      SELECT Id, Next_Renewal_Date__c, ASIC_Due_Next_Month__c, Open_Renewals__c
      FROM Account
      WHERE ASIC_Due_Next_Month__c = TRUE AND Open_Renewals__c = 0
    ];
    System.assertEquals(testList.size(), 1);
    Database.QueryLocator ql = bc.start(null);
    bc.execute(null, testList);
    bc.Finish(null);
    Test.stopTest();
  }
}