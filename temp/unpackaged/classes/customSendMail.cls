public with sharing class customSendMail {

    public static void sendmail(String[] toAddresses, String[] ccAddresses, String setDisplayName, String subject, String body ){

        Messaging.Singleemailmessage mail = new Messaging.Singleemailmessage();

        mail.setToAddresses(toAddresses);
        mail.setCCAddresses(ccAddresses);

        mail.setSenderDisplayName(setDisplayName);
        mail.setSubject(subject);
        mail.setPlainTextBody(body);
        mail.setHtmlBody(body);

        Messaging.sendEmail(new Messaging.Singleemailmessage[] {mail});

    }

}