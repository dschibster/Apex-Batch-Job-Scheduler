/**
 * This class is part of the sfdx-batch-orchestrator package, released under the MIT license.
 *
 * @description       : Trigger Handler for Batch Apex Job
 * @author            : Dennis Grzyb
 * @group             : Scheduler
 * @last modified on  : 2021-10-12
 * @last modified by  : Dennis Grzyb
 **/

public with sharing class BatchApexJobHandler extends BatchOrchTriggerExecutor {
    public BatchApexJobHelper helper = BatchApexJobHelper.getInstance();

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
