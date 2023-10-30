/**
 * Created by Mel-Goldwyn T. Samar on September 7, 2021
 * Encapsulates the Month End generation process in a batch context
 * Test Class: ASMonthEndBatch_Test
 */


 //SR this is called by the ASRUnMonthEnd component, the controler of which 'ASRunMonthEndCtrl' creates the basic record of the monthe and then passes to this batch
public class ASMonthEndBatch implements Database.Batchable<sObject>, Database.Stateful {
    public AS_Month_End__c monthEnd;
    private Set<Id> acctIdsSLI; //Stores the Account Ids of Accounts that already has a Investment Return Statement Line Items
    private Set<Id> acctIdsToUpdate; //Stores the Account Ids of Accounts that need to be updated
    private Boolean hasError; //Ensures that the batch doesn't run any logic if an error has occurred
    private Exception excObj;

    private Period currentFiscalYearSettings;

    public ASMonthEndBatch(AS_Month_End__c monthEnd){
        this.monthEnd = monthEnd;
        this.acctIdsSLI = new Set<Id>();
        this.acctIdsToUpdate = new Set<Id>();
        this.hasError = false;
    }

    public Database.QueryLocator start(Database.BatchableContext bc){
        System.debug('On Start');
        String query = '';

        // get current Fiscal Year start and end date
        System.debug('// get current Fiscal Year start and end date');
        currentFiscalYearSettings = [
            SELECT
                FiscalYearSettings.Name,
                StartDate,
                EndDate
            FROM Period
            WHERE
                Type = 'Year' AND
                StartDate <= TODAY AND
                EndDate >= TODAY
        ];

        System.debug('Current Fiscal Year details: ' +currentFiscalYearSettings);
         System.debug('Query string for ALL the active transactions within the relevant month');

        try{
            Integer numberOfDays = Date.daysInMonth(this.monthEnd.Effective_Date__c.year(), this.monthEnd.Effective_Date__c.month());
            Date startMonthDate = Date.newInstance(this.monthEnd.Effective_Date__c.year(), this.monthEnd.Effective_Date__c.month(), 1);
            Date endMonthDate = Date.newInstance(this.monthEnd.Effective_Date__c.year(), this.monthEnd.Effective_Date__c.month(), numberOfDays);
            query = 'SELECT '+
                        +'AS_Amount__c, '+
                        +'AS_Charity_Name_Text__c, '+
                        +'AS_Charity__c, '+
                        +'AS_Date__c, '+
                        +'AS_Effective_Date__c, '+
                        +'AS_Fund_CAN__c, '+
                        +'AS_Fund_Name_Text__c, '+
                        +'AS_Fund__c, '+
                        +'AS_Send_to_Email__c, '+
                        +'AS_Send_to_Xero__c, '+
                        +'AS_Statement_Line_Item__c, '+
                        +'AS_Status__c, '+
                        +'AS_Xero_Bill_ID__c, '+
                        +'AS_Xero_Invoice_ID__c, '+
                        +'Email_To__c, '+
                        +'AS_Project_Purpose__c, '+
                        +'Id, '+
                        +'Requested_By__c, '+
                        +'RecordTypeId '+
                    +'FROM '+
                        +'AS_Transaction__c '+
                    +'WHERE '+
                        +'AS_Date__c >= :startMonthDate '+
                        +'AND '+
                        +'AS_Date__c <= :endMonthDate '+
                        +'AND '+
                        +'AS_Status__c != \'Draft\' '+
                        +'AND '+
                        +'AS_Status__c != \'Rejected/Cancelled\' '+
                        +'AND '+
                        +'AS_Status__c != \'Pending Approval\' '+
                    +'ORDER BY '+
                        +'AS_Date__c ASC NULLS LAST';
        } catch(Exception ex){
            this.hasError = true;
            this.excObj = ex;
        }

        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext bc, List<AS_Transaction__c> transactions){
        System.debug('The count of unfiltered transactions to go through is: ' +transactions.size());
        System.debug('On Execute!');
        System.debug('error: '+this.hasError);
        System.debug('exception obj: '+this.excObj);
        if(this.excObj != null){
            System.debug(this.excObj.getStackTraceString());
        }
        System.debug('**scope');
        for(AS_Transaction__c trans : transactions){
            System.debug(trans);
        }
        if(!this.hasError){
            try{
                Id donationRT = Schema.SObjectType.AS_Transaction__c.getRecordTypeInfosByName().get('Donation').getRecordTypeId();
                Id giftRT = Schema.SObjectType.AS_Transaction__c.getRecordTypeInfosByName().get('Gift').getRecordTypeId();
                Id adjustmentRT = Schema.SObjectType.AS_Transaction__c.getRecordTypeInfosByName().get('Adjustment').getRecordTypeId();

                Set<Id> accountIds = new Set<Id>();

                System.debug('Get the account Ids from the queried transactions, add them to a list');

                for(AS_Transaction__c trans : transactions){
                    accountIds.add(trans.AS_Fund__c);
                }

                System.debug('The number of account Ids in the unfiltered transaction list is: '+ accountIds.size());

                Id orgRT = Schema.SObjectType.Account.getRecordTypeInfosByName().get('APS Foundation Giving Fund').getRecordTypeId();

                System.debug('Set the correct investment option based on fiscal year');
                // if set Effective date is within or beyond the current Fiscal Year
                //      use Investment Option to compare to the Month End -> Investment Option
                // else if the Effective date is before the current Fiscal Year
                //      use Previous FY Option to compare to the Month End -> Investment Option
                String investmentOptionToCompare;
                if (monthEnd.Effective_Date__c >= currentFiscalYearSettings.StartDate) {
                    investmentOptionToCompare = 'Investment_Portfolio__c';
                } else {
                    investmentOptionToCompare = 'AS_Previous_FY_Option__c';
                }

                /*
                Map<Id,Account> accountMap = new Map<Id,Account>([SELECT
                                                                        Id,
                                                                        AS_Previous_Month_End_Balance__c,
                                                                        RecordTypeId,
                                                                        RecordType.Name,
                                                                        Name
                                                                    FROM
                                                                        Account
                                                                    WHERE
                                                                        RecordTypeId =:orgRT
                                                                        AND
                                                                        (Status__c = 'Active' OR Status__c = 'Porting')
                                                                        AND
                                                                        (AS_Previous_Month_End_Balance__c != null OR AS_Previous_Month_End_Balance__c != 0)]);
                */

                String monthEndInvestmentOption = monthEnd.AS_Investment_Option__c;
                System.debug('monthEndInvestmentOption = ' + monthEndInvestmentOption);

                System.debug(' //Get the info for accounts in the transaction list above, but filtered for APSF RT and the current month end investment option and add them to a map');

                String accountMapQuery =
                    'SELECT ' +
                        'Id, ' +
                        'AS_Previous_Month_End_Balance__c, ' +
                        'RecordTypeId, ' +
                        'RecordType.Name, ' +
                        'Name ' +
                    'FROM Account ' +
                    'WHERE ' +
                        'RecordTypeId =:orgRT AND ' +
                        '(Status__c = \'Active\' OR Status__c = \'Porting\') AND ' +
                    investmentOptionToCompare + ' = :monthEndInvestmentOption';

                System.debug('accountMapQuery = ' + accountMapQuery);

                Map<Id, Account> accountMap = new Map<Id, Account>(
                    (List<Account>)Database.query(accountMapQuery)
                );

                System.debug('accountMap = ' + accountMap);

                Decimal totalBalance = 0;

                System.debug('For all accounts in the map, if the prev month end balance is not null, add their prev balances to set the totalbalance and then add the acc ids to a set');

                for(Id acctId : accountMap.keySet()){
                    Account acct = accountMap.get(acctId);

                    if(acct.AS_Previous_Month_End_Balance__c != null){
                     	totalBalance += acct.AS_Previous_Month_End_Balance__c.setScale(2);
                    }
                    accountIds.add(acct.Id);
                }

                System.debug('The totalbalance after the loop is: '+ totalBalance);
                System.debug('The accounts in the set are: '+ accountIds);
                System.debug('query all previous SLIs for those accounts and stick them in a map. Since the SLI balance should reflect the acc balanace, ok to overwrite');

                List<AS_Statement_Line_Item__c> listStateLineItem = [SELECT
                                                                            Id,
                                                                            AS_Fund__c,
                                                                            AS_Balance__c
                                                                        FROM
                                                                            AS_Statement_Line_Item__c
                                                                        WHERE
                                                                            AS_Fund__c in :accountIds AND archived__c = false
                                                                        ORDER BY Name ASC];

                Map<Id, Decimal> sliBalancePerAccount = new Map<Id, Decimal>();
                for(AS_Statement_Line_Item__c statementLineItem : listStateLineItem){
                    sliBalancePerAccount.put(statementLineItem.AS_Fund__c, statementLineItem.AS_Balance__c);
                }

                System.debug('The map of SLIBalanacePerAccount is: ' +sliBalancePerAccount);
                System.debug('so now we have map of fund ids and their balances');

                List<AS_Statement_Line_Item__c> statementLineItems = new List<AS_Statement_Line_Item__c>();
                Map<Id, Decimal> acctLastMonthBal = new Map<Id, Decimal>();

                System.debug('loop through all transactions, if the account is already in the map, get the relevant balanace and add it to lastMonthBal, else if the sli balance is not null, add it to lastMonthBal, otherwise add 0');

                for(AS_Transaction__c trans : transactions){
                    Decimal lastMonthBal = 0;

                    if(acctLastMonthBal.containsKey(trans.AS_Fund__c)){
                        lastMonthBal = acctLastMonthBal.get(trans.AS_Fund__c);
                    } else {
                        lastMonthBal = (sliBalancePerAccount.get(trans.AS_Fund__c) != null ? sliBalancePerAccount.get(trans.AS_Fund__c) : 0);
                    }

                    Account acct = (accountMap.containsKey(trans.AS_Fund__c) ? accountMap.get(trans.AS_Fund__c) : null);


                    System.debug('So if the account exists in the map from earlier and the total balance is not 0, then if the accounts prev month end bal is not 0, call the SLI calc method');
                // So if the account exists in the map from earlier and the total balance is not 0, then if the account's prev month end bal is not 0, call the SLI calc method
                //public static Decimal calculateSLIAmount(Decimal changeInFoundVal, Decimal totalPrevMonthEndBal, Decimal prevMonthEndBal) {
                //@description: method for caculating all Account balance to get percentage amount
                    if(acct != null){
                        if(!this.acctIdsSLI.contains(acct.Id) && totalBalance != 0  ){
                            Decimal calculation = (acct.AS_Previous_Month_End_Balance__c != null ? ASMonthEndTriggerHandler.calculateSLIAmount(this.monthEnd.Total_Valuation__c, totalBalance, acct.AS_Previous_Month_End_Balance__c).setScale(2) : 0);
                            lastMonthBal += calculation;

                            System.debug('The account and its last month balance are: ' + acct + lastMonthBal);


                            //if the returned calculation is not 0, then work out their investment return. method for creating Statement Line Item record for Investment returns
                            //acctIdsSLI Stores the Account Ids of Accounts that already has a Investment Return Statement Line Items
                            if( calculation !=0 ){
                                AS_Statement_Line_Item__c newInvestmentReturnSLI = ASMonthEndTriggerHandler.createInvestmentReturnSLI(this.monthEnd, acct, calculation, lastMonthBal);
                                statementLineItems.add(newInvestmentReturnSLI);
                                this.acctIdsSLI.add(acct.Id);
                            }



                        }
                    }

                    Decimal amount = 0;
                    String type = '';

                    if(trans.RecordTypeId == donationRT){
                        type = 'Donation';
                        amount = trans.AS_Amount__c.setScale(2);
                    } else if(trans.RecordTypeId == giftRT){
                        type = 'Gift';
                        if(trans.AS_Amount__c > 0) amount = -trans.AS_Amount__c;
                        else amount = trans.AS_Amount__c.setScale(2);
                    } else if(trans.RecordTypeId == adjustmentRT){
                        type = 'Adjustment';
                        amount = trans.AS_Amount__c.setScale(2);
                    }
                    lastMonthBal += amount;
                    System.debug('The lastMonthBal is: ' + lastMonthBal);

                    System.debug('accountMap.containsKey(trans.AS_Fund__c) = ' + accountMap.containsKey(trans.AS_Fund__c));

                    System.debug('Only create SLI from transaction if the related account has the same selected option from Month End option');

                    System.debug('This isnt firing??');
                    if (accountMap.containsKey(trans.AS_Fund__c)) {
                        AS_Statement_Line_Item__c newSLI = ASMonthEndTriggerHandler.createSLI(trans.RecordTypeId, trans, this.monthEnd, lastMonthBal, type, amount);
                        statementLineItems.add(newSLI);
                    }

                    acctLastMonthBal.put(trans.AS_Fund__c, lastMonthBal.setScale(2));
                }

                System.debug('The accLastMonBal map is: ' + acctLastMonthBal);

                if(!accountMap.isEmpty()){
                    Decimal lastMonthBal = 0;

                    for(Id acctId : accountMap.keySet()){
                        if(acctLastMonthBal.containsKey(acctId)){
                            lastMonthBal = acctLastMonthBal.get(acctId);
                        } else {
                            lastMonthBal = (sliBalancePerAccount.get(acctId) != null ? sliBalancePerAccount.get(acctId) : 0);
                        }

                        System.debug('');
                        if(!this.acctIdsSLI.contains(acctId) && totalBalance != 0 ){
                            Account acct = accountMap.get(acctId);
                            Decimal calculation = (acct.AS_Previous_Month_End_Balance__c != null ? ASMonthEndTriggerHandler.calculateSLIAmount(monthEnd.Total_Valuation__c, totalBalance, acct.AS_Previous_Month_End_Balance__c) : 0);
                            lastMonthBal += calculation;

                            System.debug('');
                            if( calculation !=0 ){
                                AS_Statement_Line_Item__c newInvestmentReturnSLI = ASMonthEndTriggerHandler.createInvestmentReturnSLI(this.monthEnd, acct, calculation, lastMonthBal);
                                statementLineItems.add(newInvestmentReturnSLI);
                                this.acctIdsSLI.add(acctId);
                            }

                        }

                        acctLastMonthBal.put(acctId, lastMonthBal.setScale(2));
                    }
                     System.debug('The accLastMonBal map AFTER the SLI creation calls is: ' + acctLastMonthBal);
                }


                System.debug('');

                insert statementLineItems;
                System.debug('inserted SLIs: '+statementLineItems);

                List<AS_Transaction__c> updatedTransactions = new List<AS_Transaction__c>();

                for(AS_Statement_Line_Item__c statementLineItem : statementLineItems){
                    if(statementLineItem.AS_Transaction_Relationship_Id__c != null){
                        updatedTransactions.add(new AS_Transaction__c(
                            Id = statementLineItem.AS_Transaction_Relationship_Id__c,
                            AS_Statement_Line_Item__c = statementLineItem.Id,
                            AS_Investment_Option__c = monthEnd.AS_Investment_Option__c
                        ));
                    }

                    this.acctIdsToUpdate.add(statementLineItem.AS_Fund__c);
                }

                System.debug('updatedTransactions before insert = ' + updatedTransactions);

                if(updatedTransactions.size() > 0){
                    update updatedTransactions;
                }
                System.debug('updated transactions: '+updatedTransactions);
            } catch(Exception ex){
                System.debug('error occured in execute');
                this.hasError = true;
                this.excObj = ex;

                System.debug('ex = ' + ex);
            }
        }
        System.debug('execute method done');
    }

    public void finish(Database.BatchableContext bc){
        if(!this.hasError){
            try {
                if(this.acctIdsToUpdate.size() > 0){
                    List<Account> accts = new List<Account>();

                    for(Id acctId : acctIdsToUpdate){
                        if(acctId != null){
                            Account acct = new Account(
                                Id = acctId
                            );

                            accts.add(acct);
                        }
                    }
                    System.debug('The list of accs to update: '+ accts);

                }


                ASMonthEndTriggerHandler.sendEmail(this.monthEnd);

                //Code so far is fine, this is where the issue starts for the PFY issue
                //TODO - This needs to be dynamic for PFY etc
                // run Update Balance batch
                System.debug('This is where the issues start for the PFY issue for the switched issue, its still ok as the list of accts to update match the month end option');
                String status = 'active';
                List<Id> updatedAccts_ids = new List<Id>();
                for(Account acct : [SELECT Id, Name,Investment_Portfolio__c FROM Account WHERE Status__c =:status AND Investment_Portfolio__c =:this.monthEnd.AS_Investment_Option__c]){
                   updatedAccts_ids.add( acct.Id );
                }

System.debug('Calls the update balances code with teh list of acc ids');
                ASUpdateGivingFundGoalBatch updateGivingGoalBatch = new ASUpdateGivingFundGoalBatch(updatedAccts_ids);
                Database.executeBatch(updateGivingGoalBatch,50);

            } catch(Exception ex){
                this.hasError = true;
                this.excObj = ex;
            }
        }

        if(this.hasError){
            //Create Exception record and send email
            AS_ExceptionHandler.createException(this.excObj, 'Month End', 'ASMonthEndBatch', this.monthEnd.Id);

            //AS_Month_End__c the_monthend = this.monthEnd;
            this.monthEnd.archived__c = true;
            this.monthEnd.Roll_Back_Note__c ='Monthend Process Encountered some Error! Please check error logs.';
            update this.monthEnd;

            //Run Roll Back batch to delete records created
            ASMonthEndRollback rollbackBatch = new ASMonthEndRollback(this.monthEnd);
            Database.executeBatch(rollbackBatch);
        }

    }
}