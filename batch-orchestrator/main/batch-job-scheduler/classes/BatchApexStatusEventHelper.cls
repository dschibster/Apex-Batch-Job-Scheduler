public with sharing class BatchApexStatusEventHelper {
    List<BatchApexStatusEvent__e> triggerNew;
    ListMapContainer mapParentLogIdToStatusEvent = new ListMapContainer(BatchApexStatusEvent__e.SObjectType);
    Map<Id, AsyncApexJob> relevantApexJobs = new Map<Id, AsyncApexJob>();
    Map<Id, Batch_Job_Log__c> parentLogs = new Map<Id, Batch_Job_Log__c>();

    public BatchApexStatusEventHelper(List<BatchApexStatusEvent__e> triggerNew) {
        this.triggerNew = triggerNew;
    }

    public void getApexJobs() {
        Set<Id> relevantAsyncApexJobIds = new Set<Id>();
        for (BatchApexStatusEvent__e evt : triggerNew) {
            relevantAsyncApexJobIds.add(evt.AsyncApexJobId__c);
        }

        relevantApexJobs = new Map<Id, AsyncApexJob>(
            [
                SELECT Id, Id, Status, ExtendedStatus, TotalJobItems, JobItemsProcessed, NumberOfErrors, CreatedDate, CompletedDate
                FROM AsyncApexJob
                WHERE Id IN :relevantAsyncApexJobIds
            ]
        );
    }

    public void getParentLogs() {
        List<Batch_Job_Log__c> parentLogs = [
            SELECT Id, Batch_Apex_Job__c, Batch_Job_Schedule__c
            FROM Batch_Job_Log__c
            WHERE RecordTypeId = :RecordTypeCache.LOG_RECORD_TYPE_PARENT AND AsyncApexJobId__c IN :relevantApexJobs.keySet()
        ];
    }

    public void createChildLogRecords() {
    }
}
