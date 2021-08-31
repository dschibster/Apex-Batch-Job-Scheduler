public with sharing class BatchApexJobHandler extends TriggerHandlerExtension {
    public BatchApexJobHelper helper = BatchApexJobHelper.getInstance();

    public BatchApexJobHandler() {
        super();
    }

    public override void beforeInsert(SObject so) {
        Batch_Apex_Job__c apexJob = (Batch_Apex_Job__c) so;
        helper.verifyBatchJob(apexJob);
    }

    public override void beforeUpdate(SObject oldSO, SObject newSO) {
        Batch_Apex_Job__c apexJobNew = (Batch_Apex_Job__c) newSO;
        Batch_Apex_Job__c apexJobOld = (Batch_Apex_Job__c) oldSO;
        if (apexJobNew.Batch_Class_Name__c != apexJobOld.Batch_Class_Name__c) {
            helper.verifyBatchJob(apexJobNew);
        }
    }
}
