({
    init : function(component, event, helper) {
        let action = component.get('c.getAccountRecord');

        action.setCallback(this, function(response) {
            let state = response.getState();

            if(state === 'SUCCESS') {
                var accrec_result = response.getReturnValue();
                console.log(accrec_result);
                
                if(accrec_result.hasOwnProperty("Balance__c")){
                    var balance_num = accrec_result.Balance__c;
                	balance_num = parseFloat(balance_num);
                    balance_num = balance_num.toFixed(2);
                    balance_num = balance_num.toString().replace(/(\d)(?=(\d{3})+(?!\d))/g, '$1,');
                    console.log(balance_num);
                    accrec_result.Balance__c = balance_num;
                }
                
                if(accrec_result.hasOwnProperty("AS_Available_Balance__c")){
                    var Available_Balance_num = accrec_result.AS_Available_Balance__c;
                	Available_Balance_num = parseFloat(Available_Balance_num);
                    Available_Balance_num = Available_Balance_num.toFixed(2);
                    Available_Balance_num = Available_Balance_num.toString().replace(/(\d)(?=(\d{3})+(?!\d))/g, '$1,');
                    console.log(Available_Balance_num);
                    accrec_result.AS_Available_Balance__c = Available_Balance_num;
                }
                
                component.set('v.myAccountRecord', accrec_result);
            }
        });

        $A.enqueueAction(action);
    }
})