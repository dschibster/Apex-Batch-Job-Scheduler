public with sharing class SchedulerConfigurationController {
    public static final String CRONTIGGER_JOBTYPE_SCHEDULED_APEX = '7';

    public List<ScheduledApexJob> scheduledApexJobs { get; set; }

    private List<Batch_Job_Schedule__c> batchJobSchedules;

    //Constructor
    public SchedulerConfigurationController() {
        List<ScheduledApexJob> scheduledApexJobs = new List<ScheduledApexJob>();
        retrieveBatchJobSchedules();
    }

    public PageReference save() {
        PageReference pageRef = ApexPages.currentPage();

        updateBatchJobSchedules();
        pageRef.setRedirect(true);
        
        return pageRef;
    }

    private void updateBatchJobSchedules() {
        BatchJobScheduler scheduler;

        //System.debug('*** batchJobSchedules = ' + batchJobSchedules);

        //update Schedulers
        for (ScheduledApexJob job : scheduledApexJobs) {
            if (job.scheduled) {
                if (job.cronTrigger == null) {
                    job.Schedule.Cron_Trigger_Id__c = scheduleJob(job);
                }
            } else {
                if (job.cronTrigger != null) {
                    job.Schedule.Cron_Trigger_Id__c = null;
                    System.abortJob(job.cronTrigger.Id);
                }
            }
        }

        //update Batch_Job_Scheduler__c records
        Database.SaveResult[] saveResults = Database.update(batchJobSchedules, false);
        for (Database.SaveResult sr : saveResults) {
            if (!sr.isSuccess()) {
                // Operation failed, so get all errors
                for (Database.Error err : sr.getErrors()) {
                    ApexPages.addMessage(
                        new ApexPages.Message(ApexPages.severity.ERROR, 'DML Error: ' + err.getMessage())
                    );
                    System.debug('The following error has occurred.');
                    System.debug(err.getStatusCode() + ': ' + err.getMessage());
                }
            }
        }
    }

    private Id scheduleJob(ScheduledApexJob job) {
        Id result = null;

        if (job.schedule.Cron_Expression__c != null) {
            result = System.schedule(job.schedule.Name, job.schedule.Cron_Expression__c, new BatchJobScheduler());
        }
        return result;
    }

    private Map<Id, CronTrigger> retrieveCronTriggerMap() {
        
        Map<Id, CronTrigger> result = new Map<Id, CronTrigger>(
            [
                SELECT
                    Id,
                    CronExpression,
                    CronJobDetailId,
                    NextFireTime,
                    PreviousFireTime,
                    StartTime,
                    EndTime,
                    State,
                    TimesTriggered,
                    CronJobDetail.Name
                FROM CronTrigger
                WHERE CronJobDetail.JobType = :CRONTIGGER_JOBTYPE_SCHEDULED_APEX
            ]
        );
        return result;
    }

    private void retrieveBatchJobSchedules() {
        scheduledApexJobs = new List<ScheduledApexJob>();

        //exit if cannot edit batchJobSchedule
        if (!canUpdateSchedule()) {
            return;
        }

        Map<Id, CronTrigger> cronTriggerMap = retrieveCronTriggerMap();

        batchJobSchedules = [
            SELECT Id, Name, Cron_Trigger_Id__c, Cron_Expression__c, RecordType.Name
            FROM Batch_Job_Schedule__c
            ORDER BY CreatedDate, Name
            LIMIT 2000
        ];

        for (Batch_Job_Schedule__c sch : batchJobSchedules) {
            if (sch.Cron_Trigger_Id__c != null && cronTriggerMap.containsKey(sch.Cron_Trigger_Id__c)) {
                scheduledApexJobs.add(new ScheduledApexJob(sch, cronTriggerMap.get(sch.Cron_Trigger_Id__c)));
            } else {
                scheduledApexJobs.add(new ScheduledApexJob(sch, null));
            }
        }
    }

    private Boolean canUpdateSchedule() {
        String[] batchJobScheduleUpdateFields = new List<String>{
            'Name',
            'Cron_Trigger_Id__c',
            'Cron_Expression__c',
            'RecordTypeId'
        };

        // Obtaining the field name/token map for the Batch_Job_Schedule__c object
        Map<String, Schema.SObjectField> fieldMap = Schema.SObjectType.Batch_Job_Schedule__c.fields.getMap();
        //System.debug('@@@fieldMap = ' + fieldMap);
        for (String fieldToCheck : batchJobScheduleUpdateFields) {
            // Check if the user has read access on the each field
            if (!fieldMap.get(fieldToCheck).getDescribe().isUpdateable()) {
                //System.debug('@@@fieldToCheck = ' + fieldToCheck);
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, 'Insufficient access'));
                return false;
            }
        }
        return true;
    }

    public class ScheduledApexJob{
        public Boolean                Scheduled    {get; set;}
        public Batch_Job_Schedule__c  Schedule     {get; private set;}
        public CronTrigger            CronTrigger  {get; private set;}
        
        public ScheduledApexJob(Batch_Job_Schedule__c schedule, CronTrigger cronTrigger) {
            this.schedule    = schedule;
            this.cronTrigger = cronTrigger;
            this.scheduled   = cronTrigger != null;
        }
    }
}