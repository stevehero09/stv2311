//The send email will fail if it runs on sandbox activation, due to deliverability being off.

global class batchContactEmailUpdate implements Database.Batchable<SObject>, Database.Stateful {
  //This class cannot run in production, and so doesn't write to the exception object.
  //Add the sandbox Id to the message

  global Integer contactsProcessed = 0;
  global Integer contactsUpdated = 0;
  global Integer contactsNotUpdated = 0;
  global String newMail = 'e@mail.com';
  public Database.SaveResult[] resultsList;
  public String[] toAddresses = new List<string>();
  public String[] ccAddresses = new List<string>();
  public String subject = 'The Contact email update class has run - ';
  public String displayName = 'Contact Email Overwrite for Sandboxes';
  public String msgBodyText = '';

  global Database.queryLocator start(Database.BatchableContext BC) {
    return Database.getQueryLocator('SELECT Id, email, Personal_Email__c, Work_Email__c, Asst_Email__c, Alternate_Email__c  FROM Contact WHERE email!=Null OR Personal_Email__c !=null OR Work_Email__c !=null OR Asst_Email__c !=null OR Alternate_Email__c !=null');
  }

  global void execute(Database.batchableContext bc, List<contact> scope) {
    Organization sbxOrg = [SELECT Id, IsSandbox FROM Organization];

    list<Contact> updateList = new List<Contact>();

    if (sbxOrg.isSandbox) {
      for (Contact c : scope) {
        if (c.email != null) {
          c.email = newmail;
        }
        if (c.Personal_Email__c != null) {
          c.Personal_Email__c = newmail;
        }
        if (c.Work_Email__c != null) {
          c.Work_Email__c = newmail;
        }
        if (c.Asst_Email__c != null) {
          c.Asst_Email__c = newmail;
        }
        if (c.Alternate_Email__c != null) {
          c.Alternate_Email__c = newmail;
        }

        updateList.add(c);
        contactsProcessed = contactsProcessed += 1;
      }

      Database.DMLOptions dml = new Database.DMLOptions();
      dml.DuplicateRuleHeader.allowSave = true;

      resultsList = Database.update(updatelist, dml);
      for (Database.SaveResult rl : resultsList) {
        if (rl.isSuccess()) {
          System.debug('Updated contact record: ' + rl.getId());
          contactsUpdated += 1;
        } else {
          for (Database.Error err : rl.getErrors()) {
            System.debug('The following error has occurred.');
            System.debug(err.getStatusCode() + ': ' + err.getMessage());
            System.debug('Contact not updated : ' + err.getFields());
            msgBodyText += 'The following error occurred: ' + err.getStatusCode() + ': ' + err.getMessage() + '. ' + 'Contact email not updated: ' + err.getFields();
            contactsNotUpdated += 1;
          }
        }
      }
    } else {
      System.debug('This class can only be run in a sandbox environment');
    }
  }
  global void finish(Database.batchableContext bc) {
    System.debug(contactsUpdated + ' Contact Emails Updated');
    subject += contactsUpdated + ' of ' + contactsProcessed + ' were successfully updated by the batchContactEmailUpdate class';

    if (msgBodyText.length() == 0) {
      msgBodyText += 'No Errors';
    }

    AlertEmails__mdt[] alertmails = [SELECT Masterlabel, UserEmail__c, ContactOverwrite__c FROM AlertEmails__mdt WHERE ContactOverwrite__c = TRUE];

    for (AlertEmails__mdt amail : alertmails) {
      if (amail.UserEmail__c != null) {
        ccAddresses.add(amail.UserEmail__c);
        System.debug(amail.UserEmail__c);
      }
    }

    String currentEmail = UserInfo.getUserEmail();
    toAddresses.add(currentEmail);

    CustomSendMail.sendmail(toAddresses, ccAddresses, displayName, subject, msgBodyText);
    //TODO - catch exceptions
  }
}