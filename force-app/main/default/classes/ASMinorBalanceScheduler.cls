global  class ASMinorBalanceScheduler implements Schedulable  {	
	global void execute(SchedulableContext ctx){
        
        ASMinorBalanceUpdatesBatchv2 focusedbatch = new ASMinorBalanceUpdatesBatchv2('Focused Portfolio');
        Database.executeBatch(focusedbatch,10);
        
        ASMinorBalanceUpdatesBatchv2 generalbatch = new ASMinorBalanceUpdatesBatchv2('General Portfolio');
        Database.executeBatch(generalbatch,10);
        
    }
}