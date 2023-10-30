global class batchContactPhoneUpdate implements Database.Batchable<SObject>, Database.Stateful {
  global Integer contactsProcessed = 0;
  global Integer contactsUpdated = 0;
  global Integer contactsNotUpdated = 0;
  public Database.SaveResult[] resultsList;
  private Exception excObj;
  public String[] toAddresses = new List<string>();
  public String[] ccAddresses = new List<string>();
  public String subject = 'The Contact phone update class has run - ';
  public String displayName = 'Contact Phone Update - Remove spaces';
  public String msgBodyText = '';
  public Boolean hasError = false;

  global Database.queryLocator start(Database.BatchableContext bc) {
    return Database.getQueryLocator('SELECT Id, LastName, Phone, HomePhone, MobilePhone, OtherPhone, Mobile_Phone__c, Work_Phone__c  FROM Contact WHERE HomePhone!=null OR Mobile_phone__c!=null OR Work_Phone__c!=null OR OtherPhone!=null OR MobilePhone !=null OR Phone!=null');
  }

  global void execute(Database.batchableContext bc, List<Contact> scope) {
    list<Contact> updatePhoneList = new List<Contact>();
    updatePhoneList.clear();

    //Update the debug here
    if (scope.size() > 0 && scope != null) {
      for (Contact c : scope) {
        System.debug('Before loop: Id: ' + c.Id + 'Lastname: ' + c.LastName + ' Homephone: ' + c.HomePhone + ' Phone: ' + c.Phone + ' MobilePhone: ' + c.MobilePhone + 'OtherPhone: ' + c.OtherPhone + 'Mobile Phone Custom: ' + c.Mobile_Phone__c + 'Work Phone: ' + c.Work_Phone__c);

        if (
          (c.Phone != null && String.valueOf(c.Phone).containsWhitespace()) ||
          (c.MobilePhone != null && String.valueOf(c.MobilePhone).containsWhitespace()) ||
          (c.OtherPhone != null && String.valueOf(c.OtherPhone).containsWhitespace()) ||
          (c.HomePhone != null && String.valueOf(c.HomePhone).containsWhitespace()) ||
          (c.Work_Phone__c != null && String.valueOf(c.Work_Phone__c).containsWhitespace()) ||
          (c.Mobile_Phone__c != null && String.valueOf(c.Mobile_Phone__c).containsWhitespace())
        ) {
          if (c.Phone != null && String.valueOf(c.Phone).containsWhitespace()) {
            c.Phone = c.Phone.replaceAll('(\\s+)', '');
          }
          if (c.MobilePhone != null && String.valueOf(c.MobilePhone).containsWhitespace()) {
            c.MobilePhone = c.MobilePhone.replaceAll('(\\s+)', '');
          }
          if (c.OtherPhone != null && String.valueOf(c.OtherPhone).containsWhitespace()) {
            c.OtherPhone = c.OtherPhone.replaceAll('(\\s+)', '');
          }
          if (c.HomePhone != null && String.valueOf(c.HomePhone).containsWhitespace()) {
            c.HomePhone = c.HomePhone.replaceAll('(\\s+)', '');
          }
          if (c.Work_Phone__c != null && String.valueOf(c.Work_Phone__c).containsWhitespace()) {
            c.Work_Phone__c = c.Work_Phone__c.replaceAll('(\\s+)', '');
          }
          if (c.Mobile_Phone__c != null && String.valueOf(c.Mobile_Phone__c).containsWhitespace()) {
            c.Mobile_Phone__c = c.Mobile_Phone__c.replaceAll('(\\s+)', '');
          }

          System.debug('After loop, before update: Id: ' + c.Id + 'Lastname: ' + c.LastName + ' Homephone: ' + c.HomePhone + ' Phone: ' + c.Phone + ' MobilePhone: ' + c.MobilePhone + 'OtherPhone: ' + c.OtherPhone + 'Mobile Phone Custom: ' + c.Mobile_Phone__c + 'Work Phone: ' + c.Work_Phone__c);

          updatePhoneList.add(c);
          contactsProcessed = contactsProcessed += 1;
        }
      }
    }

    try {
      resultsList = Database.update(updatePhonelist, false);
      for (Database.SaveResult rl : resultsList) {
        if (rl.isSuccess()) {
          System.debug('Updated phone on Contact: ' + rl.getId());
          contactsUpdated += 1;
        } else {
          for (Database.Error err : rl.getErrors()) {
            System.debug('The following error has occurred.');
            System.debug(err.getStatusCode() + ': ' + err.getMessage());
            System.debug('Contact phone not updated : ' + err.getFields());
            msgBodyText += 'The following error occurred: ' + err.getStatusCode() + ': ' + err.getMessage() + '. ' + 'Contact phone not updated: ' + err.getFields();
            contactsNotUpdated += 1;
          }
        }
      }
    } catch (Exception e) {
      hasError = true;
      excObj = e;
    }
  }

  global void finish(Database.batchableContext bc) {
    System.debug(contactsUpdated + ' Contacts with phone numbers updated');

    System.debug(contactsUpdated + ' Contact Phone numbers updated');
    subject += contactsUpdated + ' of ' + contactsProcessed + ' were successfully updated by the batchContactPhoneUpdate class';

    AlertEmails__mdt[] alertmails = [SELECT Masterlabel, UserEmail__c, ContactOverwrite__c FROM AlertEmails__mdt WHERE All__c = TRUE];

    for (AlertEmails__mdt amail : alertmails) {
      if (amail.UserEmail__c != null) {
        toAddresses.add(amail.UserEmail__c);
        System.debug(amail.UserEmail__c);
      }
    }

    if (msgBodyText.length() == 0) {
      msgBodyText += 'No Errors';
    }
    CustomSendMail.sendmail(toAddresses, ccAddresses, displayName, subject, msgBodyText);

    if (hasError) {
      exceptionHandler.createNewException(excObj, 'DatabaseUpdate', 'batchContactPhoneUpdate');
    }
  }
}