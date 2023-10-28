// Modified from the AS_Exception class created by Jase Brandhon Gerona @ Alphasys on 09/08/2021.

public class exceptionHandler {
  public static void createNewException(
    Exception excptn,
    String function,
    String triggerOrClass
  ) {
    AS_Exception__c expt = new AS_Exception__c();
    expt.AS_Trigger_Class__c = triggerOrClass;
    expt.AS_Function_Executed__c = function;
    expt.AS_DateTime__c = datetime.now();
    expt.AS_User__c = UserInfo.getUserId();
    expt.AS_Error_Encountered__c = excptn.getMessage();
    expt.AS_Full_Error__c =
      excptn.getMessage() +
      ' - ' +
      excptn.getStackTraceString();

    insert expt;

    //Send email for exception
    AS_Exception__c ex = [
      SELECT Id, Name
      FROM AS_Exception__c
      WHERE Id = :expt.Id
    ];
    List<String> sendTo = new List<String>();
    List<String> ccTo = new List<string>{
      'administrator@australianphilanthropicservices.com.au'
    };
    sendTo.add(UserInfo.getUserEmail());
    String subject = expt.AS_Trigger_Class__c + ' has encountered an error';
    String displayName = expt.AS_Trigger_Class__c;

    String body =
      '<div style="font-family:arial;line-height:5px;">' +
      +'<p>Dear ' +
      UserInfo.getFirstName() +
      ',<p><br/>' +
      +'<p>The ' +
      function +
      ' Process you initiated has unfortunately failed.</p>' +
      +'<p><a href="' +
      URL.getSalesforceBaseUrl().toExternalForm() +
      '/' +
      ex.Id +
      '">' +
      ex.Name +
      '</a></p><br/>' +
      +'<p>Kind regards,</p>' +
      +'<p>Operations</p>' +
      +'</div>';

    CustomSendMail.sendmail(sendTo, ccTo, displayName, subject, body);
  }
}