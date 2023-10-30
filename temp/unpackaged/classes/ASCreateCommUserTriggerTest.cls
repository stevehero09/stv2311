/*
* @author: Elly Dan Harvey L. Mahinay
* @date: Febuary 13, 2020
* @class name: ASCreateCommUserTriggerTest
* @description: Apex test class for ASCreateCommUserTrigger
* Jira Ticket: APSFSP-18
* @parameter(s): 
* @return: none
* @updated : No
* @updated by: 
* @updated Date:
* @description of the update:
*/
@isTest
public class ASCreateCommUserTriggerTest {

    /*
    * @author: Elly Dan Harvey L. Mahinay
    * @date: Febuary 13, 2020
    * @Method name: setup
    * @description: testSetup method
    * @parameter(s): none
    * @return: none
    * @updated : No
    * @updated by: 
    * @updated Date:
    * @description of the update:
    */
    @testSetup static void setup() {
        
        Id orgRT = Schema.SObjectType.Account.getRecordTypeInfosByName().get('APS Foundation Giving Fund').getRecordTypeId();
        
        Account newAcc = new Account(
            RecordTypeId = orgRT,
            Name = 'Test Giving Fund 1',
            Balance__c = 20000000,
            Status__c = 'Active',
            Investment_Portfolio__c = 'General Portfolio'
        );
        insert newAcc;

        Contact newCon = new Contact(
            FirstName = 'felse',
            Lastname = 'welse',
            Email = 'felse@welse.com'
        );
        insert newCon;

        npe5__Affiliation__c newAff = new npe5__Affiliation__c(
            Key_Contact__c = true,
            Portal_Contact__c = true,
            Position__c = 'Director',
            npe5__Organization__c = newAcc.Id,
            npe5__Contact__c = newCon.Id
        );
        insert newAff;
    }

    /*
    * @author: Elly Dan Harvey L. Mahinay
    * @date: February 13, 2020
    * @Method name: ASCreateCommUserTriggerTest_1
    * @description: test scenario 1 for creating User
    * @parameter(s): none
    * @return: none
    * @updated : No
    * @updated by: 
    * @updated Date:
    * @description of the update:
    */
    static testMethod void ASCreateCommUserTriggerTest_1() {

        List<npe5__Affiliation__c> affList = [SELECT Id, Key_Contact__c, Portal_Contact__c, Position__c, npe5__Organization__c, npe5__Contact__c FROM npe5__Affiliation__c Where Position__c = 'Director' limit 1];        

        List<Contact> conList = [SELECT Id, FirstName FROM Contact Where Id = :affList[0].npe5__Contact__c limit 1];
        system.assertEquals(conList.size()>0, true);
    }
}