trigger BatchJobScheduleTrigger on Batch_Job_Schedule__c (before insert, before update, before delete, after insert, after update, after delete) {
    
    TriggerFactory.executeTriggerHandlers(Batch_Job_Schedule__c.SObjectType);
      
}