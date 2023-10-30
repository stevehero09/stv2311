({   

    saveRecordMonthEnd : function(component, event, helper) {

        let onClickBtn = component.find('saveBtnId');
        let monthEndName = component.find('monthEndName').get('v.validity').valid;
        let changeInFoundVal = component.find('changeInFoundVal').get('v.validity').valid;
        let EffectiveDate = component.find('EffectiveDate').get('v.validity').valid;
        let investmentOption = component.find('investmentOption').get('v.validity').valid;
        console.log('monthEndName  '+monthEndName);
        console.log('changeInFoundVal  '+changeInFoundVal);
        console.log('EffectiveDate  '+EffectiveDate);
        if( monthEndName && changeInFoundVal && EffectiveDate && investmentOption ) {

            onClickBtn.set('v.disabled',true);

        }

        var simplenewMonthEnd = component.get("v.simplenewMonthEnd");
        var action = component.get("c.saveRecord");
        action.setParams({
            simplenewMonthEnd : simplenewMonthEnd
        });
        action.setCallback(this,function(a){
            var state = a.getState();
            var errormsg;

            console.log('state  '+state);
            if(state === "SUCCESS"){
                errormsg = a.getReturnValue();
                
                var resultsToast = $A.get("e.force:showToast");
                resultsToast.setParams({
                    "title": (errormsg.IsSuccess == 'yes'? 'Success' : 'Error'),
                    "type" : (errormsg.IsSuccess == 'yes'? 'success' : 'error'),
                    "message": errormsg.Message
                });
                
                if(errormsg.IsSuccess == 'yes') {
                    $A.get("e.force:closeQuickAction").fire(); 
                    $A.get("e.force:refreshView").fire();
                } else {
                    onClickBtn.set('v.disabled',false);
                }
                resultsToast.fire();
                
            } else if(state === "ERROR"){
                var errors = action.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        alert(errors[0].message);
                    }
                }
            }else if (status === "INCOMPLETE") {
                onClickBtn.set('v.disabled',false);
                alert('No response from server or client is offline.');
            }
        });       
        $A.enqueueAction(action);
        
    }


})