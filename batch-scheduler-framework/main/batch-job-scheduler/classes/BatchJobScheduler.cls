global with sharing class BatchJobScheduler implements Schedulable {
    //Batch jobs in parallel run batches
    public ListMapContainer batchJobs;
    @TestVisible private Map<Integer,Boolean> isEnabledMap;
    @TestVisible private Integer index;

    global void execute(SchedulableContext sc) {
        run(sc.getTriggerId());
    }

    //Execute jobs from the beginning
    public void run(Id cronTriggerId) {
        batchJobs = loadActiveBatchJobs(cronTriggerId);
        executeJobs();
    }

    public void executeJobs(){
        if (batchJobs.getMap().keySet().isEmpty()) {
            return;
        }

        index = 1;
        List<Batch_Apex_Job__c> firstBatchGroup = getNextBatchJobs();
        if(!firstBatchGroup.isEmpty()){
            enqueueBatchJobs(batchJobs.get(String.valueOf(index)));
        }
    }

    //Execute jobs in next batch
    public void executeNextJob() {
        if (!hasPendingJobs(index)) {
            index++;
            List<Batch_Apex_Job__c> nextJobs = getNextBatchJobs();
            if(!nextJobs.isEmpty()){
                enqueueBatchJobs(nextJobs);
            }
        }
    }

    private List<Batch_Apex_Job__c> getNextBatchJobs(){
        List<Batch_Apex_Job__c> result = new List<Batch_Apex_Job__c>();
        index = getNextIndexWithEnabledJobs();
        if(index != null){
            result = batchJobs.get(String.valueOf(index));
        }
        return result;
    }

    public ListMapContainer loadActiveBatchJobs(Id cronTriggerId) {
        Batch_Job_Schedule__c schedule = [SELECT Id FROM Batch_Job_Schedule__c WHERE Cron_Trigger_Id__c = :cronTriggerId];
        return loadActiveBatchJobsById(schedule.Id);
    }
    //load active batch jobs from Batch_Apex_Job__c, sort by Batch No and Batch Sequence
    public ListMapContainer loadActiveBatchJobsById(Id scheduleId) {
        ListMapContainer batchJobListMap = new ListMapContainer(Batch_Apex_Job__c.SObjectType);
        isEnabledMap = new Map<Integer, Boolean>();

        for (Batch_Apex_Job__c baj : [
            SELECT
                Id,
                Name,
                Enabled__c,
                Batch_Class_Name__c,
                Batch_Size__c,
                Batch_Group__c,
                Batch_Job_Schedule__c,
                RecordType.DeveloperName
            FROM Batch_Apex_Job__c
            WHERE Batch_Job_Schedule__c = :scheduleId
            ORDER BY Batch_Group__c, CreatedDate
        ]) {
            if(!isEnabledMap.containsKey(Integer.valueOf(baj.Batch_Group__c))){
                isEnabledMap.put(Integer.valueOf(baj.Batch_Group__c), false);
            }
            if(baj.Enabled__c){
                batchJobListMap.addToMap(String.valueOf(baj.Batch_Group__c), baj);
                isEnabledMap.put(Integer.valueOf(baj.Batch_Group__c), true);
            }
        }
    
        return batchJobListMap;
    }

    private void enqueueBatchJobs(List<Batch_Apex_Job__c> apexJobs) {
        for (Batch_Apex_Job__c baj : apexJobs) {
            Id scheduleId = baj.Batch_JOb_Schedule__c;
            Id jobId = baj.Id;
            BatchJobBase job = getBatchJob(baj.Batch_Class_Name__c, baj.RecordType.DeveloperName);
            if (job != null && !Test.isRunningTest()) {
                job.batchJobScheduler = this;
                job.scheduleId = scheduleId;
                job.jobId = jobId;
                job.enqueue((Integer) baj.Batch_Size__c);
            }
        }
    }

    private Boolean hasPendingJobs(Integer checkedIndex) {
        Set<String> batchJobNames = new Set<String>();
        for (Batch_Apex_Job__c job : (List<Batch_Apex_Job__c>) batchJobs.get(String.valueOf(checkedIndex))) {
            batchJobNames.add(job.Batch_Class_Name__c);
        }

        List<AsyncApexJob> apexJobs = [
            SELECT Id, JobType, ApexClassId, Status, ApexClass.Name
            FROM AsyncApexJob
            WHERE
                JobType IN ('BatchApex', 'Queueable')
                AND Status IN ('Holding', 'Processing', 'Queued', 'Preparing')
                AND ApexClass.Name IN :batchJobNames
        ];
        //if any jobs are still running from the same batch
        return !apexJobs.isEmpty();
    }

    //Get batch job instance by batch job name
    private BatchJobBase getBatchJob(String jobName, String jobType) {
        BatchJobBase result = null;

        Type t = Type.forName(jobName);
        if (t != null) {
            result = (BatchJobBase) t.newInstance();
        } else {
            throw new TypeException('Cannot find batch job: ' + jobName);
        }
        //set ExecuteNextJob to true so it executes the next job when it finishes
        result.executeNextJob = true;
        result.jobType = jobType;
        return result;
    }

    private Integer getNextIndexWithEnabledJobs(){
        while(isEnabledMap.containsKey(index)){
            if(isEnabledMap.get(index)){
                return index;
            }
            index++;
        }
        return null;
    }
}