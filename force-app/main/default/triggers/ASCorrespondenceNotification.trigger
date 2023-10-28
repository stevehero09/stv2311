/**
 * Trigger called on Content Version once the record is being updated
 * Calling the handler ASCorrenspondenceNotificationHandler that will launch a flow
 * 
 * @author Von Sienard Vibar
 * @LastUpdated September 30, 2020
 */
trigger ASCorrespondenceNotification on ContentVersion (after update) {

    if (Trigger.isUpdate) {

        ASCorrenspondenceNotificationHandler.launchFlow(Trigger.old, Trigger.new);
    }
}