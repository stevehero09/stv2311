@isTest
public class unsubscribeTest {
  @isTest
  public static void testUnsubscribe() {
    Messaging.InboundEmail emailUnsub = new Messaging.InboundEmail();
    Messaging.InboundEnvelope envUnsub = new Messaging.InboundEnvelope();
    Messaging.InboundEmail email = new Messaging.InboundEmail();
    Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();

    List<Lead> leadList = new List<Lead>();
    List<Contact> conList = new List<Contact>();

    Lead l = new lead(
      firstName = 'Jim',
      lastName = 'TestCase',
      Company = 'TestCo',
      Email = 'jim@testco.com',
      HasOptedOutOfEmail = false
    );
    leadList.add(l);

    Contact c = new Contact(
      firstName = 'Jim',
      lastName = 'TestCase',
      Email = 'jim@testco.com',
      HasOptedOutOfEmail = false
    );
    conList.add(c);

    Lead l2 = new lead(
      firstName = 'Jane',
      lastName = 'Testperson',
      Company = 'TestAcme',
      Email = 'jane@testacme.com',
      HasOptedOutOfEmail = false
    );
    leadList.add(l2);

    Contact c2 = new Contact(
      firstName = 'Jane',
      lastName = 'TestPerson',
      Email = 'jane@testacme.com',
      HasOptedOutOfEmail = false
    );
    conList.add(c2);

    insert leadlist;
    insert conList;

    emailUnsub.subject = 'test unsubscribe test';
    envUnsub.fromAddress = 'jim@testco.com';
    unsubscribe unsubscribeObj = new unsubscribe();
    unsubscribeObj.handleInboundEmail(emailUnsub, envUnsub);

    email.subject = 'test';
    env.fromAddress = 'jane@testacme.com';
    unsubscribe unsubscribeObj2 = new unsubscribe();
    unsubscribeObj2.handleInboundEmail(email, env);

    Lead stillSubbed = [
      SELECT Id, email, HasOptedOutofEmail
      FROM Lead
      WHERE Email = 'jane@testacme.com'
    ];
    System.assertEquals(stillSubbed.HasOptedOutOfEmail, false);

    Contact stillSubscribed = [
      SELECT Id, email, HasOptedOutofEmail
      FROM Contact
      WHERE Email = 'jane@testacme.com'
    ];
    System.assertEquals(stillSubscribed.HasOptedOutOfEmail, false);

    Lead notSubbed = [
      SELECT Id, email, HasOptedOutofEmail
      FROM Lead
      WHERE Email = 'jim@testco.com'
    ];
    System.assertEquals(notSubbed.HasOptedOutOfEmail, true);

    Contact notSubscribed = [
      SELECT Id, email, HasOptedOutofEmail
      FROM Contact
      WHERE Email = 'jim@testco.com'
    ];
    System.assertEquals(notSubscribed.HasOptedOutOfEmail, true);
  }
}