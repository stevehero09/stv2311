@isTest
public class batchContactEmailUpdateTest {
  @testSetup
  public static void testSetup() {
    List<Contact> contactList = new List<Contact>();

    Id accRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName()
      .get('APS Foundation Giving Fund')
      .getRecordTypeId();

    Account a = new Account();
    a.Name = 'Test account';
    a.RecordTypeId = accRecordTypeId;
    insert a;

    System.debug('Account id' + a.id);

    for (integer i = 0; i < 10; i++) {
      Contact con = new Contact();
      con.accountId = a.Id;
      con.LastName = 'Lasty' + i;
      con.Preferred_Name__c = 'Pref' + i + con.LastName;
      con.email = i + con.LastName + '@company.com';
      con.Personal_Email__c = i + con.LastName + 'personal@company.com';
      con.Work_Email__c = i + con.LastName + 'work@company.com';
      con.Asst_Email__c = i + con.LastName + 'asst@company.com';
      con.Alternate_Email__c = i + con.LastName + 'alt@company.com';
      con.Preferred_Email__c = 'Personal';  
      contactList.add(con);
    }
    Contact conNoEmail = new Contact();
    conNoEmail.LastName = 'LastyNoMail';
    conNoEmail.Preferred_Name__c = 'PrefNoEmail' + conNoEmail.LastName;
    conNoEmail.accountId = a.id;
    contactList.add(conNoEmail);

    insert contactList;
    System.debug('Contact List size' + contactList.size());
  }

  static testMethod void test() {
    Test.startTest();
    BatchContactEmailUpdate bc = new BatchContactEmailUpdate();
    List<Contact> testList = [
      SELECT
        Id,
        email,
        Personal_Email__c,
        Work_Email__c,
        Asst_Email__c,
        Alternate_Email__c
      FROM Contact
      WHERE
        email != NULL
        OR Personal_Email__c != NULL
        OR Work_Email__c != NULL
        OR Asst_Email__c != NULL
        OR Alternate_Email__c != NULL
    ];
    Database.QueryLocator ql = bc.start(null);
    bc.execute(null, testList);
    bc.Finish(null);
    
    // System.assertEquals(10,[SELECT COUNT() FROM Contact WHERE email = 'e@mail.com'] );
    // TODO - add assertions, could do with some more varied test data
    Test.stopTest();
  }
}