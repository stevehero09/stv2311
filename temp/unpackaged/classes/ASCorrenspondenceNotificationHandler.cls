/**
 * Hanlder called from the trigger ASCorrespondenceNotification on Content Version record after update
 * This checks if the Related Fund is add or updated, then passes the Content Version Id
 * to the New Correnspondence Chatter Notification Flow
 * 
 * @author Von Sienard Vibar
 * @LastUpdated September 30, 2020
 */
public class ASCorrenspondenceNotificationHandler {

    /**
     * Method called from the trigger passing the Content Version records
     * If critera mets, Releted Fund is not empty or updated, 
     * it will be passed on the New Correspondence Chatter Notification flow
     * 
     * @param List<ContentVersion> oldContentVersions List of old Content Version records that are not updated yet
     * @param List<ContentVersion> newContentVersions List of updated Content Version records
     */
    public static void launchFlow(List<ContentVersion> oldContentVersions, List<ContentVersion> newContentVersions) {
        
        Map<Id, ContentVersion> oldCVMap = new Map<Id, ContentVersion>();
        Map<Id, ContentVersion> newCVMap = new Map<Id, ContentVersion>();

        List<ContentVersion> contentVersionToPassToFlow = new List<ContentVersion>();

        System.debug('oldContentVersions = ' + oldContentVersions);
        System.debug('newContentVersions = ' + newContentVersions);

        for (ContentVersion cv : oldContentVersions) {

            oldCVMap.put(cv.Id, cv);
        }

        for (ContentVersion cv : newContentVersions) {

            newCVMap.put(cv.Id, cv);
        }

        for (Id cvId : newCVMap.keySet()) {
            
            ContentVersion oldCV = oldCVMap.get(cvId);
            ContentVersion newCV = newCVMap.get(cvId);

            System.debug('oldCV.Related_Fund__c = ' + oldCV.Related_Fund__c);
            System.debug('newCV.Related_Fund__c = ' + newCV.Related_Fund__c);

            if (newCV.Related_Fund__c != null && newCV.Related_Fund__c != oldCV.Related_Fund__c) {
                
                contentVersionToPassToFlow.add(newCV);
            }
        }

        System.debug('contentVersionToPassToFlow = ' + contentVersionToPassToFlow);

        if (contentVersionToPassToFlow.size() > 0) {

            Map<String, Object> flowParams = new Map<String, Object>();
            flowParams.put('recordId', contentVersionToPassToFlow.get(0).Id);

            System.debug('flowParams = ' + flowParams);

            Flow.Interview flow = new Flow.Interview.AS_New_Correspondence_Chatter_Notification(flowParams);
            flow.start();
        }
    }
}