global class batchASICCreate implements Schedulable {
   global void execute(SchedulableContext sc) {
      batchCreateASICRecords b = new batchCreateASICRecords(); 
      database.executebatch(b);
   }
}