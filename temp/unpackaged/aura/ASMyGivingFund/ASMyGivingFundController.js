({
	init : function(component, event, helper) {
		let action = component.get('c.getAccountRecord');
        action.setCallback(this, function(response) {
            let state = response.getState();console.log(response.getError());
            
            if( state == 'SUCCESS' ) {
                let record = response.getReturnValue();
                
                console.log('Acct Record:');
                console.log(record);
                component.set('v.myGivingAcct', record);
            }
        });
        $A.enqueueAction(action);
	}
})