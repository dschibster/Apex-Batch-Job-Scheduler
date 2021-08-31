public with sharing class BatchApexJobHelper {
    public static BatchApexJobHelper instance;

    public static BatchApexJobHelper getInstance() {
        if (instance == null) {
            instance = new BatchApexJobHelper();
        }
        return instance;
    }

    public BatchApexJobHelper() {
    }

    public void verifyBatchJob(Batch_Apex_Job__c apexJob) {
        String batchJobName = apexJob.Batch_Class_Name__c;
        try {
            BatchJobBase apexJobTypeCast = (BatchJobBase) Type.forName(batchJobName).newInstance();
        } catch (Exception e) {
            String errorMessage = 'Unable to create BatchJobBase instance from Batch Job {0}. Please make sure to type the correct name and ensure that it extends BatchJobBase.';
            apexJob.addError(String.format(errorMessage, new List<String>{ batchJobName }));
        }
    }
}
