public without sharing class BatchOrchestrator {
    public static void runBatchScheduleById(Id scheduleId) {
        BatchJobScheduler adhocSchedule = new BatchJobScheduler();
        adhocSchedule.batchJobs = adhocSchedule.loadActiveBatchJobsById(scheduleId);
        adhocSchedule.executeJobs();
    }

    public static void runBatchJob(Id batchJobId) {
        Batch_Apex_Job__c batchApexJob = [
            SELECT Batch_Class_Name__c, Batch_Job_Schedule__c, Batch_Size__c, RecordType.DeveloperName, EnhancedLogging__c
            FROM Batch_Apex_Job__c
            WHERE Id = :batchJobId
        ];
    }

    public static void runBatchJob(Batch_Apex_Job__c batchApexJob) {
        BatchJobBase batchJobToRun = (BatchJobBase) Type.forName(batchApexJob.Batch_Class_Name__c).newInstance();
        batchJobToRun.jobType = batchApexJob.RecordType.DeveloperName;
        batchJobToRun.executeNextJob = false;
        batchJobToRun.jobId = batchApexJob.Id;
        batchJobToRun.scheduleId = batchApexJob.Batch_Job_Schedule__c;
        batchJobToRun.className = batchApexJob.Batch_Class_Name__c;
        batchJobToRun.enhancedLoggingEnabled = batchApexJob.EnhancedLogging__c;

        batchJobToRun.enqueue(Integer.valueOf(batchApexJob.Batch_Size__c));
    }
}
