/**
 * Created by Rendhon Gerone on June 15, 2022
 * Calculate Balances for Orgnisations
 */

/* Done - To fix the mid year account wind up issue, all APSF account statuses ( non active should have Date left service within the past 365 days) should be included.  DOC fix for shorthand. Case 00025011. Also changing from query string
 */
/* Null values partial fix, replaced calculations with ternery operators. Case 00024135
 */

public class ASMinorBalanceUpdatesBatchv2 implements Database.Batchable<sObject>, Database.Stateful {
  String investment_option;
  private Boolean hasError; //Ensures that the batch doesn't run any logic if an error has occurred
  private Exception excObj;
  private Date leftDate;
  List<ID> account_id_list = new List<Id>();

  public ASMinorBalanceUpdatesBatchv2(String investment_option) {
    this.investment_option = investment_option;
    this.hasError = false;
  }

  public Database.QueryLocator start(Database.BatchableContext BC) {
    // String query = '';

    try {
      Id devRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('APS Foundation Giving Fund').getRecordTypeId();

      // DOC fix - comment out status line and query below
      // String status = 'Active';
      // query =
      //   'SELECT ' +
      //   'Id, Name,Investment_Portfolio__c ' +
      //   'FROM   Account ' +
      //   'WHERE RecordTypeId  =: devRecordTypeId AND Status__c =: status AND Investment_Portfolio__c  =: investment_option';

      leftDate = date.today() - 365;
      System.debug('Left date is ' + leftDate);
    } catch (Exception ex) {
      this.hasError = true;
      this.excObj = ex;
    }

    // return Database.getQueryLocator(query);
    // DOC fix query
    return Database.getQueryLocator(
      'SELECT Id, Name,Investment_Portfolio__c, Date_left_service__c FROM Account WHERE RecordTypeId  =: devRecordTypeId AND Investment_Portfolio__c  =: investment_option AND (Date_left_service__c = null OR Date_left_service__c >=: leftDate)'
    );
  }

  public void execute(Database.BatchableContext BC, List<Account> scope) {
    //System.debug(scope.size());
    System.debug('The accounts:' + scope);
    if (!this.hasError) {
      try {
        Date fy_date = date.today();
        Date previous_ytd_date = date.today();

        List<AS_Month_End__c> recent_month_end = [
          SELECT Id, Name, Effective_Date__c
          FROM AS_Month_End__c
          WHERE AS_Investment_Option__c = :investment_option
          ORDER BY Effective_Date__c DESC
          LIMIT 1
        ];
        if (recent_month_end.size() > 0) {
          if (recent_month_end[0].Effective_Date__c.month() > 6) {
            fy_date = date.newInstance(recent_month_end[0].Effective_Date__c.year(), 6, 30);
            previous_ytd_date = date.newInstance(recent_month_end[0].Effective_Date__c.year() - 1, 6, 30);
          } else {
            fy_date = date.newInstance(recent_month_end[0].Effective_Date__c.year() - 1, 6, 30);
            previous_ytd_date = date.newInstance(recent_month_end[0].Effective_Date__c.year() - 2, 6, 30);
          }
        }

        Map<ID, Decimal> total_gift = new Map<ID, Decimal>();
        Map<ID, Decimal> total_donation = new Map<ID, Decimal>();
        Map<ID, Decimal> total_investment_return = new Map<ID, Decimal>();
        Map<ID, Decimal> total_adjustment = new Map<ID, Decimal>();

        Map<ID, Decimal> total_trans = new Map<ID, Decimal>();

        Map<ID, Decimal> ytd_total_gift = new Map<ID, Decimal>();
        Map<ID, Decimal> ytd_total_donation = new Map<ID, Decimal>();
        Map<ID, Decimal> ytd_total_investment_return = new Map<ID, Decimal>();
        Map<ID, Decimal> ytd_total_adjustment = new Map<ID, Decimal>();

        Map<ID, Decimal> pfy_total_gift = new Map<ID, Decimal>();
        Map<ID, Decimal> pfy_total_donation = new Map<ID, Decimal>();
        Map<ID, Decimal> pfy_total_investment_return = new Map<ID, Decimal>();
        Map<ID, Decimal> pfy_total_adjustment = new Map<ID, Decimal>();

        Map<ID, Decimal> june_balance = new Map<ID, Decimal>();
        Map<ID, Decimal> prev_june_balance = new Map<ID, Decimal>();

        Map<ID, String> account_latest_SLi = new Map<ID, String>();
        List<Account> accounts_toupdate = new List<Account>();

        // Merge all account IDs to a list so we can query all / and extracing the latest SLI value from June
        for (Account each_account : scope) {
          account_id_list.add(each_account.Id);
        }

        // function call to all inceptions
        total_gift = return_account_totals(account_id_list, 'Gift', 'Inception', fy_date, fy_date);
        total_donation = return_account_totals(account_id_list, 'Donation', 'Inception', fy_date, fy_date);
        total_investment_return = return_account_totals(account_id_list, 'Investment Return', 'Inception', fy_date, fy_date);
        total_adjustment = return_account_totals(account_id_list, 'Adjustment', 'Inception', fy_date, fy_date);
        june_balance = get_lastsli_monthend(account_id_list, fy_date);

        // function call to all YTD
        ytd_total_gift = return_account_totals(account_id_list, 'Gift', 'YTD', fy_date, fy_date);
        ytd_total_donation = return_account_totals(account_id_list, 'Donation', 'YTD', fy_date, fy_date);
        ytd_total_investment_return = return_account_totals(account_id_list, 'Investment Return', 'YTD', fy_date, fy_date);
        ytd_total_adjustment = return_account_totals(account_id_list, 'Adjustment', 'YTD', fy_date, fy_date);

        // Total trans
        total_trans = return_total_transactions(account_id_list);

        // function call to all Previous YTD
        pfy_total_gift = return_account_totals(account_id_list, 'Gift', 'PrevYTD', fy_date, previous_ytd_date);
        pfy_total_donation = return_account_totals(account_id_list, 'Donation', 'PrevYTD', fy_date, previous_ytd_date);
        pfy_total_investment_return = return_account_totals(account_id_list, 'Investment Return', 'PrevYTD', fy_date, previous_ytd_date);
        pfy_total_adjustment = return_account_totals(account_id_list, 'Adjustment', 'PrevYTD', fy_date, previous_ytd_date);
        prev_june_balance = get_lastsli_monthend(account_id_list, previous_ytd_date);

        /*
        System.debug('total gift:' + total_gift);
        System.debug('total_donation:' + total_gift);
        System.debug('total_investment_return:' + total_gift);
        System.debug('total_adjustment:' + total_gift);
        System.debug('The Last SLI:' + june_balance);

        System.debug('YTD gift:' + ytd_total_gift);
        System.debug('YTD donation:' + ytd_total_donation);
        System.debug('YTD total_investment_return:' + ytd_total_investment_return);
        System.debug('YTD total_adjustment:' + ytd_total_adjustment);

        System.debug('Pending transactions:' + total_trans);

     */

        for (Account org : scope) {
          //
          Decimal percentage = 0;

          if (ytd_total_gift.get(org.Id) != null && june_balance.get(org.Id) != null) {
            percentage = 100 * (ytd_total_gift.get(org.Id) * -1 / june_balance.get(org.Id));
          }

          //DONE - Adding ternery operators to fix the null values issue
          //If this requires reverting, DO NOT replace the lines containing '-1', these are from original coding

          org.AS_Gifts_Since_Inception__c = total_gift.containskey(org.id) ? total_gift.get(org.Id) * -1 : 0;
          org.AS_Donations_Since_Inception__c = total_donation.containskey(org.id) ? total_donation.get(org.Id) : 0;
          org.AS_Adjustments_Since_Inception__c = total_adjustment.containskey(org.id) ? total_adjustment.get(org.Id) : 0;
          org.AS_Investment_Returns_Since_Inception__c = total_investment_return.containskey(org.Id) ? total_investment_return.get(org.Id) : 0;
          org.AS_June_30_Balance__c = org.AS_June_30_Balance__c = june_balance.containskey(org.Id) ? june_balance.get(org.Id) : 0;

          org.AS_Gifts_YTD__c = ytd_total_gift.containskey(org.ID) ? ytd_total_gift.get(org.Id) * -1 : 0;
          org.AS_Donations_YTD__c = ytd_total_donation.containskey(org.Id) ? ytd_total_donation.get(org.Id) : 0;
          org.AS_Adjustments_YTD__c = ytd_total_adjustment.containsKey(org.Id) ? ytd_total_adjustment.get(org.Id) : 0;
          org.AS_Investment_Returns_YTD__c = ytd_total_investment_return.containsKey(org.Id) ? ytd_total_investment_return.get(org.Id) : 0;

          org.AS_Pending_Transactions__c = total_trans.containsKey(org.Id) ? total_trans.get(org.Id) : 0;
          org.AS_Achieved__c = percentage;

          org.AS_Gifts_Previous_FY__c = pfy_total_gift.containskey(org.Id) ? pfy_total_gift.get(org.Id) * -1 : 0;
          org.AS_Donations_Previous_FY__c = pfy_total_donation.containsKey(org.Id) ? pfy_total_donation.get(org.Id) : 0;
          org.AS_Adjustments_Previous_FY__c = pfy_total_adjustment.containsKey(org.Id) ? pfy_total_adjustment.get(org.Id) : 0;
          org.AS_Investment_Returns_Previous_FY__c = pfy_total_investment_return.containsKey(org.Id) ? pfy_total_investment_return.get(org.Id) : 0;
          org.AS_June_30_Balance_Previous_FY__c = prev_june_balance.containsKey(org.Id) ? prev_june_balance.get(org.Id) : 0;

          /*
          DONE - Add old values here for reference


          org.AS_Gifts_Since_Inception__c = total_gift.containskey(org.id) ? total_gift.get(org.Id) * -1 : 0;
          org.AS_Donations_Since_Inception__c = total_donation.get(org.Id);
          org.AS_Adjustments_Since_Inception__c = total_adjustment.get(org.Id);
          org.AS_Investment_Returns_Since_Inception__c = total_investment_return.get(org.Id);
          org.AS_June_30_Balance__c = june_balance.get(org.Id);

          org.AS_Gifts_YTD__c = ytd_total_gift.containskey(org.ID) ? ytd_total_gift.get(org.Id) * -1 : 0;
          org.AS_Donations_YTD__c = ytd_total_donation.get(org.Id);
          org.AS_Adjustments_YTD__c = ytd_total_adjustment.get(org.Id);
          org.AS_Investment_Returns_YTD__c = ytd_total_investment_return.get(org.Id);

          org.AS_Pending_Transactions__c = total_trans.get(org.Id);
          org.AS_Achieved__c = percentage;

          org.AS_Gifts_Previous_FY__c = pfy_total_gift.containskey(org.Id) ? pfy_total_gift.get(org.Id) * -1 : 0;
          org.AS_Donations_Previous_FY__c = pfy_total_donation.get(org.Id);
          org.AS_Adjustments_Previous_FY__c = pfy_total_adjustment.get(org.Id);
          org.AS_Investment_Returns_Previous_FY__c = pfy_total_investment_return.get(org.Id);
          org.AS_June_30_Balance_Previous_FY__c = prev_june_balance.get(org.Id);
*/
          accounts_toupdate.add(org);
        }

        if (accounts_toupdate.size() > 0) {
          update accounts_toupdate;
        }
      } catch (Exception ex) {
        System.debug('error occured in execute');
        this.hasError = true;
        this.excObj = ex;

        System.debug('ex = ' + ex);
      }
    }
  }

  public Map<ID, Decimal> get_lastsli_monthend(List<ID> ids, Date fy_date) {
    Map<ID, Decimal> accnt_last_sli = new Map<ID, Decimal>();
    Map<ID, String> account_latest_sli = new Map<ID, String>();

    if (!this.hasError) {
      try {
        for (AS_Statement_Line_Item__c sli : [
          SELECT Id, AS_Balance__c, AS_Fund__c, Name
          FROM AS_Statement_Line_Item__c
          WHERE archived__c = FALSE AND AS_Effective_Date__c = :fy_date AND AS_Fund__c IN :ids
        ]) {
          if (account_latest_sli.containskey(sli.AS_Fund__c)) {
            if (sli.Name > account_latest_sli.get(sli.AS_Fund__c)) {
              account_latest_sli.put(sli.AS_Fund__c, sli.Name);
              accnt_last_sli.put(sli.AS_Fund__c, sli.AS_Balance__c);
            }
          } else {
            account_latest_sli.put(sli.AS_Fund__c, sli.Name);
            accnt_last_sli.put(sli.AS_Fund__c, sli.AS_Balance__c);
          }
        }
      } catch (Exception ex) {
        this.hasError = true;
        this.excObj = ex;
      }
    }

    return accnt_last_sli;
  }

  public Map<ID, Decimal> return_total_transactions(List<ID> ids) {
    Map<ID, Decimal> account_total_summary = new Map<ID, Decimal>();

    if (!this.hasError) {
      try {
        Id donationRT = Schema.SObjectType.AS_Transaction__c.getRecordTypeInfosByName().get('Donation').getRecordTypeId();
        Id adjustmentRT = Schema.SObjectType.AS_Transaction__c.getRecordTypeInfosByName().get('Adjustment').getRecordTypeId();
        Id giftRT = Schema.SObjectType.AS_Transaction__c.getRecordTypeInfosByName().get('Gift').getRecordTypeId();

        //calculate Gifts and adjustment that are not reconciled
        for (AS_Transaction__c trans : [
          SELECT Id, Name, AS_Fund__c, AS_Statement_Line_Item__c, AS_Status__c, AS_Effective_Amount__c, RecordTypeId
          FROM AS_Transaction__c
          WHERE
            AS_Fund__c IN :ids
            AND (AS_Statement_Line_Item__c = NULL
            OR AS_Statement_Line_Item__r.archived__c = TRUE)
            AND (((AS_Status__c = 'Reconciled'
            OR AS_Status__c != 'Rejected/Cancelled')
            AND (RecordTypeId = :giftRT
            OR RecordTypeId = :adjustmentRT))
            OR (((AS_Status__c = 'Reconciled'
            AND AS_Status__c != 'Draft')
            OR (AS_Status__c != 'Rejected/Cancelled'
            AND AS_Status__c != 'Draft'))
            AND RecordTypeId = :donationRT))
        ]) {
          //If account is already in the list
          if (account_total_summary.containsKey(trans.AS_Fund__c)) {
            Decimal total = account_total_summary.get(trans.AS_Fund__c);
            total = total + trans.AS_Effective_Amount__c;
            account_total_summary.put(trans.AS_Fund__c, total);
          } else {
            Decimal total = 0;
            total = total + trans.AS_Effective_Amount__c;
            account_total_summary.put(trans.AS_Fund__c, total);
          }
        }
      } catch (Exception ex) {
        this.hasError = true;
        this.excObj = ex;
      }
    }

    //System.debug( 'The :'+account_total_summary );
    return account_total_summary;
  }

  // type('gift',donation,adjustment)
  public Map<ID, Decimal> return_account_totals(List<ID> ids, String type, String process, Date date_monthend, Date ytd_previous) {
    Map<ID, Decimal> account_total_summary = new Map<ID, Decimal>();
    //Get all SLI using the list of accounts based from type

    if (!this.hasError) {
      try {
        List<AS_Statement_Line_Item__c> sli_list = new List<AS_Statement_Line_Item__c>();
        if (process == 'Inception') {
          sli_list = [
            SELECT Id, AS_Amount__c, AS_Fund__c, AS_Effective_Date__c
            FROM AS_Statement_Line_Item__c
            WHERE AS_Type__c = :type AND archived__c = FALSE AND AS_Fund__c IN :ids
          ];
        } else if (process == 'YTD') {
          sli_list = [
            SELECT Id, AS_Amount__c, AS_Fund__c, AS_Effective_Date__c
            FROM AS_Statement_Line_Item__c
            WHERE AS_Type__c = :type AND archived__c = FALSE AND AS_Fund__c IN :ids AND AS_Effective_Date__c > :date_monthend
          ];
        }
        if (process == 'PrevYTD') {
          sli_list = [
            SELECT Id, AS_Amount__c, AS_Fund__c, AS_Effective_Date__c
            FROM AS_Statement_Line_Item__c
            WHERE
              AS_Type__c = :type
              AND archived__c = FALSE
              AND AS_Fund__c IN :ids
              AND AS_Effective_Date__c <= :date_monthend
              AND AS_Effective_Date__c > :ytd_previous
          ];
        }

        for (AS_Statement_Line_Item__c sli : sli_list) {
          //If account is already in the list
          if (account_total_summary.containsKey(sli.AS_Fund__c)) {
            Decimal total = account_total_summary.get(sli.AS_Fund__c);
            total = total + sli.AS_Amount__c;
            account_total_summary.put(sli.AS_Fund__c, total);
          } else {
            Decimal total = 0;
            total = total + sli.AS_Amount__c;
            account_total_summary.put(sli.AS_Fund__c, total);
          }
        }
      } catch (Exception ex) {
        this.hasError = true;
        this.excObj = ex;
      }
    }

    return account_total_summary;
  }

  public void finish(Database.BatchableContext BC) {
    if (this.hasError) {
      //Create Exception record and send email
      AS_ExceptionHandler.createExceptionRecord(this.excObj, 'Update Minor Balances', 'ASMinorBalanceUpdatesBatchv2', account_id_list);
    }
  }
}