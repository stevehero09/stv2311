({
    executeBatch : function (cmp){
        var action = cmp.get("c.executeBatchJob");

        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "type": "success",
                    "title": "Success!",
                    "message": "The Job has been successfully initiated."
                });
                toastEvent.fire();
console.log('aasdd' , response.getReturnValue());
                if (state === "SUCCESS"){
                    cmp.set('v.showProgressBar', true);

                    var interval = setInterval($A.getCallback(function () {
                        var jobStatus = cmp.get("c.getBatchJobStatus");
                        if(jobStatus != null){
                            jobStatus.setParams({ jobIds : response.getReturnValue()});
                            jobStatus.setCallback(this, function(jobStatusResponse){
                                var state = jobStatus.getState();
                                if (state === "SUCCESS"){
                                    var job = jobStatusResponse.getReturnValue();
                                    var totalItemProcessed = 0;
                                    var totalItem = 0;
                                    var processedPercent = 0;
                                    console.log(job);
                                    
                                    job.forEach(jobItem => {
                                        totalItem += jobItem.TotalJobItems;
                                        totalItemProcessed += jobItem.JobItemsProcessed;
                                    });

                                    processedPercent = (totalItemProcessed / totalItem) * 100;
                                    console.log(processedPercent);

                                    cmp.set('v.progress', processedPercent);
                                    cmp.set('v.totalItem', totalItem);
                                    cmp.set('v.totalItemProcessed', totalItemProcessed);

                                    if (processedPercent === 100) {
                                        cmp.set('v.isCompleted', true);
                                        clearInterval(interval);
                                    }

                                    // cmp.set('v.apexJob',job);
                                    // var processedPercent = 0;
                                    // if(job.JobItemsProcessed != 0){
                                    //     processedPercent = (job.JobItemsProcessed / job.TotalJobItems) * 100;
                                    // }
                                    // var progress = cmp.get('v.progress');
                                    // cmp.set('v.progress', progress === 100 ? clearInterval(interval) :  processedPercent);
                                }
                            });
                            $A.enqueueAction(jobStatus);
                        }
                    }), 2000);
                }
            }
            else if (state === "ERROR") {
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "type": "error",
                    "title": "Error!",
                    "message": "An Error has occured. Please try again or contact System Administrator."
                });
                toastEvent.fire();
            }
        });
        $A.enqueueAction(action);
    }
});