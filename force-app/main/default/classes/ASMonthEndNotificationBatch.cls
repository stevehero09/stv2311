//Note 30/08/2022 - addition of setSubject() to generateEmailMessage and  necessary supporting query addition. When using a template, subject should override coded, this wasn't occuring in this case, resulting in blank subject line and necessary addition of setSubject.

// DONE 00023679 04/01/2023 - the exception uses the full list of processed accounts in the exception record, not just those who have failed.
/* Can create a method without the account ids as an easy fix, but this should be improved in case of >1 failures. Update to pass the error type and exception to new AS_ExceptionHandler class method. Will the list of processedIds ever be required in an email to end user?
 */

public class ASMonthEndNotificationBatch implements Database.Batchable<sObject>, Database.Stateful {
  private String investmentOption;
  private Boolean hasError; //Ensures that the batch doesn't run any logic if an error has occurred
  private String errorType;
  private Exception excObj;
  private Id networkId;
  private EmailTemplate emailTemplate;
  private OrgWideEmailAddress owa;

  private List<Id> processedAccountIds;

  public ASMonthEndNotificationBatch(String investmentOption) {
    this.investmentOption = investmentOption;
    this.hasError = false;
    this.processedAccountIds = new List<Id>();

    List<Network> networks = [SELECT Id, Name FROM Network WHERE Name = 'APS Foundation Portal' LIMIT 1];
    System.debug('networks = ' + networks);
    Network network = networks.get(0);
    System.debug('network = ' + network);
    this.networkId = network.Id;

    this.emailTemplate = [SELECT Id, Name, Body, Subject FROM EmailTemplate WHERE Name = 'Balance Update Notification' LIMIT 1];

    System.debug('this.emailTemplateId = ' + this.emailTemplate);

    this.owa = [SELECT Id, Address, DisplayName FROM OrgWideEmailAddress WHERE DisplayName = 'APS Foundation'];
  }

  public Database.QueryLocator start(Database.BatchableContext bc) {
    String query = '';

    try {
      Id orgRT = Schema.SObjectType.Account.getRecordTypeInfosByName().get('APS Foundation Giving Fund').getRecordTypeId();

      query +=
        'SELECT ' +
        'Id, Name, npe5__Contact__c, npe5__Contact__r.Email, npe5__Organization__c, npe5__Organization__r.Name ' +
        'FROM npe5__Affiliation__c ' +
        'WHERE ' +
        'npe5__Organization__r.RecordTypeId = :orgRT AND ' +
        'npe5__Organization__r.Status__c = \'Active\' AND ' +
        'Key_Contact__c = TRUE ';

      switch on this.investmentOption {
        when 'General Portfolio', 'Focused Portfolio' {
          query += 'AND ' + 'npe5__Organization__r.Investment_Portfolio__c = \'' + this.investmentOption + '\'';
        }
        when 'Both' {
          query +=
            'AND ' +
            '(npe5__Organization__r.Investment_Portfolio__c = \'General Portfolio\' OR ' +
            'npe5__Organization__r.Investment_Portfolio__c = \'Focused Portfolio\')';
        }
      }

      System.debug('query = ' + query);
    } catch (Exception e) {
      this.hasError = true;
      this.excObj = e;
      this.errorType = 'Query error';

      System.debug('e = ' + e);
    }

    return Database.getQueryLocator(query);
  }

  public void execute(Database.BatchableContext bc, List<npe5__Affiliation__c> scope) {
    if (scope.size() > 0) {
      try {
        Set<Id> affiliateContactUserIdsSet = new Set<Id>();
        List<FeedItem> feedItemsToCreate = new List<FeedItem>();
        List<Messaging.SingleEmailMessage> emailMessagesToSend = new List<Messaging.SingleEmailMessage>();
        Map<Id, npe5__Affiliation__c> contactIdAffiliationMap = new Map<Id, npe5__Affiliation__c>();
        List<ConnectApi.BatchInput> batchInputs = new List<ConnectApi.BatchInput>();

        for (npe5__Affiliation__c affiliation : scope) {
          if (affiliation.npe5__Contact__c != null) {
            affiliateContactUserIdsSet.add(affiliation.npe5__Contact__c);
            contactIdAffiliationMap.put(affiliation.npe5__Contact__c, affiliation);
            this.processedAccountIds.add(affiliation.npe5__Organization__c);
          }
        }

        for (User affiliateContactUser : [
          SELECT Id, Name, ContactId, AS_Email_Notification_Preferences__c
          FROM User
          WHERE ContactId IN :affiliateContactUserIdsSet
        ]) {
          // post to chatter
          ConnectApi.BatchInput batchInput = new ConnectApi.BatchInput(this.generateFeedItemInput(affiliateContactUser.Id));
          batchInputs.add(batchInput);

          npe5__Affiliation__c affiliation = contactIdAffiliationMap.get(affiliateContactUser.ContactId);

          if (
            affiliateContactUser.AS_Email_Notification_Preferences__c == 'Enable email notifications' &&
            (affiliation.npe5__Contact__r.Email != null &&
            affiliation.npe5__Contact__r.Email != '')
          ) {
            // email alert
            Messaging.SingleEmailMessage newEmailMessage = this.generateEmailMessage(
              affiliation.Id,
              affiliation.npe5__Contact__c,
              affiliation.npe5__Contact__r.Email,
              affiliation.npe5__Organization__r.Name
            );
            emailMessagesToSend.add(newEmailMessage);
          }
        }

        System.debug('feedItemsToCreate = ' + feedItemsToCreate);
        System.debug('emailMessagesToSend = ' + emailMessagesToSend);

        // insert feedItemsToCreate;
        if (!Test.isRunningTest())
          ConnectApi.ChatterFeeds.postFeedElementBatch(this.networkId, batchInputs);

        //DONE 00023679- month end bounced email error shows all orgs, not just bounced. Fix to only show genuine errors
        /*Adding the false value to the sendEmail allornothing element produces no exceptions. Leaving as is so notifications on bounced email are sent. Note - This contravenes SF documented APEX behaviour for this function. https://developer.salesforce.com/docs/atlas.en-us.apexref.meta/apexref/apex_classes_email_outbound_messaging.htm#apex_System_Messaging_sendEmail
         */
        List<Messaging.SendEmailResult> emailResults = Messaging.sendEmail(emailMessagesToSend);

        //TODO - force exception for testing
        // if (Test.isRunningTest()) {
        //   throw new EmailException('Email Exception occurred for testing');
        // }

        for (Messaging.SendEmailResult emailResult : emailResults) {
          if (emailResult.isSuccess()) {
            System.debug('Email send success');
          } else {
            System.debug('Email send failed: ' + emailResult.getErrors());
          }
        }
      } catch (Exception e) {
        this.hasError = true;
        this.excObj = e;
        this.errorType = 'Notification error';
      }
    }
  }
  //TODO - what if >1 error - need to handle both
  public void finish(Database.BatchableContext bc) {
    if (this.hasError && this.errorType != 'Notification Error') {
      //if (this.hasError) {
      // Create Exception record and send email
      AS_ExceptionHandler.createExceptionRecord(this.excObj, 'Month End Notification', 'ASMonthEndNotificationBatch', this.processedAccountIds);
    }
    if (this.hasError && this.errorType == 'Notification Error') {
      AS_ExceptionHandler.createNotificationExceptionRecord(this.excObj, 'Month End Notification', 'ASMonthEndNotificationBatch');
    }
  }

  private ConnectApi.FeedItemInput generateFeedItemInput(Id userId) {
    ConnectApi.FeedItemInput input = new ConnectApi.FeedItemInput();

    input.subjectId = userId;

    ConnectApi.MessageBodyInput body = new ConnectApi.MessageBodyInput();
    body.messageSegments = new List<ConnectApi.MessageSegmentInput>();

    ConnectApi.TextSegmentInput textSegment = new ConnectApi.TextSegmentInput();
    textSegment.text = 'The Balance for your giving fund has been updated to reflect last month’s investment returns. Navigate to the Home page to view the updated Balance and investment returns applied since inception and financial year to date. Month to month investment returns can be viewed on the Fund Activity page.';

    body.messageSegments.add(textSegment);
    input.body = body;

    return input;
  }

  private Messaging.SingleEmailMessage generateEmailMessage(Id affiliationId, Id contactId, String email, String orgName) {
    Messaging.SingleEmailMessage renderedEmailTemplate = Messaging.renderStoredEmailTemplate(this.emailTemplate.Id, contactId, affiliationId);

    Messaging.SingleEmailMessage newEmailMessage = new Messaging.SingleEmailMessage();
    newEmailMessage.setToAddresses(new List<String>{ email });
    newEmailMessage.setTargetObjectId(contactId);
    newEmailMessage.setTemplateId(this.emailTemplate.Id);
    newEmailMessage.setSubject(orgName + ' - Balance Update');
    newEmailMessage.setWhatId(affiliationId);
    newEmailMessage.setHtmlBody(renderedEmailTemplate.getHtmlBody());
    newEmailMessage.setOrgWideEmailAddressId(this.owa.Id);
    // newEmailMessage.setPlainTextBody(this.emailTemplate.Body);

    return newEmailMessage;
  }
}