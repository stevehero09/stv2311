({
	myAction : function(component, event, helper) {
		
	}, 

	handleNotify: function(component, event, helper) {

		var investmentOption = component.get('v.investmentOption');

		var action = component.get('c.notify');
		action.setParams({
			'investmentOption': investmentOption
		});
		action.setCallback(this, function(response) {

			var state = response.getState();

			var toastEvent = $A.get("e.force:showToast");

			if (state === 'SUCCESS') {

				toastEvent.setParams({
					"title": 'Success',
					"type" : 'success',
					"message": 'Month End Notification Batch is now running'
				});
				toastEvent.fire();

			} else {

				toastEvent.setParams({
					"title": 'Error',
					"type" : 'error',
					"message": 'Something went wrong'
				});
				toastEvent.fire();
			}

			$A.get("e.force:closeQuickAction").fire(); 
			$A.get("e.force:refreshView").fire();
		});

		$A.enqueueAction(action);
	}
})