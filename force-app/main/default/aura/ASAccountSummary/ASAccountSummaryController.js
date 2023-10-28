({
    init : function(component, event, helper) {
        
        var acc; 

        var action = component.get('c.getAccountRecord');
        action.setCallback(this, function(response) {
            var state = response.getState();
            if ( state == 'SUCCESS') {
                acc = response.getReturnValue();
                
                if(acc.hasOwnProperty("Balance__c")){
                    var balance_num = acc.Balance__c;
                	balance_num = parseFloat(balance_num);
                    balance_num = balance_num.toFixed(2);
                    balance_num = balance_num.toString().replace(/(\d)(?=(\d{3})+(?!\d))/g, '$1,');
                    console.log(balance_num);
                    acc.Balance__c = balance_num;
                }
                
                if(acc.hasOwnProperty("AS_Available_Balance__c")){
                    var Available_Balance_num = acc.AS_Available_Balance__c;
                	Available_Balance_num = parseFloat(Available_Balance_num);
                    Available_Balance_num = Available_Balance_num.toFixed(2);
                    Available_Balance_num = Available_Balance_num.toString().replace(/(\d)(?=(\d{3})+(?!\d))/g, '$1,');
                    console.log(Available_Balance_num);
                    acc.AS_Available_Balance__c = Available_Balance_num;
                }
                
                if(acc.hasOwnProperty("AS_Donations_Since_Inception__c")){
                    var Donations_Since_Inception_num = acc.AS_Donations_Since_Inception__c;
                	Donations_Since_Inception_num = parseFloat(Donations_Since_Inception_num);
                    Donations_Since_Inception_num = Donations_Since_Inception_num.toFixed(2);
                    Donations_Since_Inception_num = Donations_Since_Inception_num.toString().replace(/(\d)(?=(\d{3})+(?!\d))/g, '$1,');
                    console.log(Donations_Since_Inception_num);
                    acc.AS_Donations_Since_Inception__c = Donations_Since_Inception_num;
                }
                
                if(acc.hasOwnProperty("AS_Gifts_Since_Inception__c")){
                    var Gifts_Since_Inception_num = acc.AS_Gifts_Since_Inception__c;
                	Gifts_Since_Inception_num = parseFloat(Gifts_Since_Inception_num);
                    Gifts_Since_Inception_num = Gifts_Since_Inception_num.toFixed(2);
                    Gifts_Since_Inception_num = Gifts_Since_Inception_num.toString().replace(/(\d)(?=(\d{3})+(?!\d))/g, '$1,');
                    console.log(Gifts_Since_Inception_num);
                    acc.AS_Gifts_Since_Inception__c = Gifts_Since_Inception_num;
                }
                
                if(acc.hasOwnProperty("AS_Investment_Returns_Since_Inception__c")){
                    var Investment_Returns_Since_Inception_num = acc.AS_Investment_Returns_Since_Inception__c;
                	Investment_Returns_Since_Inception_num = parseFloat(Investment_Returns_Since_Inception_num);
                    Investment_Returns_Since_Inception_num = Investment_Returns_Since_Inception_num.toFixed(2);
                    Investment_Returns_Since_Inception_num = Investment_Returns_Since_Inception_num.toString().replace(/(\d)(?=(\d{3})+(?!\d))/g, '$1,');
                    console.log(Investment_Returns_Since_Inception_num);
                    acc.AS_Investment_Returns_Since_Inception__c = Investment_Returns_Since_Inception_num;
                }
                
                if(acc.hasOwnProperty("AS_Adjustments_Since_Inception__c")){
                    var Adjustments_Since_Inception_num = acc.AS_Adjustments_Since_Inception__c;
                	Adjustments_Since_Inception_num = parseFloat(Adjustments_Since_Inception_num);
                    Adjustments_Since_Inception_num = Adjustments_Since_Inception_num.toFixed(2);
                    Adjustments_Since_Inception_num = Adjustments_Since_Inception_num.toString().replace(/(\d)(?=(\d{3})+(?!\d))/g, '$1,');
                    console.log(Adjustments_Since_Inception_num);
                    acc.AS_Adjustments_Since_Inception__c = Adjustments_Since_Inception_num;
                }
                
                if(acc.hasOwnProperty("AS_Donations_YTD__c")){
                    var Donations_YTD_num = acc.AS_Donations_YTD__c;
                	Donations_YTD_num = parseFloat(Donations_YTD_num);
                    Donations_YTD_num = Donations_YTD_num.toFixed(2);
                    Donations_YTD_num = Donations_YTD_num.toString().replace(/(\d)(?=(\d{3})+(?!\d))/g, '$1,');
                    console.log(Donations_YTD_num);
                    acc.AS_Donations_YTD__c = Donations_YTD_num;
                }
                
                if(acc.hasOwnProperty("AS_Gifts_YTD__c")){
                    var Gifts_YTD_num = acc.AS_Gifts_YTD__c;
                	Gifts_YTD_num = parseFloat(Gifts_YTD_num);
                    Gifts_YTD_num = Gifts_YTD_num.toFixed(2);
                    Gifts_YTD_num = Gifts_YTD_num.toString().replace(/(\d)(?=(\d{3})+(?!\d))/g, '$1,');
                    console.log(Gifts_YTD_num);
                    acc.AS_Gifts_YTD__c = Gifts_YTD_num;
                }
                
                if(acc.hasOwnProperty("AS_Investment_Returns_YTD__c")){
                    var Investment_Returns_YTD_num = acc.AS_Investment_Returns_YTD__c;
                	Investment_Returns_YTD_num = parseFloat(Investment_Returns_YTD_num);
                    Investment_Returns_YTD_num = Investment_Returns_YTD_num.toFixed(2);
                    Investment_Returns_YTD_num = Investment_Returns_YTD_num.toString().replace(/(\d)(?=(\d{3})+(?!\d))/g, '$1,');
                    console.log(Investment_Returns_YTD_num);
                    acc.AS_Investment_Returns_YTD__c = Investment_Returns_YTD_num;
                }
                
                if(acc.hasOwnProperty("AS_Adjustments_YTD__c")){
                    var Adjustments_YTD_num = acc.AS_Adjustments_YTD__c;
                	Adjustments_YTD_num = parseFloat(Adjustments_YTD_num);
                    Adjustments_YTD_num = Adjustments_YTD_num.toFixed(2);
                    Adjustments_YTD_num = Adjustments_YTD_num.toString().replace(/(\d)(?=(\d{3})+(?!\d))/g, '$1,');
                    console.log(Adjustments_YTD_num);
                    acc.AS_Adjustments_YTD__c = Adjustments_YTD_num;
                }
                
                let data = {
                    AccDetails: acc,
                    FormattedDate: helper.getFormattedDate(acc.Date_Joined_APS__c),
                    DateFormat: helper.getFormattedDateTime(acc.AS_Balances_Last_Updated__c)
                };
                component.set("v.myAccount", data);
                
            } else {
                var errors = response.getError();                      
                console.log('response ' + errors[0].message);
            }
        });

        $A.enqueueAction(action);
 
    },
    redirectToAccount : function(component, event, helper) {
        var ctarget = event.currentTarget;
        var id_str = ctarget.dataset.id;
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": `/account/${id_str}`
        });
    
        urlEvent.fire(); 
    }
})