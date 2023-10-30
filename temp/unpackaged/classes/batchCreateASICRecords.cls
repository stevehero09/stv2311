global class batchCreateASICRecords implements Database.Batchable<SObject>, Database.Stateful {
  global Integer accountsProcessed = 0;
  global Integer ASICRecordsCreated = 0;
  global Integer ASICRecordsNotCreated = 0;
  public List<ASIC_Solvency_Declaration__c> asdList = new List<ASIC_Solvency_Declaration__c>();

  public Database.SaveResult[] resultsList;
  private Exception excObj;

  public String[] toAddresses = new List<string>();
  public String[] ccAddresses = new List<string>();
  public String subject = 'The ASIC solvency record creator class has run. ';
  public String displayName = 'ASIC Record Creator';
  public String msgBodyText = '';
  public Boolean hasError = false;

  global Database.queryLocator start(Database.BatchableContext bc) {
    return Database.getQueryLocator('SELECT Id, Next_Renewal_Date__c, ASIC_Due_Next_Month__c, Open_Renewals__c, Name FROM Account WHERE ASIC_Due_Next_Month__c=true AND Open_Renewals__c=0');
  }

  global void execute(Database.batchableContext bc, List<Account> scope) {
    asdList.clear();
    if (scope.size() > 0 && scope != null) {
    }

    for (Account acc : scope) {
      //create the ASIC solvency record if there is no open renewal
      if (acc.Open_Renewals__c == 0) {
        ASIC_Solvency_Declaration__c asd = new ASIC_Solvency_Declaration__c();
        asd.Organisation_Name__c = acc.Id;
        asd.ASIC_Renewal_Date__c = acc.Next_Renewal_Date__c;
        asd.Status__c = 'Upcoming Renewal';
        asdList.add(asd);
        accountsProcessed += 1;
      }
    }

    try {
      resultsList = Database.insert(asdList, false);
      for (Database.SaveResult rl : resultsList) {
        if (rl.isSuccess()) {
          System.debug('Created ASIC record ' + rl.getId());
          ASICRecordsCreated += 1;
        } else {
          for (Database.Error err : rl.getErrors()) {
            System.debug('The following error has occurred.');
            System.debug(err.getStatusCode() + ': ' + err.getMessage());
            System.debug('ASIC record not created : ' + err.getFields());
            msgBodyText += 'The following error occurred: ' + err.getStatusCode() + ': ' + err.getMessage() + '. ' + 'ASIC record not created: ' + err.getFields();
            ASICRecordsNotCreated += 1;
          }
        }
      }
    } catch (Exception e) {
      hasError = true;
      excObj = e;
    }
  }

  global void finish(Database.batchableContext bc) {
    System.debug(accountsProcessed + ' Accounts with ASIC due next month processed');

    System.debug(ASICRecordsCreated + ' ASIC Solvency records created');

    subject += 'Accounts with ASIC due next month have been processed - ' + ASICRecordsCreated + ' ASIC records created from ' + accountsProcessed + ' total matching organisation records.';

    if (msgBodyText.length() == 0) {
      msgBodyText += subject;
    }

    AlertEmails__mdt[] alertmails = [SELECT Masterlabel, UserEmail__c, ContactOverwrite__c FROM AlertEmails__mdt WHERE All__c = TRUE];

    for (AlertEmails__mdt amail : alertmails) {
      if (amail.UserEmail__c != null) {
        toAddresses.add(amail.UserEmail__c);
        System.debug(amail.UserEmail__c);
      }
    }

    CustomSendMail.sendmail(toAddresses, ccAddresses, displayName, subject, msgBodyText);

    if (hasError) {
      exceptionHandler.createNewException(excObj, 'DatabaseCreate', 'batchCreateASICRecords');
    }
  }
}