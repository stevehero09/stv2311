@isTest
public class batchContactPhoneUpdateTest {
  @testSetup
  public static void testSetup() {
    List<Contact> contactList = new List<Contact>();

    Id accRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName()
      .get('APS Foundation Giving Fund')
      .getRecordTypeId();

    Account a = new Account();
    a.Name = 'Test Phone Update Account';
    a.RecordTypeId = accRecordTypeId;
    insert a;

    System.debug('Account id' + a.id);

    String p1 = '01  234 56 9';

    for (integer i = 0; i < 10; i++) {
      Contact con = new Contact();
      con.accountId = a.Id;
      con.LastName = 'Lasty' + i;
      con.Preferred_Name__c = 'Pref' + i + con.LastName;
      con.HomePhone = p1 + i;
      con.Work_Phone__c = p1; 
      con.Mobile_Phone__c= p1;  
      con.OtherPhone = p1;
      con.Phone = p1;  
      

      contactList.add(con);
    }
    Contact conNoPhone = new Contact();
    conNoPhone.LastName = 'LastyNoPhone';
    conNoPhone.Preferred_Name__c = 'Pref' + conNoPhone.LastName;
    conNoPhone.accountId = a.id;
   
      
    contactList.add(conNoPhone);

    Contact conNoSpacePhone = new Contact();
    conNoSpacePhone.LastName = 'LastyNoSpacePhone';
    conNoSpacePhone.Preferred_Name__c = 'Pref' + conNoSpacePhone.LastName;
    conNoSpacePhone.accountId = a.id;
    conNoSpacePhone.HomePhone = '987654321';
    
    
    contactList.add(conNoSpacePhone);

    insert contactList;
    System.debug('Contact List size' + contactList.size());
  }

  static testMethod void test() {
    Test.startTest();
    BatchContactPhoneUpdate bcpu = new BatchContactPhoneUpdate();
    List<Contact> testList = [
      SELECT
        Id,
        LastName,
        Phone,
        HomePhone,
        MobilePhone,
        OtherPhone,
        Mobile_Phone__c,
        Work_Phone__c
      FROM Contact
      WHERE
        HomePhone != NULL
        OR Mobile_phone__c != NULL
        OR Work_Phone__c != NULL
        OR OtherPhone != NULL
        OR MobilePhone != NULL
        OR Phone != NULL
        OR Work_Phone__c != NULL
    ];
    Database.QueryLocator ql = bcpu.start(null);
    bcpu.execute(null, testList);
    bcpu.Finish(null);

    //TODO - Add assertions
    Test.stopTest();
  }
}