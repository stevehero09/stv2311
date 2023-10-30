public with sharing class batchContactEmailUpdate_Caller {

    batchContactEmailUpdate bce=new batchContactEmailUpdate();
    Id batchprocess=database.executeBatch(bce);
}