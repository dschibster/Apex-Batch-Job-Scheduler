/**
 * This class is part of the sfdx-batch-orchestrator package, released under the MIT license.
 *
 * @description       : Helper Class for Trigger Handler on Batch Apex Status Event
 * @author            : Dennis Grzyb
 * @group             : Scheduler
 * @last modified on  : 2021-10-12
 * @last modified by  : Dennis Grzyb
 **/

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
                SELECT Id, Batch_Apex_Job__c, Batch_Job_Schedule__c, AsyncApexJobId__c, FailedBatches__c, SuccessfulBatches__c, RecordTypeId
                FROM Batch_Job_Log__c
                WHERE
                    (RecordTypeId = :RecordTypeCache.LOG_RECORD_TYPE_PARENT
                    OR RecordTypeId = :RecordTypeCache.LOG_RECORD_TYPE_QUEUEABLE)
                    AND AsyncApexJobId__c IN :relevantApexJobs.keySet()
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

    public Batch_Job_Log__c extractRecordFromJSON(BatchApexStatusEvent__e statusEvent) {
        Batch_Job_Log__c extractedLog = (Batch_Job_Log__c) JSON.deserialize(statusEvent.SObjectJSON__c, Batch_Job_Log__c.class);
        return extractedLog;
    }

    public void createParentLogsFromSObjectJSON() {
        List<Batch_Job_Log__c> parentLogs = new List<Batch_Job_Log__c>();
        for (BatchApexStatusEvent__e evt : triggerNew) {
            if (evt.SObjectJSON__c != null) {
                parentLogs.add(extractRecordFromJSON(evt));
            }
        }
        if (!parentLogs.isEmpty()) {
            insert parentLogs;
            for (Batch_Job_Log__c insertedParentLog : parentLogs) {
                parentLogsByAsyncJobId.put(insertedParentLog.AsyncApexJobId__c, insertedParentLog);
                parentLogsById.put(insertedParentLog.Id, insertedParentLog);
            }
        }
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
        if (parentLogsById.containsKey(childLog.Parent_Log__c)) {
            Batch_Job_Log__c parentLog = parentLogsById.get(childLog.Parent_Log__c);
            AsyncApexJob apexJob = relevantApexJobs.get(childLog.AsyncApexJobId__c);

            //Increase failed and successful Batches for each Successful Execute Log
            if (childLog.Context__c == 'EXECUTE') {
                switch on childLog.Result__c {
                    when 'Error' {
                        parentLog.FailedBatches__c += 1;
                    }
                    when 'Success' {
                        parentLog.SuccessfulBatches__c += 1;
                    }
                }
            }

            //Queueable Logs finish with their finish Event, while we want to set results on the batch job log after all events have been evaluated
            //We can however still put the Completed Date on the Parent Log after the finish() Log has been processed.
            if (childLog.Context__c == 'FINISH') {
                if (parentLog.RecordTypeId == RecordTypeCache.LOG_RECORD_TYPE_QUEUEABLE) {
                    parentLog.Result__c = childLog.Result__c;
                }
                parentLog.Completed_Date__c = DateTime.valueOf((Long) childLog.Timestamp__c);
            } else if (apexJob?.TotalJobItems == (parentLog.FailedBatches__c + parentLog.SuccessfulBatches__c)) {
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
                parentLog.Result__c = status;
            }

            parentLogsById.put(parentLog.Id, parentLog);
        }
    }
}
