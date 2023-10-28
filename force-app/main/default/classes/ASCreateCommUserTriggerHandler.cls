/*
* @author: Elly Dan Harvey L. Mahinay
* @date: Febuary 12, 2020
* @class name: ASCreateCommUserTriggerHandler
* @description: trigger handler for ASCreateCommUserTrigger
* Jira Ticket: APSFSP-18
* @parameter(s): 
* @return: none
* @updated : No
* @updated by: 
* @updated Date:
* @description of the update:
*/
public class ASCreateCommUserTriggerHandler {

    public static Boolean runOnce = false;

    /*
    * @author: Elly Dan Harvey L. Mahinay
    * @date: Febuary 12, 2020
    * @method name: checkPortalContact
    * @description: class method for creating User
    * Jira Ticket: APSFSP-18
    * @parameter(s): 
    * @return: none
    * @updated : No
    * @updated by: 
    * @updated Date:
    * @description of the update:
    */
    public static void checkPortalContact(List<npe5__Affiliation__c> affiliationList) {

        Set<String> fnameAffSet = new Set<String>();
        Set<String> lnameAffSet = new Set<String>();
        Set<String> emailAffSet = new Set<String>();
        Set<String> contIdAffSet = new Set<String>();
        Set<String> usernameSet = new Set<String>();
        Set<Id> contactIdSet = new Set<Id>();

        List<User> newUserList = new List<User>();

        Map<Id,Contact> contIdAffMap = new Map<Id,Contact>();
        Map<String,User> userRecMap = new Map<String,User>();

        for(npe5__Affiliation__c affiliationListRec0 : affiliationList) { contIdAffSet.add(affiliationListRec0.npe5__Contact__c); }

        for(Contact conRec : [SELECT Id, FirstName, Lastname, Email From Contact Where Id In :contIdAffSet]) {

            fnameAffSet.add(conRec.FirstName);
            lnameAffSet.add(conRec.Lastname);
            emailAffSet.add(conRec.Email);

            contIdAffMap.put(conRec.Id, conRec);
        }

        for(User userRec1 : [SELECT Id, ContactId From User]) {
            contactIdSet.add(userRec1.ContactId);
        }

        for(User userRec : [SELECT Id, ContactId, FirstName, Lastname, Email, Username From User Where FirstName In :fnameAffSet And Lastname In :lnameAffSet And Email In:emailAffSet]) {

            String uFname = userRec.FirstName; String uLname = userRec.Lastname; String uEmail = userRec.Email; userRecMap.put((uFname+uLname+uEmail).toLowerCase(),userRec); usernameSet.add(userRec.Username);
        }
        
        for(npe5__Affiliation__c affiliationListRec : affiliationList) {
                
            if(contIdAffMap.containsKey(affiliationListRec.npe5__Contact__c)) {

                String affFname = contIdAffMap.get(affiliationListRec.npe5__Contact__c).FirstName;
                String affLname = contIdAffMap.get(affiliationListRec.npe5__Contact__c).LastName;
                String affEmail = contIdAffMap.get(affiliationListRec.npe5__Contact__c).Email;

                if(affiliationListRec.Portal_Contact__c && !userRecMap.containsKey((affFname+affLname+affEmail).toLowerCase()) ) {

                    String nickn = affFname;

                    String userNames = affEmail;


                    if(!contactIdSet.contains(affiliationListRec.npe5__Contact__c)) {

                        if(!usernameSet.contains(userNames)) insertUser(affFname, affLname, affEmail, affiliationListRec.npe5__Contact__c, nickn, String.valueOf(affFname).substring(0,1) + String.valueOf(affLname).substring(affLname.length()-2,affLname.length()), userNames);
                    }

                }
            }
        }
    }

    @future
	public static void insertUser(String affFname, String affLname, String affEmail, Id contId, String nickn, String aliases, String usern){

        User user = new User();  
        user.ProfileID = [SELECT Id From Profile Where Name='Customer Community Plus Login User (Custom)' limit 1].id;   
        user.EmailEncodingKey = 'UTF-8';   
        user.LanguageLocaleKey = 'en_US';   
        user.TimeZoneSidKey = 'Australia/Sydney';   
        user.LocaleSidKey = 'en_AU';   
        user.FirstName = affFname;   
        user.LastName = affLname;   
        user.Username = usern;      
        user.CommunityNickname = nickn;   
        user.Alias = aliases;   
        user.Email = affEmail;   
        user.IsActive = true;   
        user.ContactId = contId;  
                
        if(!Test.isRunningTest()) {
            insert user;   
        }
    }
}