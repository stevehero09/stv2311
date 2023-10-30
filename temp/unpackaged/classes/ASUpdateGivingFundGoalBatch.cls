/**
 * Created by Liezel Dela Peña on June 07, 2022
 * Calculates the Total SLI for every Account and update the account balances and month End value.
 * Test Class: ASMonthEndBatch_Test
 */
public class ASUpdateGivingFundGoalBatch implements Database.Batchable<sObject>, Database.Stateful {
  Datetime today = Datetime.now();

  List<Id> accIds;
  Set<String> investmentOption = new Set<String>();
  //Map<Id, List<AS_Statement_Line_Item__c>> accountSLIMap = new Map<Id, List<AS_Statement_Line_Item__c>>();
  //Map<Id, Decimal> totalSLIMap = new Map<Id, Decimal>();
  List<AS_Month_End__c> monthEnds = new List<AS_Month_End__c>();
  Map<Id, Decimal> accountAmountMap = new Map<Id, Decimal>();
  Map<Id, Decimal> accountAmountMapNoOpt = new Map<Id, Decimal>();
  List<Account> accountsToUpdate = new List<Account>();
  List<Account> accountsToUpdateNoOpt = new List<Account>();
  List<AS_Month_End__c> generalMonthEnd = new List<AS_Month_End__c>();
  Map<String, List<Account>> accountInvestmentMap = new Map<String, List<Account>>();
  Map<String, List<Account>> monthEndAccMap = new Map<String, List<Account>>();
  Map<String, AS_Month_End__c> monthEndOptionMap = new Map<String, AS_Month_End__c>();
  private Boolean hasError; //Ensures that the batch doesn't run any logic if an error has occurred
  private Exception excObj;

  //takes in the list of acc ids from the MonthEndBatch, which are correct, UNLESS its a pfy change
  public ASUpdateGivingFundGoalBatch(List<Id> accIds) {
    this.accIds = accIds;
    this.hasError = false;
  }

  public Database.QueryLocator start(Database.BatchableContext BC) {
    System.debug(' //Need to update this to handle the PFY issue');
    String query = '';

    try {
      query = 'SELECT ' + 'Id, Name, 	Investment_Portfolio__c ' + 'FROM 	Account ' + 'WHERE ' + 'Id IN: accIds';
    } catch (Exception ex) {
      this.hasError = true;
      this.excObj = ex;
    }

    return Database.getQueryLocator(query);
  }

  public void execute(Database.BatchableContext BC, List<Account> scope) {
    System.debug('scope ' + scope);
    System.debug('scope ' + scope.size());
    if (!this.hasError) {
      System.debug(
        '//For all accounts in the list passed in, if the accountInvestmetMap contains the acc/invest portfolio, get the acc fom the map, add the account to a list, and put the inv portfolio string and the account into the accountInvestmentMap'
      );

      try {
        if (scope.size() > 0) {
          for (Account acc : scope) {
            //accInvestmentOption.add(acc.AS_Investment_Option__c);

            if (accountInvestmentMap.containsKey(acc.Investment_Portfolio__c)) {
              List<Account> accountList = accountInvestmentMap.get(acc.Investment_Portfolio__c);
              accountList.add(acc);
              accountInvestmentMap.put(acc.Investment_Portfolio__c, accountList);
            } else {
              List<Account> newAccountList = new List<Account>();
              newAccountList.add(acc);
              accountInvestmentMap.put(acc.Investment_Portfolio__c, newAccountList);
            }
          }
          System.debug('accountInvestmentMap' + accountInvestmentMap);
          System.debug('accountInvestmentMap' + accountInvestmentMap.keySet());

          System.debug('//Get the prev month ends and add them to the monthEnds list');
          //Go through all the month ends where the month end investment option is in the map and add them to the monthEnds list
          for (String optionValue : accountInvestmentMap.keySet()) {
            AS_Month_End__c monthEnd = [
              SELECT Id, Name, Effective_Date__c, Total_Valuation__c, AS_Investment_Option__c
              FROM AS_Month_End__c
              WHERE AS_Investment_Option__c = :optionValue AND archived__c = FALSE
              ORDER BY Effective_Date__c DESC
              LIMIT 1
            ];
            monthEnds.add(monthEnd);
            System.debug('monthEnds' + monthEnds);
          }

          System.debug('// if the month end list isnt empty, collect the month end investment option and the related month end into a map');
          // if the accInvestmentMap contains the month end invest option as a key value, add the list of accounts from the accInvestoptionmap to a list, then add the month end ivest option to a map with this list of accounts');

          if (monthEnds.size() > 0) {
            for (AS_Month_End__c monthEnd : monthEnds) {
              System.debug(monthEnd);

              monthEndOptionMap.put(monthEnd.AS_Investment_Option__c, monthEnd);

              if (accountInvestmentMap.containsKey(monthEnd.AS_Investment_Option__c)) {
                List<Account> accMapVals = accountInvestmentMap.get(monthEnd.AS_Investment_Option__c);
                monthEndAccMap.put(monthEnd.AS_Investment_Option__c, accMapVals);
              }
            }
            System.debug('monthEndOptionMap' + monthEndOptionMap);
            System.debug('monthEndAccMap' + monthEndAccMap);
          }

          /*
          Case 00029656 - fix: Replaced the filtered query with an unfiltered one. original query was trying to get the prev statement line items that match the fund, but the fund is changed so no prior line items exist. It needs to get all SLIs for the fund, regardless of option.
          */
          /*
          List<AS_Statement_Line_Item__c> statementlineItems = [
            SELECT Id, Name, AS_Amount__c, AS_Fund__c, AS_Type__c, AS_Investment_Option__c, AS_Month_End__r.archived__c
            FROM AS_Statement_Line_Item__c
            WHERE
              AS_Fund__c IN :scope
              AND archived__c = FALSE
              AND AS_Month_End__r.archived__c = FALSE
              AND AS_Investment_Option__c IN :monthEndOptionMap.keySet()
          ];

          System.debug('statementlineItems' + statementlineItems);
          System.debug('statementlineItems' + statementlineItems.size());

          */
          List<AS_Statement_Line_Item__c> statementlineItemsNoOptionFilter = [
            SELECT Id, Name, AS_Amount__c, AS_Fund__c, AS_Type__c, AS_Investment_Option__c, AS_Month_End__r.archived__c
            FROM AS_Statement_Line_Item__c
            WHERE AS_Fund__c IN :scope AND archived__c = FALSE AND AS_Month_End__r.archived__c = FALSE
          ];

          System.debug('statementlineItemsNoOptionFilter' + statementlineItemsNoOptionFilter);
          System.debug('statementlineItemsNoOptionFilter' + statementlineItemsNoOptionFilter.size());

          //adding 0 as starting amount before SLI calculation

          System.debug('//add up all the SLIs');
          System.debug(
            'If the accountMap (holding the list of accounts in the original scope and an amount)has the statement line item fund, add up all the SLI amounts and add the account and the SLI total to the accountAmountMap'
          );
          for (Account acc : scope) {
            accountAmountMap.put(acc.Id, 0);
            accountAmountMapNoOpt.put(acc.Id, 0);
          }
          /*
          System.debug('  //Lets compare results from the filtered query and the non filtered query');
          System.debug('  //First the filtered query');

          if (statementlineItems.size() > 0) {
            System.debug('Statement LI query size: ' + statementlineItems);

            for (AS_Statement_Line_Item__c statementlineItem : statementlineItems) {
              if (accountAmountMap.containsKey(statementlineItem.AS_Fund__c)) {
                Decimal amount = accountAmountMap.get(statementlineItem.AS_Fund__c);
                amount += statementlineItem.AS_Amount__c;
                accountAmountMap.put(statementlineItem.AS_Fund__c, amount);
              } else {
                Decimal newAmount = 0;
                newAmount += statementlineItem.AS_Amount__c;
                accountAmountMap.put(statementlineItem.AS_Fund__c, newAmount);
              }
              System.debug('accountAmountMap WITHOUT FIX' + accountAmountMap);
            }
          }
          */

          // System.debug('  //Now the non filtered query');
          if (statementlineItemsNoOptionFilter.size() > 0) {
            System.debug('Statement LI query size: ' + statementlineItemsNoOptionFilter);

            for (AS_Statement_Line_Item__c statementlineItemNoOpt : statementlineItemsNoOptionFilter) {
              if (accountAmountMapNoOpt.containsKey(statementlineItemNoOpt.AS_Fund__c)) {
                Decimal amountnoOpt = accountAmountMapNoOpt.get(statementlineItemNoOpt.AS_Fund__c);
                amountnoOpt += statementlineItemNoOpt.AS_Amount__c;
                accountAmountMapNoOpt.put(statementlineItemNoOpt.AS_Fund__c, amountnoOpt);
              } else {
                Decimal newAmountNoOpt = 0;
                newAmountNoOpt += statementlineItemNoOpt.AS_Amount__c;
                accountAmountMapNoOpt.put(statementlineItemNoOpt.AS_Fund__c, newAmountNoOpt);
              }
              System.debug('accountAmountMapNoOpt WITH FIX' + accountAmountMapNoOpt);
            }
          }

          List<Account> accWithMonthEnd = new List<Account>();

          for (Account acc : scope) {
            if (monthEndAccMap.containsKey(acc.Investment_Portfolio__c)) {
              List<Account> accnts = monthEndAccMap.get(acc.Investment_Portfolio__c);
              if (accnts.contains(acc)) {
                System.debug('acc' + acc);
                accWithMonthEnd.add(acc);
              }
            }
          }

          if (accWithMonthEnd.size() > 0) {
            System.debug(accWithMonthEnd.size());
            /*
            System.debug('Lets see what the tally is from both queries, filtered first');
            for (Account accnt : accWithMonthEnd) {
              if (accountAmountMap.containsKey(accnt.Id)) {
                Decimal amountVal = accountAmountMap.get(accnt.Id);
                System.debug('amountVal' + amountVal);

                accnt.AS_Balances_Last_Updated__c = today;
                accnt.AS_Previous_Month_End_Balance__c = amountVal;
                accnt.Balance__c = amountVal;
                accnt.AS_Primary_Balance_Updated__c = true;
                accnt.AS_Update_Balances__c = false;

                if (accnt.Investment_Portfolio__c == monthEndOptionMap.get(accnt.Investment_Portfolio__c).AS_Investment_Option__c) {
                  System.debug(monthEndOptionMap.get(accnt.Investment_Portfolio__c));

                  accnt.AS_Last_Run_Month_End__c = monthEndOptionMap.get(accnt.Investment_Portfolio__c).Id;
                }

                accountsToUpdate.add(accnt);
                System.debug('accnt' + accnt);
              }
            }

            */
            // System.debug('Lets see what the tally is from both queries, non filtered now');
            for (Account accntNoOpt : accWithMonthEnd) {
              if (accountAmountMapNoOpt.containsKey(accntNoOpt.Id)) {
                Decimal amountValNoOpt = accountAmountMapNoOpt.get(accntNoOpt.Id);
                System.debug('amountValNoOpt' + amountValNoOpt);

                accntNoOpt.AS_Balances_Last_Updated__c = today;
                accntNoOpt.AS_Previous_Month_End_Balance__c = amountValNoOpt;
                accntNoOpt.Balance__c = amountValNoOpt;
                accntNoOpt.AS_Primary_Balance_Updated__c = true;
                accntNoOpt.AS_Update_Balances__c = false;

                if (accntNoOpt.Investment_Portfolio__c == monthEndOptionMap.get(accntNoOpt.Investment_Portfolio__c).AS_Investment_Option__c) {
                  System.debug(monthEndOptionMap.get(accntNoOpt.Investment_Portfolio__c));

                  accntNoOpt.AS_Last_Run_Month_End__c = monthEndOptionMap.get(accntNoOpt.Investment_Portfolio__c).Id;
                }

                accountsToUpdateNoOpt.add(accntNoOpt);
                System.debug('accntNoOpt' + accntNoOpt);
              }
            }
          }

          // System.debug('accountsToUpdate' + accountsToUpdate);
          System.debug('accountsToUpdateNoOpt' + accountsToUpdateNoOpt);
        }
      } catch (Exception ex) {
        System.debug('error occured in execute');
        this.hasError = true;
        this.excObj = ex;

        System.debug('ex = ' + ex);
      }
    }
    System.debug('execute method done');
  }

  public void finish(Database.BatchableContext BC) {
    // System.debug('Updated the acc update to use the no opt query, issue appears to be resolved - 00029656');

    if (!this.hasError) {
      try {
        System.debug(accountsToUpdateNoOpt);
        if (accountsToUpdateNoOpt.size() != 0) {
          Database.SaveResult[] insertResults = Database.update(accountsToUpdateNoOpt, false);
          for (Database.SaveResult sr : insertResults) {
            system.debug(sr);
            if (!sr.isSuccess()) {
              Database.Error err = sr.getErrors()[0];
            }
          }
        }
      } catch (Exception ex) {
        this.hasError = true;
        this.excObj = ex;
      }
    }

    if (this.hasError) {
      //Create Exception record and send email
      AS_ExceptionHandler.createExceptionRecord(this.excObj, 'Update Giving', 'ASUpdateGivingFundGoalBatch', this.accIds);
    }
  }
}