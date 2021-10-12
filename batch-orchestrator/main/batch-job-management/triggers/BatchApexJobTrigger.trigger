trigger BatchApexJobTrigger on Batch_Apex_Job__c(before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    TriggerFactory.executeTriggerHandlers(Batch_apex_Job__c.SObjectType);
}
