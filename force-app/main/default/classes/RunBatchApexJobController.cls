public with sharing class RunBatchApexJobController {
    BatchJobBase batchJobToRun;
    Batch_Apex_Job__c jobRecord;

    public RunBatchApexJobController(ApexPages.StandardController stdCtrl) {
        if(!Test.isRunningTest()){
             stdCtrl.addFields(new List<String>{'Batch_Class_Name__c','Batch_Job_Schedule__c', 'Batch_Size__c','RecordType.DeveloperName'});
        }
        Batch_Apex_Job__c batchApexJob = (Batch_Apex_Job__c) stdCtrl.getRecord();

        batchJobToRun = (BatchJobBase) Type.forName(batchApexJob.Batch_Class_Name__c).newInstance();
        batchJobToRun.jobType = batchApexJob.RecordType.DeveloperName;
        batchJobToRun.executeNextJob = false;
        batchJobToRun.jobId = batchApexJob.Id;
        batchJobToRun.scheduleId = batchApexJob.Batch_Job_Schedule__c;
    
        jobRecord = batchApexJob;
    }

    public PageReference runJob(){
        batchJobToRun.enqueue(Integer.valueOf(jobRecord.Batch_Size__c));
        PageReference ref = new PageReference('/'+jobRecord.Batch_Job_Schedule__c);
        ref.setRedirect(true);
        return ref;
    }
}
