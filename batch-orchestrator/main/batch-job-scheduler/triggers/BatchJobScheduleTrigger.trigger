trigger BatchJobScheduleTrigger on Batch_Job_Schedule__c(before insert, before update, before delete, after insert, after update, after delete) {
    new BatchJobScheduleHandler().execute();
}
