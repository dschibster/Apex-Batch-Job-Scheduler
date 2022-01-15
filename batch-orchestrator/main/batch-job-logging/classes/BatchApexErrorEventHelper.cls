/**
 * This class is part of the sfdx-batch-orchestrator package, released under the MIT license.
 *
 * @description       :
 * @author            : Dennis Grzyb
 * @group             : Scheduler
 * @last modified on  : 2021-10-12
 * @last modified by  : Dennis Grzyb
 **/
public with sharing class BatchApexErrorEventHelper {
    List<BatchApexErrorEvent> triggerNew;
    Map<Id, AsyncApexJob> relevantApexJobs = new Map<Id, AsyncApexJob>();
    Map<Id, Batch_Job_Log__c> parentLogsByAsyncJobId = new Map<Id, Batch_Job_Log__c>();
    public Map<Id, Batch_Job_Log__c> parentLogsById = new Map<Id, Batch_Job_Log__c>();
    Map<Id, Id> childJobIdToParentId = new Map<Id, Id>();

    public BatchApexErrorEventHelper(List<BatchApexErrorEvent> triggerNew) {
        this.triggerNew = triggerNew;
    }

    public void getApexJobs() {
        Set<String> relevantAsyncApexJobIds = new Set<String>();
        for (BatchApexErrorEvent evt : triggerNew) {
            Id asyncApexJobId18digit = (Id) evt.AsyncApexJobId;
            relevantAsyncApexJobIds.add(asyncApexJobId18digit);
        }

        relevantApexJobs = new Map<Id, AsyncApexJob>(
            [
                SELECT Id, Status, ApexClass.Name, ParentJobId, ExtendedStatus, TotalJobItems, JobItemsProcessed, NumberOfErrors, CreatedDate, CompletedDate
                FROM AsyncApexJob
                WHERE Id IN :relevantAsyncApexJobIds
            ]
        );

        for (AsyncApexJob apxj : relevantApexJobs.values()) {
            childJobIdToParentId.put(apxj.Id, apxj.ParentJobId);
        }
    }

    public BatchApexStatusEvent__e createStatusEvent(BatchApexErrorEvent evt) {
        Id asyncApexJobId18 = (Id) evt.AsyncApexJobId;
        BatchApexStatusEvent__e statusEvent = new BatchApexStatusEventBuilder()
            .withContext(evt.Phase)
            .withStatus('Error')
            .withMessage(evt.ExceptionType + '\n' + evt.Message + '\n' + evt.StackTrace)
            .withTimestamp(evt.CreatedDate.getTime())
            .withJobId(childJobIdToParentId.get(asyncApexJobId18))
            .withScope(evt.JobScope)
            .getRecord();
        return statusEvent;
    }
}
