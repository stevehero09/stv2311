/**
 * Created by Mel-Goldwyn T. Samar on September 13, 2021
 * Rolls back the recent Month End and its associated records
 */
/*
SR changes made - if the send email fails, the process is only partialy rolled back, no ccounts are updated and the data is corrupted and requires manual intervention.
Updating to roll back to the original save pt if anything fails.
*/
public class ASMonthEndRollback implements Database.Batchable<sObject>, Database.Stateful {
  public AS_Month_End__c monthEnd; //Stores the month end to be rolled back
  private Boolean hasError; //Ensures that the batch won't run its logic if an error has occurred
  private Set<Id> accountIds; //Stores Account Ids to update balance
  private Exception excObj;
  private List<AS_Statement_Line_Item__c> lst_sli_toarchive = new List<AS_Statement_Line_Item__c>();
  String newMonthEndName = '';

  public ASMonthEndRollback(AS_Month_End__c monthEnd) {
    this.monthEnd = monthEnd;
    this.accountIds = new Set<Id>();
    this.hasError = false;
  }

  public Database.QueryLocator start(Database.BatchableContext bc) {
    String query = '';

    try {
      Id monthEndId = this.monthEnd.Id;
      query = 'SELECT AS_Fund__c FROM AS_Statement_Line_Item__c WHERE AS_Month_End__c = :monthEndId';
    } catch (Exception ex) {
      this.hasError = true;
      this.excObj = ex;
    }
    return Database.getQueryLocator(query);
  }

  public void execute(Database.BatchableContext bc, List<AS_Statement_Line_Item__c> scope) {
    Savepoint sp = Database.setSavepoint(); //Savepoint to restore deleted statement line items in case of error - //SR, archived, not deleted
    try {
      Set<Id> sliIds = (new Map<Id, AS_Statement_Line_Item__c>(scope)).keySet();
      List<AS_Statement_Line_Item__c> statementLineItems = [SELECT AS_Fund__c FROM AS_Statement_Line_Item__c WHERE Id IN :sliIds FOR UPDATE];

      for (AS_Statement_Line_Item__c lineItem : statementLineItems) {
        if (lineItem.AS_Fund__c != null) {
          this.accountIds.add(lineItem.AS_Fund__c);
        }
        lineItem.archived__c = true;
        lst_sli_toarchive.add(lineItem);
      }

      if (lst_sli_toarchive.size() > 0) {
        update lst_sli_toarchive;
      }
    } catch (Exception ex) {
      this.hasError = true;
      this.excObj = ex;
      Database.rollback(sp); //Roll back in case of error
    }
  }

  public void finish(Database.BatchableContext bc) {
    //If no errors so far, archive Month End record and send Email for completion of Roll Back process
    if (!this.hasError) {
      Savepoint sp = Database.setSavepoint(); //SR - may not use this endpoint - results in an incomplete roll back
      try {
        newMonthEndName = [SELECT Id, Name FROM AS_Month_End__c WHERE Id = :monthEnd.Id].Name; //Gets the latest name of the Month End record
        String status = 'active';
        List<Account> updatedAccts = new List<Account>();
        List<Id> updatedAccts_ids = new List<Id>();
        for (Account acct : [
          SELECT Id, Name, Investment_Portfolio__c
          FROM Account
          WHERE Status__c = :status AND Investment_Portfolio__c = :monthEnd.AS_Investment_Option__c
        ]) {
          updatedAccts_ids.add(acct.Id);
        }

        System.debug('To Process List:' + updatedAccts_ids);

        if (updatedAccts_ids.size() > 0) {
          ASUpdateGivingFundGoalBatch updateGivingGoalBatch = new ASUpdateGivingFundGoalBatch(updatedAccts_ids);
          Database.executeBatch(updateGivingGoalBatch, 50);
        }

        //DONE - The sendEmail needs to be removed from the try catch block, as email errors (deliverability etc) cause a partial roll back is to be done, leaving unworkable data.
        //DONE - Ideally, add info to the body if an error occurred.
        // Send notification email of completion
      } catch (Exception ex) {
        this.hasError = true;
        this.excObj = ex;
        Database.rollback(sp); //Roll back in case of error
      }

      try {
        sendEmail(newMonthEndName);
      } catch (Exception ex) {
        this.hasError = true;
        this.excObj = ex;
      }
    }

    if (this.hasError) {
      AS_ExceptionHandler.createException(this.excObj, 'Roll Back', 'ASMonthEndRollback', this.monthEnd.Id);
    }
  }

  private void sendEmail(String monthEndName) {
    String body =
      '<div style="font-family:arial;line-height:5px;">' +
      +'<p>Dear ' +
      UserInfo.getFirstName() +
      ',<p><br/>' +
      +'<p>The Roll Back Process you initiated for ' +
      monthEndName +
      ' has been completed.</p><br/>' +
      +'<p>Kind regards,</p>' +
      +'<p>Operations</p>' +
      +'</div>';

    if (this.hasError) {
      body += 'An error has occurred, see the exception record for more information' + this.excObj;
    }

    List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
    List<String> sendTo = new List<String>();
    List<String> ccAddresses = new List<String>();

    AlertEmails__mdt[] alertmails = [SELECT Masterlabel, UserEmail__c, ContactOverwrite__c FROM AlertEmails__mdt WHERE All__c = TRUE];

    for (AlertEmails__mdt amail : alertmails) {
      if (amail.UserEmail__c != null) {
        ccAddresses.add(amail.UserEmail__c);
        System.debug(amail.UserEmail__c);
      }
    }

    sendTo.add(UserInfo.getUserEmail());
    mail.setToAddresses(sendTo);
    mail.setCCAddresses(ccAddresses);
    mail.setSubject('Roll Back Process Complete');
    mail.setHtmlBody(body);
    mails.add(mail);
    Messaging.sendEmail(mails);
  }
}