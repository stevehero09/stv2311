({
    getAllRecords :  function(component) {
        var action = component.get("c.getAllRecords");
        action.setcallback(this, function(response) {
            var state = response.getState();
            if(component.isValid() && state === "SUCCESS") {
                component.set("v.recordDetails", response.getReturnValue());
            }
        });
        $A.enqueueAction(action);
    },

    createRecord : function(component, RecordDetail) {
        this.upsertRecord(component, RecordDetail, function(a) {
            var recordDetails = component.get("v.recordDetails");
            recordDetails.push(a.getReturnValue());
            component.set("v.recordDetails", recordDetails);
        });
    },

    upsertRecord :function(component, RecordDetail, callback) {
        var action = component.get("c.saveRecord");
        action.setParams({
            "RecordDetail": RecordDetail
        });
        if (callback) {
            action.setCallback(this, callback);
        }
        $A.enqueueAction(action);
    },
    
    validateContactForm: function(component) {
        var validContact = true;

         // Show error messages if required fields are blank
        var allValid = component.find('contactField').reduce(function (validFields, inputCmp) {
            inputCmp.showHelpMessageIfInvalid();
            return validFields && inputCmp.get('v.validity').valid;
        }, true);

        if (allValid) {
            // Verify we have an account to attach it to
            var account = component.get("v.account");
            if($A.util.isEmpty(account)) {
                validContact = false;
                console.log("Quick action context doesn't have a valid account.");
            }
            return(validContact);
        }  
    }
})