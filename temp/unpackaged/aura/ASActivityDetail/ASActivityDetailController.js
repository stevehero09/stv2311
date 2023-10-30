({
    init : function(component, event, helper) {

        var action = component.get('c.getAccountRecord');
        action.setCallback(this, function(response) {

            var state = response.getState();
            if ( state == 'SUCCESS') {
                var acc = response.getReturnValue();
                console.log(acc);
                component.set("v.myAccount", acc);
            } else {
                var errors = response.getError();                      
                console.log('response ' + errors[0].message);
            }

        });

        $A.enqueueAction(action);
    }
})