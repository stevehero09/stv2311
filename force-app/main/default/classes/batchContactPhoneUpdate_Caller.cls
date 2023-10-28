public with sharing class batchContactPhoneUpdate_Caller {

    batchContactPhoneUpdate bcpu=new batchContactPhoneUpdate();
    Id batchprocess=database.executeBatch(bcpu);
}