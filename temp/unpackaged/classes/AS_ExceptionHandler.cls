/**
 * Created by Jase Brandhon Gerona on 09/08/2021.
 * Description : Insert Exception error on AS_Exception__c object for better capture of the error messages and keep an audit trail of errors.
 * Test Class: AS_ExceptionHandlerTest
 * Ticket : APSFB-15
 */
public class AS_ExceptionHandler {
  /**
   * Create a record on AS_Exception__c object
   *
   * @param excptn Exemption Error from ASMonthEndTriggerHandler class.
   * @param function Name of the function that causing the error.
   * @param triggerOrClass Name of the Trigger Or Class that causing the error
   *
   * @return None.
   */

  public static void createException(Exception excptn, String function, String triggerOrClass, Id monthEndId) {
    AS_Exception__c newRec = new AS_Exception__c(
      AS_Trigger_Class__c = triggerOrClass,
      AS_Function_Executed__c = function,
      AS_DateTime__c = datetime.now(),
      AS_User__c = UserInfo.getUserId(),
      AS_Error_Encountered__c = excptn.getMessage(),
      AS_Full_Error__c = excptn.getMessage() + ' - ' + excptn.getStackTraceString()
    );

    insert newRec;

    //Send email for exception
    AS_Month_End__c monthEnd = [SELECT Id, Name FROM AS_Month_End__c WHERE Id = :monthEndId];
    AS_Exception__c exRec = [SELECT Id, Name FROM AS_Exception__c WHERE Id = :newRec.Id];

    String addText = '';
    if (function == 'Month End') {
      addText = 'The Roll Back batch has been automatically initiated to roll back the failed Month End.';
    } else if (function == 'Roll Back') {
      addText = 'Please try initiating the Roll Back batch again.';
    }

    String body =
      '<div style="font-family:arial;line-height:5px;">' +
      +'<p>Dear ' +
      UserInfo.getFirstName() +
      ',<p><br/>' +
      +'<p>The ' +
      function +
      ' Process you initiated has unfortunately failed.</p>' +
      +'<p>' +
      addText +
      '</p>' +
      +'<p>Click here to see the relevant Month End and Exception record:</p>' +
      +'<p><a href="' +
      URL.getSalesforceBaseUrl().toExternalForm() +
      '/' +
      monthEnd.Id +
      '">' +
      monthEnd.Name +
      '</a></p>' +
      +'<p><a href="' +
      URL.getSalesforceBaseUrl().toExternalForm() +
      '/' +
      exRec.Id +
      '">' +
      exRec.Name +
      '</a></p><br/>' +
      +'<p>Kind regards,</p>' +
      +'<p>Operations</p>' +
      +'</div>';

    List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
    List<String> sendTo = new List<String>();
    sendTo.add(UserInfo.getUserEmail());
    mail.setToAddresses(sendTo);
    mail.setSubject(function + ' Process Error');
    mail.setHtmlBody(body);
    mails.add(mail);
    Messaging.sendEmail(mails);
  }

  public static void createExceptionRecord(Exception excptn, String function, String triggerOrClass, List<Id> accountIds) {
    String body = '';

    AS_Exception__c newRec = new AS_Exception__c(
      AS_Trigger_Class__c = triggerOrClass,
      AS_Function_Executed__c = function,
      AS_DateTime__c = datetime.now(),
      AS_User__c = UserInfo.getUserId(),
      AS_Error_Encountered__c = excptn.getMessage(),
      AS_Full_Error__c = excptn.getMessage() + ' - ' + excptn.getStackTraceString()
    );

    insert newRec;

    List<Account> accs = [SELECT Id, Name FROM Account WHERE Id IN :accountIds];
    System.debug(accs);
    AS_Exception__c exRec = [SELECT Id, Name FROM AS_Exception__c WHERE Id = :newRec.Id];

    body =
      '<div style="font-family:arial;line-height:5px;">' +
      +'<p>Dear ' +
      UserInfo.getFirstName() +
      ',<p><br/>' +
      +'<p>The ' +
      function +
      ' process you initiated may have failed or partially failed due to a Query error.</p>' +
      +'<p>Click here to see the relevant Accounts and Exception record:</p>';

    for (Account acc : accs) {
      body = body + '<ul><li><a href="' + URL.getSalesforceBaseUrl().toExternalForm() + '/' + acc.Id + '">' + acc.Name + '</a></li></ul>';
    }

    body +=
      '<ul><li><a href="' +
      URL.getSalesforceBaseUrl().toExternalForm() +
      '/' +
      exRec.Id +
      '">' +
      exRec.Name +
      '</a></p></li></ul>' +
      +'<br/><p>Kind regards,</p>' +
      +'<p>Operations</p>' +
      +'</div>';

    List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
    List<String> sendTo = new List<String>();
    sendTo.add(UserInfo.getUserEmail());
    mail.setToAddresses(sendTo);
    mail.setSubject(function + ' Process Error');
    mail.setHtmlBody(body);
    mails.add(mail);
    Messaging.sendEmail(mails);
  }

  public static void createNotificationExceptionRecord(Exception excptn, String function, String triggerOrClass) {
    String body = '';

    AS_Exception__c newRec = new AS_Exception__c(
      AS_Trigger_Class__c = triggerOrClass,
      AS_Function_Executed__c = function,
      AS_DateTime__c = datetime.now(),
      AS_User__c = UserInfo.getUserId(),
      AS_Error_Encountered__c = excptn.getMessage(),
      AS_Full_Error__c = excptn.getMessage() + ' - ' + excptn.getStackTraceString()
    );

    insert newRec;

    AS_Exception__c exRec = [SELECT Id, Name FROM AS_Exception__c WHERE Id = :newRec.Id];

    body =
      '<div style="font-family:arial;line-height:5px;">' +
      +'<p>Dear ' +
      UserInfo.getFirstName() +
      ',<p><br/>' +
      +'<p>The ' +
      function +
      ' process you initiated may have failed or partially failed due to a notification error. </p>' +
      '<p>Click here to see the relevant Exception information and record:</p>';

    body +=
      '<a href="' +
      URL.getSalesforceBaseUrl().toExternalForm() +
      '/' +
      exRec.Id +
      '">' +
      exRec.Name +
      '</a></p>' +
      +'<p>The reason for this failure is : </p>' +
      excptn.getMessage() +
      '<br/><p>Kind regards,</p>' +
      +'<p>Operations</p>' +
      +'</div>';

    List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
    List<String> sendTo = new List<String>();
    sendTo.add(UserInfo.getUserEmail());
    mail.setToAddresses(sendTo);
    mail.setSubject(function + ' - Notification Error');
    mail.setHtmlBody(body);
    mails.add(mail);
    Messaging.sendEmail(mails);
  }
}