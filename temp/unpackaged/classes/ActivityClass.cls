public inherited sharing class ActivityClass {
    
    @AuraEnabled(Cacheable = true)
    public static List<Task> getActivity(string CaseLd){ 
        return  [SELECT Id, Subject,Description,ActivityDate, Status,What.Type,TaskURl__c, whatId,Estimated_Time_Required__c FROM Task WHERE What.Type IN ('Case') And  whatId=: CaseLd ORDER BY CreatedDate asc];
       
    }


    @AuraEnabled
    public static void deleteActivity(list<Id> lstCaseIds){
        try {
           list<Task> eventToDelete = new list<Task>();

           
            for(Id idCase : lstCaseIds) {
                eventToDelete.add(new Task(Id = idCase));  
            }
            if(!eventToDelete.isEmpty()) {
                delete eventToDelete;
            }  
        }
        catch(Exception ex) {
            throw new AuraHandledException(ex.getMessage());
        }
    }

    @AuraEnabled
    public static void UpdateActivity(list<Id> lstEventIds, string lstDetails){
        try {
           list<Task> eventToDelete = new list<Task>();

           
            for(Id idCase : lstEventIds) {
                eventToDelete.add(new Task(Id = idCase, Status = lstDetails));  
            }
            if(!eventToDelete.isEmpty()) {
                Update eventToDelete;
            }  
        }
        catch(Exception ex) {
            throw new AuraHandledException(ex.getMessage());
        }
    }


    
}