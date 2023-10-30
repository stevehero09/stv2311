/*
 * Title	: CaseUtilityHandler
 * Author	: Stephen M
 * Date		: 20230213
 * Descr	: prevents recursive trigger updates in DML calls from CaseUtility
 */

public class CaseUtilityHandler {
    public static boolean casesNotUpdatedYet = True;
    public static boolean tasksNotUpdatedYet = True;

    public static void CaseHandlerMethod(Set<Case> CasesToUpdateSet)
    {
        if ((CasesToUpdateSet != NULL) && (CasesToUpdateSet.size() > 0))            
        {
           	system.debug('CaseUtilityHandler.CaseHandlerMethod - setting "casesNotUpdatedYet" (' + casesNotUpdatedYet + ') to FALSE and UPDATING' + casesToUpdateSet.size() + 'cases...');
        	casesNotUpdatedYet = False;
            List<Case> CasesToUpdateList = New List<Case>(CasesToUpdateSet);
            Update(CasesToUpdateList);
        }
	}//end CaseHandlerMethod
    
    public static void TaskHandlerMethod(Set<Task> TasksToUpdateSet)
    {
        if((TasksToUpdateSet.size()>0) && (TasksToUpdateSet != NULL))
        {
            system.debug('CaseUtilityHandler.TaskHandlerMethod - setting "tasksNotUpdatedYet" (' + tasksNotUpdatedYet + ') to FALSE and UPDATING' + tasksToUpdateset.size() + 'tasks...');
            tasksNotUpdatedYet = False;
			system.debug('Updating TasksToUpdateSet.... ');
            List <Task> TasksToUpdateList = new List <Task>(TasksToUpdateSet);
            update (TasksToUpdateList);   
        }
    } //end TaskHandlerMethod
}