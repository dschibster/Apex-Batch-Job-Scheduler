public with sharing class RunBatchJobScheduleController {
    Batch_Job_Schedule__c scheduleRecord;

    public RunBatchJobScheduleController(ApexPages.StandardController stdCtrl) {
         scheduleRecord = (Batch_Job_Schedule__c) stdCtrl.getRecord();
    }

    public PageReference runSchedule(){
        BatchJobScheduler adhocSchedule = new BatchJobScheduler();
        adhocSchedule.batchJobs = adhocSchedule.loadActiveBatchJobsById(scheduleRecord.Id);
        adhocSchedule.executeJobs();
        PageReference ref = new PageReference('/'+scheduleRecord.Id);
        ref.setRedirect(true);
        return ref;
    }
}
