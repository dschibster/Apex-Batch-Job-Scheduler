public with sharing class BatchApexStatusEventHelper {
    List<BatchApexStatusEvent__e> triggerNew;
    Map<Id, AsyncApexJob> relevantApexJobs = new Map<Id, AsyncApexJob>();
    Map<Id, Batch_Job_Log__c> parentLogsByAsyncJobId = new Map<Id, Batch_Job_Log__c>();
    public Map<Id, Batch_Job_Log__c> parentLogsById = new Map<Id, Batch_Job_Log__c>();
    Set<Id> setFinishedParentLogs = new Set<Id>();

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
                SELECT Id, Status, ExtendedStatus, TotalJobItems, JobItemsProcessed, NumberOfErrors, CreatedDate, CompletedDate
                FROM AsyncApexJob
                WHERE Id IN :relevantAsyncApexJobIds
            ]
        );
    }

    public void getParentLogs() {
        parentLogsById = new Map<Id, Batch_Job_Log__c>(
            [
                SELECT Id, Batch_Apex_Job__c, Batch_Job_Schedule__c, AsyncApexJobId__c, FailedBatches__c, SuccessfulBatches__c
                FROM Batch_Job_Log__c
                WHERE RecordTypeId = :RecordTypeCache.LOG_RECORD_TYPE_PARENT AND AsyncApexJobId__c IN :relevantApexJobs.keySet()
            ]
        );
        for (Batch_Job_Log__c log : parentLogsById.values()) {
            parentLogsByAsyncJobId.put(log.AsyncApexJobId__c, log);
        }
    }

    public Batch_Job_Log__c createChildLogRecord(BatchApexStatusEvent__e statusEvent) {
        Batch_Job_Log__c parentLog = parentLogsByAsyncJobId.get(statusEvent.AsyncApexJobId__c);
        Batch_Job_Log__c childLog = createChildLogFromEvent(statusEvent);
        childLog.Parent_Log__c = parentLog.Id;

        handleUpdatesForParentLogs(childLog);

        return childLog;
    }

    private Batch_Job_Log__c createChildLogFromEvent(BatchApexStatusEvent__e evt) {
        Batch_Job_Log__c childLog = new Batch_Job_Log__c(
            RecordTypeId = RecordTypeCache.LOG_RECORD_TYPE_CHILD,
            AsyncApexCallsLimit__c = evt.AsyncApexCallsLimit__c,
            AsyncApexCallsUsed__c = evt.AsyncApexCallsUsed__c,
            CPUTimeUsed__c = evt.CPUTimeUsed__c,
            CPUTimeLimit__c = evt.CPUTimeLimit__c,
            DMLRowsLimit__c = evt.DMLRowsLimit__c,
            DMLRowsUsed__c = evt.DMLRowsUsed__c,
            DMLStatementsLimit__c = evt.DMLStatementsLimit__c,
            DMLStatementsUsed__c = evt.DMLStatementsUsed__c,
            SOQLQueriesLimit__c = evt.SOQLQueriesLimit__c,
            SOQLQueriesUsed__c = evt.SOQLQueriesUsed__c,
            SOQLRowsLimit__c = evt.SOQLRowsLimit__c,
            SOQLRowsUsed__c = evt.SOQLRowsUsed__c,
            Context__c = evt.Context__c,
            Scope__c = evt.Scope__c,
            Execution_Result__c = evt.Message__c,
            Result__c = evt.Status__c,
            Timestamp__c = evt.Timestamp__c,
            ClassName__c = evt.ClassName__c,
            AsyncApexJobId__c = evt.AsyncApexJobId__c
        );
        return childLog;
    }

    private void handleUpdatesForParentLogs(Batch_Job_Log__c childLog) {
        Batch_Job_Log__c parentLog = parentLogsById.get(childLog.Parent_Log__c);
        switch on childLog.Result__c {
            when 'Error' {
                parentLog.FailedBatches__c += 1;
            }
            when 'Success' {
                parentLog.SuccessfulBatches__c += 1;
            }
        }

        if (childLog.Context__c == 'Finish') {
            String status;
            Boolean noBatches = parentLog.FailedBatches__c == 0 && parentLog.SuccessfulBatches__c == 0;
            Boolean hasSuccessfulBatches = parentLog.SuccessfulBatches__c > 0;
            Boolean hasFailedBatches = parentLog.FailedBatches__c > 0;
            if (noBatches || (hasSuccessfulBatches && !hasFailedBatches)) {
                status = 'Completed';
            }
            if (hasSuccessfulBatches && hasFailedBatches) {
                status = 'Completed with Errors';
            }
            if (hasFailedBatches && !hasSuccessfulBatches) {
                status = 'Failed';
            }
            parentLog.Completed_Date__c = DateTime.valueOf(childLog.Timestamp__c);
            parentLog.Result__c = status;
        }

        parentLogsById.put(parentLog.Id, parentLog);
    }
}
