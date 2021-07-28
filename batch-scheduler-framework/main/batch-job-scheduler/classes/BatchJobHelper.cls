public inherited sharing class BatchJobHelper {
    
    public static void logBatchJob(String batchJobName, Id asyncJobId, Id scheduleId, Id jobId) {
        logBatchJob(batchJobName, asyncJobId, '', scheduleId, jobId);
    }

    //Log batch job exection result
    public static void logBatchJob(String batchJobName, Id asyncJobId, String summary, Id scheduleId, Id jobId) {
        AsyncApexJob job = [
            SELECT
                Id,
                Status,
                NumberOfErrors,
                JobItemsProcessed,
                TotalJobItems,
                CompletedDate,
                CreatedBy.Email,
                ExtendedStatus
            FROM AsyncApexJob
            WHERE Id = :asyncJobId
        ];

        String executeResult = job.ExtendedStatus;

        // Create a batch job log record to notify the batch job execute result
        try {
            Batch_Job_Log__c bjl = new Batch_Job_Log__c(
                Batch_Job_Name__c = batchJobName,
                Batch_Apex_Job__c = jobId,
                Batch_Job_Schedule__c = scheduleId,
                Completed_Date__c = job.CompletedDate,
                Status__c = job.Status,
                Batches_Processed__c = job.JobItemsProcessed,
                Number_of_Errors__c = job.NumberOfErrors,
                Execution_Result__c = (String.isNotBlank(executeResult) ? executeResult : '') +
                    (String.isNotBlank(summary) ? '\n' + summary : '')
            );
            insert bjl;
        } catch (Exception ex) {
            throw new DmlException('Failed to save batch job log: ' + ex.getMessage());
        }
    }

    //Log batch job exection result
    public static void logBatchJob(String batchJobName, DateTime completedDate, String errorMessages) {
        // Create a batch job log record to notify the batch job execute result
        try {
            Batch_Job_Log__c bjl = new Batch_Job_Log__c(
                Batch_Job_Name__c = batchJobName,
                Completed_Date__c = completedDate,
                Execution_Result__c = errorMessages
            );
            insert bjl;
        } catch (Exception ex) {
            throw new DmlException('Failed to save batch job log. ' + ex.getMessage());
        }
    }
}