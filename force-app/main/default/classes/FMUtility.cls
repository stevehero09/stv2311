/**
* Revisions:	
* 15-Jan-2023 - Stephen Manning	- Deprecated "Temp FM" category - Case#00023770.
* -
* 27-Aug-2023 - Stephen Manning - Set FM Paper Author to "CSA" - Case#00027639.
*/ 

public class FMUtility 
{
    
    public static void beforeInsert(List<Foundation_Meeting__c> triggerNew)
    {        
        system.debug('Entering fmUtility.beforeInsert');
        Id AdminId = [select id,Name from User where Profile.Name = 'System Administrator' and Name = 'System Admin' limit 1].id;   
        for(Foundation_Meeting__c fm : triggerNew)
        {    
            if(fm.Paper_Author__c == null && AdminId != null)
            {
                fm.Paper_Author__c = AdminId;
            } //end if
		} //end for
    } //end beforeInsert
    
  @future
    public static void afterInsert(set<id> ids)
    {    
        system.debug('Entering fmUtility.afterInsert futureHandler');
        List <Foundation_Meeting__c> fmsToUpdate = new list <Foundation_Meeting__c>();
        Id recordtypeid = [select id from recordtype where name = 'Foundation Meetings' AND sobjecttype = 'Case'].id;
        Id AdminId = [select id,Name from User where Profile.Name = 'System Administrator' and Name = 'System Admin' limit 1].id;
        List<case> caselist = new List<case>();
        for(Foundation_Meeting__c fm : [select id,Organisation_Name__c,Paper_Author__c,Meeting_type__c,Date_of_Meeting__c, organisation_name__r.csa__c 
                                        from Foundation_Meeting__c 
                                        where id in:ids ])
        {
            // CASE#00027639 - Set PaperAuthor to Organisation.CSA for new FMs only
            if (fm.Organisation_Name__r.csa__c != null)
            {
                fm.Paper_Author__c = fm.Organisation_Name__r.csa__c;
            	/*system.debug('afterinsert - value of fm.Organisation_Name__r.id is: ' + fm.Organisation_Name__r.id);
            	system.debug('afterinsert - value of fm.Organisation_Name__r.csa__c is: ' + fm.Organisation_Name__r.csa__c);
            	system.debug('afterinsert - value of fm.Organisation_Name__c is: ' + fm.Organisation_Name__c);
            	system.debug('Value of fm.Paper_Author__c is: ' + fm.Paper_Author__c);*/
            	fmsToUpdate.add(fm);
            } //end if
              	
            //}
			
            
                
            Case cs = new Case();
            cs.AccountId = fm.Organisation_Name__c ;
            if(fm.Paper_Author__c == null && AdminId != null) {
                
                cs.Assigned_to__c = AdminId;
            }
                
            else {
                
                cs.Assigned_to__c = fm.Paper_Author__c ;
            	cs.ownerid = fm.Paper_Author__c;
                
            }
            cs.Case_FM_lookup__c = fm.id;
             // cs.Category__c = 'Temp FM'; <-- Comment-out existing code for Case#00023770.
             // Below code block for Case#00023770 : Deprecation of 'Temp FM' category.
            try{
                switch on fm.Meeting_Type__c
                {
                    when 'Annual'			{ cs.Category__c = 'Foundation Meeting - AM'; }
                    when 'Initial Trustee'	{ cs.Category__c = 'Foundation Meeting - ITM'; }
                    when 'ITM/AM Mash'		{ cs.Category__c = 'Foundation Meeting - MASH'; }
                    when 'Mid Year Meeting' { cs.Category__c = 'Foundation Meeting - MYM'; }
                    when 'Wind Up'			{ cs.Category__c = 'Foundation Meeting - Wind Up'; }
                    when 'Exiting'			{ cs.Category__c = 'Foundation Meeting - Exiting'; }
                } //end switch
            } //end try
            catch (exception e)
            {
                system.debug('FMUtility.afterInsert - Error assigning category for FM Parent Case in!! - ' +e.getMessage());
            } //end catch
            cs.RecordTypeId = recordtypeid;
            cs.Type = fm.Meeting_type__c;
            cs.Due_Date__c = fm.Date_of_Meeting__c;
            cs.Summary__c = fm.Organisation_Name__c;
            cs.Status = 'New';
            cs.Reason = fm.Meeting_type__c;
            caselist.add(cs);
            
        
        
        if(!caselist.isEmpty())
            insert caselist;
                
            }
        
        if(!fmsToUpdate.isEmpty())
        {
            update(fmsToUpdate);
        }
            
            
    
    }
    
    
    public static void afterUpdate(set<id> ids, Map<id,Foundation_Meeting__c> triggerNewMap, Map<id,Foundation_Meeting__c> triggerOldMap){
        
        
        /*List<case> newSubCases = new List<case>();
        Id recordtypeid = [select id from recordtype where name = 'Subcases' AND sobjecttype = 'Case'].id;*/
        
        List<case> caselist = new List<case>();
        caselist = [select id,Due_Date__c,Assigned_to__c,AccountId, Case_FM_lookup__c,Type  from Case where Case_FM_lookup__c in : ids];
        
        Id AdminId = [select id,Name from User where Profile.Name = 'System Administrator' and Name = 'System Admin' limit 1].id;
        if(!caselist.isEmpty()){
            
        for(Case cs : caselist){
            
           	Foundation_Meeting__c oldFM = triggerOldMap.get(cs.Case_FM_lookup__c);
            Foundation_Meeting__c newFM = triggerNewMap.get(cs.Case_FM_lookup__c);
            
            if(oldFM.Paper_Author__c != newFM.Paper_Author__c)
           		cs.Assigned_to__c = newFM.Paper_Author__c ;
            if(newFM.Paper_Author__c == null && AdminId != null)
                cs.Assigned_to__c = AdminId;
            if(oldFM.Date_of_Meeting__c != newFM.Date_of_Meeting__c){
                cs.Due_Date__c = newFM.Date_of_Meeting__c;
                
                /*Case subcs = new Case();
                subcs.AccountId = cs.AccountId ;
                subcs.Assigned_to__c = cs.Assigned_to__c;
                //subcs.Case_FM_lookup__c = newFM.id;
                subcs.RecordTypeId = recordtypeid;
                subcs.Type = cs.Type;
                subcs.Due_Date__c = newFM.Date_of_Meeting__c;
                subcs.Summary__c = 'Meeting date changed';
                subcs.Reason = 'Change of Meeting Date';
                subcs.Status = 'New';
                subcs.Estimated_time_for_case__c = 0.28;
                subcs.ParentId = cs.id;
                newSubCases.add(subcs);*/
                
            }
           		
           
          
        }
        
        
       		update caselist;
            
            /*if(!newSubCases.isEmpty()){
                insert newSubCases;
            }*/
	 }
        
    
    }

}