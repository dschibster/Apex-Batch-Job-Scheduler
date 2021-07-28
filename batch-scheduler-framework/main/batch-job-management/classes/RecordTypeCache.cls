public inherited sharing class RecordTypeCache {
    
    private static Map<String, Schema.RecordTypeInfo> rtInfosBatchJobSchedule = Schema.SObjectType.Batch_Job_Schedule__c.getRecordTypeInfosByDeveloperName();
    private static Map<String, Schema.RecordTypeInfo> rtInfosBatchJobApexJob = Schema.SObjectType.Batch_Apex_Job__c.getRecordTypeInfosByDeveloperName();
    public static final Id SCHEDULER_RECORD_TYPE_HOURLY_JOB  = rtInfosBatchJobSchedule.get('Hourly_Job').getRecordTypeId();
    public static final Id SCHEDULER_RECORD_TYPE_DAILY_JOB   = rtInfosBatchJobSchedule.get('Daily_Job').getRecordTypeId();
    public static final Id SCHEDULER_RECORD_TYPE_WEEKLY_JOB  = rtInfosBatchJobSchedule.get('Weekly_Job').getRecordTypeId();
    public static final Id SCHEDULER_RECORD_TYPE_MONTHLY_JOB = rtInfosBatchJobSchedule.get('Monthly_Job').getRecordTypeId();
    public static final Id SCHEDULER_RECORD_TYPE_YEARLY_JOB  = rtInfosBatchJobSchedule.get('Yearly_Job').getRecordTypeId();
    public static final Id SCHEDULER_RECORD_TYPE_CUSTOM_CRON_EXPRESSION_JOB = rtInfosBatchJobSchedule.get('Custom_Cron_Expression_Job').getRecordTypeId();
    public static final Id SCHEDULER_RECORD_TYPE_EXISTING_SCHEDULED_JOB_JOB = rtInfosBatchJobSchedule.get('Existing_Scheduled_Job').getRecordTypeId();
    public static final Id JOB_RECORD_TYPE_BATCHABLE = rtInfosBatchJobApexJob.get('Batchable').getRecordTypeId();
    public static final Id JOB_RECORD_TYPE_QUEUEABLE = rtInfosBatchJobApexJob.get('Queueable').getRecordTypeId();
    

}