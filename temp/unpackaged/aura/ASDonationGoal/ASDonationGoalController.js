({
    init : function(component, event, helper) {
        var action = component.get('c.getDonationGoalProgress');

        action.setCallback(this, function(res) {
            var state = res.getState();

            if (state === 'SUCCESS') {
                console.log(res.getReturnValue());
                component.set('v.progressDetails', res.getReturnValue());   
            }
        });

        $A.enqueueAction(action);
    }
})