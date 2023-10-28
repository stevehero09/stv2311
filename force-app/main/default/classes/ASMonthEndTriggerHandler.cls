/*
- Function Name: ASMonthEndTriggerHandler
- Author: Butch B. Enerio
- Date Created: February 6, 2020
- Short Description: trigger handler for Month End object.
- Long Description
- Jira Ticket: APSFSP-43
*/
public class ASMonthEndTriggerHandler {
  //static flag variable to enable/disable the trigger
  public static Boolean runTrigger = true;

  /*
   * @author: Butch B. Enerio
   * @date: February 6, 2020
   * @Method name: ASMonthEndTriggerHandler
   * @description: Constructor
   * @parameter(s): None
   * @return: None
   * @updated : No
   * @updated by:
   * @updated Date:
   * @description of the update:
   * @Jira Ticket: APSFSP-43
   */
  public ASMonthEndTriggerHandler() {
  }

  /*
   * @author: Butch B. Enerio
   * @date: February 6, 2020
   * @Method name: checkExistingMonthEnd
   * @description: method for validating if the month end record for that month already exists
   * @parameter(s): List<AS_Month_End__c> monthEndList
   * @return: None
   * @updated : No
   * @updated by:
   * @updated Date:
   * @description of the update:
   * @Jira Ticket: APSFSP-43
   */

   /*SR 06/03/23 - adding year comparison to the method below due to errors encountrred when running test classes - 00025902
   */
  public static void checkExistingMonthEnd(List<AS_Month_End__c> monthEndList) {
    Map<Integer, AS_Month_End__c> monthEndMap = new Map<Integer, AS_Month_End__c>();
    Map<Integer, AS_Month_End__c> monthEndYearMap = new Map<Integer, AS_Month_End__c>();
    List<AS_Month_End__c> existingMonthEndList = [
      SELECT Id, Effective_Date__c, AS_Investment_Option__c
      FROM AS_Month_End__c
      WHERE Effective_Date__c = THIS_YEAR AND AS_Investment_Option__c = :monthEndList.get(0).AS_Investment_Option__c AND archived__c = FALSE
    ];

    if (existingMonthEndList.size() > 0) {
      for (AS_Month_End__c mEnd : existingMonthEndList) {
        monthEndMap.put(mEnd.Effective_Date__c.month(), mEnd);
        monthEndYearMap.put(mEnd.Effective_Date__c.year(), mEnd);
      }
    }

    if (monthEndList.size() > 0) {
      for (AS_Month_End__c mEnd : monthEndList) {
        if (monthEndMap.containsKey(mEnd.Effective_Date__c.month()) && monthEndYearMap.containsKey(mEnd.Effective_Date__c.year())) {
          mEnd.addError(
            'Month End record for the month of ' +
            getMonthStr(mEnd.Effective_Date__c.month(), 0) +
            ' with Investment Option ' +
            mEnd.AS_Investment_Option__c +
            ' already exists.'
          );
        }
      }
    }
  }

  /*
   * @author: Butch B. Enerio
   * @date: February 6, 2020
   * @Method name: renameMonthEnd
   * @description: method for renaming the name
   * @parameter(s): List<AS_Month_End__c> monthEndList
   * @return: None
   * @updated : No
   * @updated by:
   * @updated Date:
   * @description of the update:
   * @Jira Ticket: APSFSP-43
   */
  public static void renameMonthEnd(List<AS_Month_End__c> monthEndList) {
    if (monthEndList.size() > 0) {
      for (AS_Month_End__c mEnd : monthEndList) {
        mEnd.Name = 'Month End ' + getMonthStr(mEnd.Effective_Date__c.month(), 1) + ' ' + String.valueOf(mEnd.Effective_Date__c.year());
      }
    }
  }

  // APSFB-13 - Moved this logic to ASMonthEndBatch batch class
  // /*
  // * @author: Butch B. Enerio
  // * @date: February 6, 2020
  // * @Method name: renameMonthEnd
  // * @description: method for generating the child records for month end and email notification
  // * @parameter(s): List<AS_Month_End__c> monthEndList
  // * @return: None
  // * @updated by: Romnick Hilot
  // * @updated Date: April 16, 2020
  // * @description of the update:
  // * @Jira Ticket: APSFSP-43 updated by APSFSP-51
  // */
  // public static void generateMonthEndRecords(List<AS_Month_End__c> monthEndList){
  //     try{
  //         Id orgRT = Schema.SObjectType.Account.getRecordTypeInfosByName().get('APS Foundation Giving Fund').getRecordTypeId();
  //         Id donationRT = Schema.SObjectType.AS_Transaction__c.getRecordTypeInfosByName().get('Donation').getRecordTypeId();
  //         Id giftRT = Schema.SObjectType.AS_Transaction__c.getRecordTypeInfosByName().get('Gift').getRecordTypeId();
  //         Id adjustmentRT = Schema.SObjectType.AS_Transaction__c.getRecordTypeInfosByName().get('Adjustment').getRecordTypeId();
  //         Date startMonthDate = null;
  //         Date endMonthDate = null;
  //         Set<String> monthEndIdSet = new Set<String>();
  //         Map<String,AS_Month_End__c> monthEndMap = new Map<String,AS_Month_End__c>();
  //         Map<Id,Decimal> accountBalanceMap = new Map<Id,Decimal>();
  //         List<AS_Statement_Line_Item__c> insertSLIList = new List<AS_Statement_Line_Item__c>();
  //         List<AS_Transaction__c> transactionList = new List<AS_Transaction__c>();
  //         List<AS_Transaction__c> updateTransactionList = new List<AS_Transaction__c>();
  //         List<Account> accList = new List<Account>();
  //         Set<Id> accIds = new Set<Id>();

  //         //*************Get month end Ids********************
  //         Map<Id,Account> accountMap = null;
  //         for(AS_Month_End__c mEnd : monthEndList){
  //             monthEndIdSet = checkSetId(monthEndIdSet,mEnd.Id);
  //         }

  //         //*************Requery new month end and order by effective date********************
  //         List<AS_Month_End__c> newMonthEndList = [SELECT Effective_Date__c,Id,Total_Valuation__c,Name FROM AS_Month_End__c WHERE Id in :monthEndIdSet ORDER BY Effective_Date__c ASC NULLS LAST];

  //         //*************Getting Existing Month End Records from last year and this year********************
  //         List<AS_Month_End__c> existingMonthEndList = [SELECT Id, Effective_Date__c, Total_Valuation__c,Name FROM AS_Month_End__c WHERE Effective_Date__c = LAST_YEAR OR Effective_Date__c = THIS_YEAR ORDER BY Effective_Date__c ASC NULLS LAST];
  //         if(existingMonthEndList.size()>0){
  //             for(AS_Month_End__c mEnd : existingMonthEndList){
  //                 monthEndMap.put(String.valueOf(mEnd.Effective_Date__c.month()) + String.valueOf(mEnd.Effective_Date__c.year()),mEnd);
  //             }
  //         }

  //         //*************Getting the earliest start date month of earliest month end and last date of the most recent month of month end********************
  //         if(newMonthEndList.size()>0){
  //             if(newMonthEndList.size() == 1){
  //                 Integer numberOfDays = Date.daysInMonth(newMonthEndList[0].Effective_Date__c.year(), newMonthEndList[0].Effective_Date__c.month());
  //                 startMonthDate = Date.newInstance(newMonthEndList[0].Effective_Date__c.year(), newMonthEndList[0].Effective_Date__c.month(), 1);
  //                 endMonthDate = Date.newInstance(newMonthEndList[0].Effective_Date__c.year(), newMonthEndList[0].Effective_Date__c.month(), numberOfDays);
  //             }else{
  //                 Integer listSize = newMonthEndList.size() - 1;
  //                 Integer numberOfDays = Date.daysInMonth(newMonthEndList[listSize].Effective_Date__c.year(), newMonthEndList[listSize].Effective_Date__c.month());
  //                 startMonthDate = Date.newInstance(newMonthEndList[0].Effective_Date__c.year(), newMonthEndList[0].Effective_Date__c.month(), 1);
  //                 endMonthDate = Date.newInstance(newMonthEndList[listSize].Effective_Date__c.year(), newMonthEndList[listSize].Effective_Date__c.month(), numberOfDays);
  //             }
  //         }

  //         //*************Transaction Query and getting all Account Id from transaction********************
  //         if(startMonthDate != null && endMonthDate != null){
  //             transactionList = [SELECT AS_Amount__c,
  //                                     AS_Charity_Name_Text__c,
  //                                     AS_Charity__c,
  //                                     AS_Date__c,
  //                                     AS_Effective_Date__c,
  //                                     AS_Fund_CAN__c,
  //                                     AS_Fund_Name_Text__c,
  //                                     AS_Fund__c,
  //                                     AS_Send_to_Email__c,
  //                                     AS_Send_to_Xero__c,
  //                                     AS_Statement_Line_Item__c,
  //                                     AS_Status__c,
  //                                     AS_Xero_Bill_ID__c,
  //                                     AS_Xero_Invoice_ID__c,
  //                                     Email_To__c,
  //                                     AS_Project_Purpose__c,
  //                                     Id,
  //                                     Requested_By__c,
  //                                     RecordTypeId
  //                                 FROM
  //                                     AS_Transaction__c
  //                                 WHERE
  //                                     AS_Date__c >= :startMonthDate
  //                                 AND
  //                                     AS_Date__c <= :endMonthDate
  //                                 AND
  //                                     AS_Status__c != 'Draft'
  //                                 AND
  //                                     AS_Status__c != 'Rejected/Cancelled'
  //                                 AND
  //                                     AS_Status__c != 'Pending Approval'
  //                                 ORDER BY AS_Date__c ASC NULLS LAST
  //                             ];
  //         }

  //         Set<Id> fundIdSet = new Set<Id>();
  //         // Map<Id, Decimal> sliBalancePerAccount = new Map<Id, Decimal>();
  //         Map<Id, DateTime> sliDateCreated = new Map<Id, DateTime>();

  //         for(AS_Transaction__c trans : transactionList ) {

  //             fundIdSet.add( trans.AS_Fund__c );

  //         }

  //         //*************Account Map for Investment Return********************
  //         accountMap = new Map<Id,Account>([SELECT AS_Previous_Month_End_Balance__c,RecordTypeId,RecordType.Name,Name,Id FROM Account WHERE RecordTypeId =:orgRT AND (Status__c = 'Active' OR Status__c = 'Porting') AND (AS_Previous_Month_End_Balance__c != null OR AS_Previous_Month_End_Balance__c != 0)]);
  //         Decimal totalBal = 0;

  //         for( Id accId : accountMap.keySet() ){

  //             if( accountMap.get( accId ).AS_Previous_Month_End_Balance__c != null ) {

  //                 totalBal += accountMap.get( accId ).AS_Previous_Month_End_Balance__c.setScale(2);

  //             }

  //             fundIdSet.add( accId );

  //         }

  //         Map<Id, Decimal> sliBalancePerAccount = new Map<Id, Decimal>();
  //         List<AS_Statement_Line_Item__c> listStateLineItem = [SELECT
  //                                                                     Id,
  //                                                                     AS_Fund__c,
  //                                                                     AS_Balance__c
  //                                                             FROM
  //                                                                     AS_Statement_Line_Item__c
  //                                                             WHERE
  //                                                                     AS_Fund__c in :fundIdSet
  //                                                             ORDER BY Name ASC];

  //         for( AS_Statement_Line_Item__c statementLineItem : listStateLineItem ) {

  //             sliBalancePerAccount.put(statementLineItem.AS_Fund__c, statementLineItem.AS_Balance__c);

  //         }

  //         //*************Creating SLI Block********************
  //         if(newMonthEndList.size()>0){
  //             for(AS_Month_End__c mEnd : newMonthEndList){
  //                 Integer numberOfDays = Date.daysInMonth(mEnd.Effective_Date__c.year(), mEnd.Effective_Date__c.month());
  //                 Date startMonthDate2 = Date.newInstance(mEnd.Effective_Date__c.year(), mEnd.Effective_Date__c.month(), 1);
  //                 Date endMonthDate2 = Date.newInstance(mEnd.Effective_Date__c.year(), mEnd.Effective_Date__c.month(), numberOfDays);

  //                 AS_Month_End__c lastMonthEnd = null;
  //                 Integer lastMonth =(mEnd.Effective_Date__c.month() != 1 ? mEnd.Effective_Date__c.month() - 1 : 12);
  //                 Integer year = (mEnd.Effective_Date__c.month() != 1 ? mEnd.Effective_Date__c.year() : mEnd.Effective_Date__c.year() - 1);
  //                 String monthYearStr = String.valueOf(lastMonth) + String.valueOf(year);

  //                 if( monthEndMap.containsKey(monthYearStr) ) {

  //                     lastMonthEnd = monthEndMap.get(monthYearStr);

  //                 }

  //                 Map<Id, Decimal> totalLastMonthBal = new Map<Id, Decimal>();
  //                 Set<Id> checkAccountExist = new Set<Id>();
  //                 //Generating Investment Return SLI and SLI for Transactions

  //                 if(transactionList.size()>0){

  //                     for(AS_Transaction__c trans : transactionList){

  //                         Decimal lastMonthBal = 0;

  //                         if(totalLastMonthBal.containsKey(trans.AS_Fund__c)) {

  //                             lastMonthBal = totalLastMonthBal.get( trans.AS_Fund__c );

  //                         } else {

  //                             lastMonthBal = ( sliBalancePerAccount.get( trans.AS_Fund__c ) != null ? sliBalancePerAccount.get( trans.AS_Fund__c ): 0 );

  //                         }

  //                         if(trans.AS_Date__c >= startMonthDate2 && trans.AS_Date__c <= endMonthDate2){
  //                             Account acc = null;

  //                             if(accountMap.containsKey(trans.AS_Fund__c)){

  //                                 acc = accountMap.get(trans.AS_Fund__c);

  //                             }

  //                             //*************Creating Investment Return SLI********************
  //                             if(acc != null){

  //                                 if(!checkAccountExist.contains( acc.Id )){

  //                                     Decimal calculation = (acc.AS_Previous_Month_End_Balance__c != null ? calculateSLIAmount(mEnd.Total_Valuation__c, totalBal, acc.AS_Previous_Month_End_Balance__c).setScale(2) : 0 );
  //                                     lastMonthBal += calculation;

  //                                     AS_Statement_Line_Item__c newInvestmentReturnSLI = createInvestmentReturnSLI(mEnd,acc,calculation,lastMonthBal);
  //                                     insertSLIList.add(newInvestmentReturnSLI);
  //                                     checkAccountExist.add( acc.Id );

  //                                 }

  //                                 totalLastMonthBal.put( acc.Id, lastMonthBal.setScale(2) );
  //                             }

  //                             //*************Creating SLI based on transaction RecordType ********************

  //                             Decimal amount = 0;
  //                             String type = '';

  //                             if(trans.RecordTypeId == donationRT){
  //                                 type = 'Donation';
  //                                 amount = trans.AS_Amount__c.setScale(2);
  //                                 lastMonthBal += amount;
  //                             } else if(trans.RecordTypeId == giftRT){
  //                                 type = 'Gift';
  //                                 if(trans.AS_Amount__c > 0) amount = -trans.AS_Amount__c;
  //                                 else amount = trans.AS_Amount__c.setScale(2);
  //                                 lastMonthBal += amount;
  //                             } else if(trans.RecordTypeId == adjustmentRT){
  //                                 type = 'Adjustment';
  //                                 amount = trans.AS_Amount__c.setScale(2);
  //                                 lastMonthBal += amount;
  //                             }

  //                             AS_Statement_Line_Item__c newSLI = createSLI(trans.RecordTypeId,trans,mEnd,lastMonthBal,type,amount);
  //                             insertSLIList.add(newSLI);
  //                         }

  //                         totalLastMonthBal.put( trans.AS_Fund__c, lastMonthBal.setScale(2) );
  //                     }

  //                 }
  //                 //Generating Investment returns for Giving Fund Organisations
  //                 if(!accountMap.isEmpty()){

  //                     Decimal lastMonthBal = 0;

  //                     for(ID accId : accountMap.keySet()){
  //                         if( sliBalancePerAccount.containsKey( accId  ) ) {

  //                             sliBalancePerAccount.get( accId  );

  //                         }

  //                         if(totalLastMonthBal.containsKey(accId)) {

  //                             lastMonthBal = totalLastMonthBal.get( accId );

  //                         } else {

  //                             lastMonthBal = ( sliBalancePerAccount.get( accId ) != null ? sliBalancePerAccount.get( accId ): 0 );

  //                         }

  //                         if(!checkAccountExist.contains( accId )){

  //                             Account accs = accountMap.get( accId );
  //                             Decimal calculation = (accs.AS_Previous_Month_End_Balance__c != null ? calculateSLIAmount(mEnd.Total_Valuation__c, totalBal, accs.AS_Previous_Month_End_Balance__c) : 0 );
  //                             lastMonthBal += calculation;

  //                             AS_Statement_Line_Item__c newInvestmentReturnSLI = createInvestmentReturnSLI(mEnd,accountMap.get(accId),calculation,lastMonthBal);
  //                             insertSLIList.add(newInvestmentReturnSLI);
  //                             checkAccountExist.add( accId );

  //                         }

  //                         totalLastMonthBal.put( accId, lastMonthBal.setScale(2) );

  //                     }

  //                 }

  //                 //*************Send Email to current user********************
  //                 sendEmail(mEnd);
  //             }
  //         }
  //         //*************Inserting new SLI and relate the new SLI to its transaction record********************
  //         Set<Id> sliNewlyInsertedIds = new Set<Id>();
  //         if( insertSLIList.size() > 0 ){
  //             Database.SaveResult[] resultList =  Database.insert(insertSLIList,false);

  //             for(Database.SaveResult result : resultList){

  //                 if(result.isSuccess()){

  //                     sliNewlyInsertedIds.add( result.getId() );

  //                 }
  //             }
  //         }
  //         List<AS_Statement_Line_Item__c> newSliCreatedList = [SELECT
  //                                                                     Id,
  //                                                                     AS_Transaction_Relationship_Id__c,
  //                                                                     AS_Fund__c
  //                                                                 FROM
  //                                                                     AS_Statement_Line_Item__c
  //                                                                 WHERE
  //                                                                     Id in: sliNewlyInsertedIds
  //                                                             ];
  //         for(AS_Statement_Line_Item__c sli : newSliCreatedList) {

  //             if( sli.AS_Transaction_Relationship_Id__c != null ) {

  //                 updateTransactionList.add(new AS_Transaction__c(
  //                     Id = sli.AS_Transaction_Relationship_Id__c,
  //                     AS_Statement_Line_Item__c = sli.Id
  //                 ));

  //             }
  //             accIds.add( sli.AS_Fund__c );
  //         }
  //         if(updateTransactionList.size() > 0 ) {

  //             update updateTransactionList;

  //         }
  //         if( accIds.size() > 0 ) {

  //             for(Id acc : accIds) {

  //                 if( acc != null) {

  //                     accList.add( new Account(
  //                         Id = acc,
  //                         AS_Update_Balances__c = true

  //                     ));

  //                 }

  //             }
  //         }
  //         if( accList.size() > 0 ) {

  //             update accList;

  //         }

  //     }catch(Exception ex){
  //         AS_ExceptionHandler.createException(ex, 'Month End', 'ASMonthEndTriggerHandler');
  //     }
  // }

  /*
   * @author: Butch B. Enerio
   * @date: February 6, 2020
   * @Method name: getMonthStr
   * @description: method for getting the month String
   * @parameter(s): List<AS_Month_End__c> monthEndList
   * @return: None
   * @updated : No
   * @updated by:
   * @updated Date:
   * @description of the update:
   * @Jira Ticket: APSFSP-43
   */
  public static String getMonthStr(Integer month, Integer format) {
    String monthStr = '';
    if (month == 1)
      monthStr = format == 0 ? 'January' : 'Jan';
    else if (month == 2)
      monthStr = format == 0 ? 'February' : 'Feb';
    else if (month == 3)
      monthStr = format == 0 ? 'March' : 'Mar';
    else if (month == 4)
      monthStr = format == 0 ? 'April' : 'Apr';
    else if (month == 5)
      monthStr = format == 0 ? 'May' : 'May';
    else if (month == 6)
      monthStr = format == 0 ? 'June' : 'Jun';
    else if (month == 7)
      monthStr = format == 0 ? 'July' : 'Jul';
    else if (month == 8)
      monthStr = format == 0 ? 'August' : 'Aug';
    else if (month == 9)
      monthStr = format == 0 ? 'September' : 'Sep';
    else if (month == 10)
      monthStr = format == 0 ? 'October' : 'Oct';
    else if (month == 11)
      monthStr = format == 0 ? 'November' : 'Nov';
    else if (month == 12)
      monthStr = format == 0 ? 'December' : 'Dec';
    return monthStr;
  }

  /*
   * @author: Butch B. Enerio
   * @date: March 19, 2020
   * @Method name: calculateSLIAmount
   * @description: method for caculating all Account balance to get percentage amount
   * @parameter(s): Decimal changeInFoundVal, Decimal totalPrevMonthEndBal, Decimal prevMonthEndBal
   * @return: accBal
   * @updated : No 1
   * @updated by: Romnick Hilot
   * @updated Date: April 16, 2020
   * @description of the update:
   * @Jira Ticket: APSFSP-43 updated by APSFSP-51
   */
  public static Decimal calculateSLIAmount(Decimal changeInFoundVal, Decimal totalPrevMonthEndBal, Decimal prevMonthEndBal) {
    Decimal per = changeInFoundVal.setScale(2) / totalPrevMonthEndBal.setScale(2);
    Decimal accBal = prevMonthEndBal.setScale(2) * per;

    return accBal.setScale(2);
  }

  /*
   * @author: Butch B. Enerio
   * @date: February 6, 2020
   * @Method name: checkSetId
   * @description: method for checking if id is already in the set
   * @parameter(s): List<AS_Month_End__c> monthEndList
   * @return: None
   * @updated : No
   * @updated by:
   * @updated Date:
   * @description of the update:
   * @Jira Ticket: APSFSP-43
   */
  public static Set<String> checkSetId(Set<String> idset, String id) {
    if (idset.size() > 0) {
      Boolean found = false;
      for (String idrow : idset) {
        if (idrow == id)
          found = true;
      }
      if (!found)
        idset.add(id);
    } else
      idset.add(id);
    return idset;
  }

  /*
   * @author: Butch B. Enerio
   * @date: February 6, 2020
   * @Method name: createSLI
   * @description: method for creating Statement Line Item record
   * @parameter(s): Id recordTypeId, Account acc, AS_Transaction__c trans, Decimal balance
   * @return: None
   * @updated : No
   * @updated by:
   * @updated Date:
   * @description of the update:
   * @Jira Ticket: APSFSP-43
   */
  public static AS_Statement_Line_Item__c createSLI(
    Id recordTypeId,
    AS_Transaction__c trans,
    AS_Month_End__c mEnd,
    Decimal balance,
    String type,
    Decimal amount
  ) {
    Id donationRT = Schema.SObjectType.AS_Transaction__c.getRecordTypeInfosByName().get('Donation').getRecordTypeId();
    Id giftRT = Schema.SObjectType.AS_Transaction__c.getRecordTypeInfosByName().get('Gift').getRecordTypeId();
    Id adjustmentRT = Schema.SObjectType.AS_Transaction__c.getRecordTypeInfosByName().get('Adjustment').getRecordTypeId();

    return new AS_Statement_Line_Item__c(
      AS_Month_End__c = mEnd.Id,
      AS_Fund__c = trans.AS_Fund__c,
      AS_Charity__c = (recordTypeId == giftRT ? trans.AS_Charity__c : null),
      AS_Type__c = type,
      AS_Amount__c = amount,
      AS_Balance__c = balance,
      AS_Project_Purpose__c = (recordTypeId == giftRT ? trans.AS_Project_Purpose__c : null),
      AS_Transaction_Relationship_Id__c = trans.Id,
      AS_Investment_Option__c = mEnd.AS_Investment_Option__c
    );
  }

  /*
   * @author: Butch B. Enerio
   * @date: February 6, 2020
   * @Method name: createInvestmentReturnSLI
   * @description: method for creating Statement Line Item record for Investment returns
   * @parameter(s): AS_Month_End__c mEnd, Account acc, Decimal calculation, Decimal accountBalance
   * @return: None
   * @updated : No
   * @updated by:
   * @updated Date:
   * @description of the update:
   * @Jira Ticket: APSFSP-43
   */
  public static AS_Statement_Line_Item__c createInvestmentReturnSLI(AS_Month_End__c mEnd, Account acc, Decimal calculation, Decimal accountBalance) {
    return new AS_Statement_Line_Item__c(
      AS_Month_End__c = mEnd.Id,
      AS_Fund__c = acc.Id,
      AS_Type__c = 'Investment Return',
      AS_Amount__c = calculation,
      AS_Balance__c = accountBalance,
      AS_Investment_Option__c = mEnd.AS_Investment_Option__c
    );
  }

  /*
   * @author: Butch B. Enerio
   * @date: February 7, 2020
   * @Method name: sendEmail
   * @description: method for sending an email.
   * @parameter(s): String email,String templateId,String subject
   * @return: none
   * @updated : No
   * @updated by:
   * @updated Date:
   * @description of the update:
   */
  public static void sendEmail(AS_Month_End__c mEnd) {
    List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
    List<String> sendTo = new List<String>();
    List<String> ccAddresses = new List<String>();

    //SR - 30/11/2022 - Adding additional alerts for the admin team
    AlertEmails__mdt[] alertmails = [SELECT Masterlabel, UserEmail__c, MonthEnd__c FROM AlertEmails__mdt WHERE All__c = TRUE];

    for (AlertEmails__mdt amail : alertmails) {
      if (amail.UserEmail__c != null) {
        ccAddresses.add(amail.UserEmail__c);
      }
    }

    AS_Month_End__c newMonthEnd = [SELECT Id, Name, AS_Investment_Option__c FROM AS_Month_End__c WHERE Id = :mEnd.Id];

    String email = UserInfo.getUserEmail();
    String userId = UserInfo.getUserId();
    String htmlBody = setBody(newMonthEnd.Id, newMonthEnd.Name, newMonthEnd.AS_Investment_Option__c);
    sendTo.add(email);
    mail.setToAddresses(sendTo);
    mail.setCCAddresses(ccAddresses);
    mail.setSubject(newMonthEnd.Name + ', ' + newMonthEnd.AS_Investment_Option__c + ' is now Complete');
    mail.setHtmlBody(htmlBody);
    mails.add(mail);
    Messaging.sendEmail(mails);
  }

  /*
   * @author: Butch B. Enerio
   * @date: February 10, 2020
   * @Method name: setBody
   * @description: method for setting the email body.
   * @parameter(s): String email,String templateId,String subject
   * @return: none
   * @updated : No
   * @updated by:
   * @updated Date:
   * @description of the update:
   */

  //SR 03/01/2023 - Updating notification email to show portfolio, moving query to the main sendEmail() method. Case 251520
  // public static String setBody(AS_Month_End__c mEnd) {
  //   AS_Month_End__c newMonthEnd = [SELECT Id, Name, AS_Investment_Option__c FROM AS_Month_End__c WHERE Id = :mEnd.Id]; // Get Month End latest name
  //   String str = '<div style="font-family:arial;line-height:5px;"><p>Dear ' + UserInfo.getFirstName() + ',<p><br/>';
  //   str +=
  //     '<p>The Month End Process you initiated for the ' +
  //     newMonthEnd.AS_Investment_Option__c +
  //     ' - ' +
  //     newMonthEnd.Name +
  //     ' ' +
  //     'has been completed.</p>';
  //   str +=
  //     '<p>Click here to see the relevant Month End record:&nbsp;<a href="' +
  //     URL.getSalesforceBaseUrl().toExternalForm() +
  //     '/' +
  //     newMonthEnd.Id +
  //     '">' +
  //     newMonthEnd.Name +
  //     '</a></p><br/><br/>';
  //   str += '<p>Kind regards,</p>';
  //   str += '<p>Operations</p></div>';
  //   return str;
  // }

  public static String setBody(string MonthEndId, string MonthEndName, string MonthEndIO) {
    String str = '<div style="font-family:arial;line-height:5px;"><p>Dear ' + UserInfo.getFirstName() + ',<p><br/>';
    str += '<p>The Month End Process you initiated for the ' + MonthEndIO + ' - ' + MonthEndName + ' ' + 'has been completed.</p>';
    str +=
      '<p>Click here to see the relevant Month End record:&nbsp;<a href="' +
      URL.getSalesforceBaseUrl().toExternalForm() +
      '/' +
      MonthEndId +
      '">' +
      MonthEndName +
      '</a></p><br/><br/>';
    str += '<p>Kind regards,</p>';
    str += '<p>Operations</p></div>';
    return str;
  }

  // APSFB-14 - Moved to ASMonthEndRollBack batch class
  //  /**
  //  * Function Name: ASMonthEndTrigger
  //  * Author: Romnick Hilot
  //  * Date Created: April 20, 2020
  //  * Description: Update Account when month end delete
  //  * @return   return description
  //  * Jira Ticket: https://jira.alphasys.com.au/browse/APSFSP-54
  //  */
  // public static void AsUpdateAccountOnDeletedMonthEnd(List<AS_Month_End__c> deletedMonthEnd) {

  //     try{
  //         Id recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('APS_Foundation_Sub_Fund').getRecordTypeId();
  //         Set<Id> accountId = new Set<Id>();
  //         List<Account> accountList = new List<Account>();
  //         Set<Id> monthEndId = new Set<Id>();

  //         for( AS_Month_End__c monthEnd : deletedMonthEnd ) {

  //             monthEndId.add( monthEnd.Id );

  //         }

  //         List<AS_Statement_Line_Item__c> statementLIList = [SELECT Id, AS_Fund__c FROM AS_Statement_Line_Item__c WHERE AS_Month_End__c in: monthEndId];
  //         if( statementLIList.size() > 0 ) {

  //             for( AS_Statement_Line_Item__c statementLI : statementLIList ) {

  //                 if( statementLI.AS_Fund__c != null ) {

  //                     accountId.add( statementLI.AS_Fund__c );

  //                 }

  //             }

  //         }

  //         if( accountId.size() > 0 ) {

  //         List<Account> accList = [SELECT Id, AS_Update_Balances__c FROM Account WHERE Id in: accountId AND RecordTypeId =: recordTypeId];

  //             for( Account acc : accList ) {

  //                 if( acc != null) {

  //                     accountList.add( new Account(
  //                         Id = acc.Id,
  //                         AS_Update_Balances__c = true
  //                     ) );

  //                 }

  //             }

  //         }

  //         if( accountList.size() > 0 ) {

  //             update accountList;

  //         }
  //     }catch(Exception ex){
  //         AS_ExceptionHandler.createException(ex, 'Roll Back', 'ASMonthEndTriggerHandler');
  //     }

  // }
}