/**
 * This class is part of the sfdx-batch-orchestrator package, released under the MIT license.
 *
 * @description       : Logger Class to bundle creation of Log Events
 * @author            : dschibster
 * @group             : Scheduler
 * @last modified on  : 2021-08-27
 * @last modified by  : dschibster
 **/

public with sharing class BatchJobLogger {
    public static void log(List<SObject> chunkScope, Id asyncJobId, String status, String message, String context) {
        String scopeJSON = chunkScope != null ? JSON.serializePretty(chunkScope).left(129999) : '';
        BatchApexStatusEvent__e statusEvent = new BatchApexStatusEventBuilder()
            .withContext(context)
            .withStatus(status)
            .withMessage(message)
            .withScope(scopeJSON)
            .withTimestamp(DateTime.now().getTime())
            .withJobId(asyncJobId)
            .withLimits()
            .getRecord();

        EventBus.publish(statusEvent);
    }

    public static void logStart(String className, Id asyncJobId, Id scheduleId, Id jobId) {
        writeParentLog(className, asyncJobId, scheduleId, jobId);
        log(null, asyncJobId, 'Information', 'Batch Job started', 'START');
    }

    public static void logStartAfterParent(Id asyncJobId, String message) {
        log(null, asyncJobId, 'Information', message, 'START');
    }

    public static void logFinish(Id asyncJobId) {
        log(null, asyncJobId, 'Information', 'Batch Job finished', 'FINISH');
    }

    public static void logFinish(Id asyncJobId, String message) {
        log(null, asyncJobId, 'Information', message, 'FINISH');
    }

    public static void logExecute(List<SObject> chunkScope, Id asyncJobId, String status) {
        log(chunkScope, asyncJobId, status, null, 'EXECUTE');
    }

    public static void logExecuteInformation(Id asyncJobId, String message) {
        log(null, asyncJobId, 'Information', message, 'EXECUTE');
    }

    public static void logExecuteInformation(List<SObject> scope, Id asyncJobId, String message) {
        log(scope, asyncJobId, 'Information', message, 'EXECUTE');
    }

    public static void logExecute(List<SObject> chunkScope, Id asyncJobId, String status, String message) {
        log(chunkScope, asyncJobId, status, message, 'EXECUTE');
    }

    private static Batch_Job_Log__c getParentLog(String className, Id asyncJobId, Id scheduleId, Id jobId) {
        return new Batch_Job_Log__c(
            Batch_Job_Name__c = className,
            Batch_Apex_Job__c = jobId,
            Batch_Job_Schedule__c = scheduleId,
            BatchApexJobParent__c = jobId,
            BatchJobScheduleParent__c = scheduleId,
            AsyncApexJobId__c = asyncJobId,
            RecordTypeId = RecordTypeCache.LOG_RECORD_TYPE_PARENT,
            Result__c = 'Processing'
        );
    }

    public static void writeParentLog(String className, Id asyncJobId, Id scheduleId, Id jobId, Boolean isAsync) {
        Batch_Job_Log__c parentLog = getParentLog(className, asyncJobId, scheduleId, jobId);
        if (isAsync) {
            EventBus.publish(new BatchApexStatusEventBuilder().withSObjectJSON(JSON.serializePretty(parentLog)).getRecord());
        } else {
            insert parentLog;
        }
    }

    public static void writeParentLog(String className, Id asyncJobId, Id scheduleId, Id jobId) {
        writeParentLog(className, asyncJobId, scheduleId, jobId, false);
    }

    public static void writeQueueableParentLog(String className, Id asyncJobId, Id scheduleId, Id jobId) {
        Batch_Job_Log__c queueableLog = getParentLog(className, asyncJobId, scheduleId, jobId);
        queueableLog.RecordTypeId = RecordTypeCache.LOG_RECORD_TYPE_QUEUEABLE;
        EventBus.publish(new BatchApexStatusEventBuilder().withSObjectJSON(JSON.serializePretty(queueableLog)).getRecord());
    }

    public static void updateParentQueueableLog(Id asyncJobId) {
        AsyncApexJob job = [
            SELECT Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CompletedDate, CreatedBy.Email, ExtendedStatus
            FROM AsyncApexJob
            WHERE Id = :asyncJobId
        ];

        Datetime completedDate = job.CompletedDate;
        if (completedDate == null) {
            completedDate = Datetime.now();
        }

        BatchApexStatusEvent__e statusEvent = new BatchApexStatusEventBuilder()
            .withContext('FINISH')
            .withStatus(job.Status)
            .withMessage(job.ExtendedStatus)
            .withTimestamp(completedDate.getTime())
            .withJobId(asyncJobId)
            .getRecord();

        EventBus.publish(statusEvent);
    }

    /**
     * Copyright (c) Ian Huang Salesforce
     *
     * Permission is hereby granted, free of charge, to any person obtaining a copy
     * of this software and associated documentation files (the "Software"), to deal
     * in the Software without restriction, including without limitation the rights
     * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
     * copies of the Software, and to permit persons to whom the Software is
     * furnished to do so, subject to the following conditions:
     * The above copyright notice and this permission notice shall be included in all
     * copies or substantial portions of the Software.
     *
     * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
     * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
     * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
     * IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
     * DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
     * OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE
     * OR OTHER DEALINGS IN THE SOFTWARE.
     */

    public static void logLegacy(String batchJobName, Id asyncJobId, Id scheduleId, Id jobId) {
        logLegacy(batchJobName, asyncJobId, '', scheduleId, jobId);
    }

    //Log batch job exection result
    public static void logLegacy(String batchJobName, Id asyncJobId, String summary, Id scheduleId, Id jobId) {
        AsyncApexJob job = [
            SELECT Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CompletedDate, CreatedBy.Email, ExtendedStatus
            FROM AsyncApexJob
            WHERE Id = :asyncJobId
        ];

        String executeResult = job.ExtendedStatus;

        // Create a batch job log record to notify the batch job execute result
        try {
            Batch_Job_Log__c bjl = new Batch_Job_Log__c(
                Batch_Job_Name__c = batchJobName,
                Batch_Apex_Job__c = jobId,
                Batch_Job_Schedule__c = scheduleId,
                BatchApexJobParent__c = jobId,
                BatchJobScheduleParent__c = scheduleId,
                Completed_Date__c = job.CompletedDate,
                Result__c = job.Status,
                Batches_Processed__c = job.JobItemsProcessed,
                Number_of_Errors__c = job.NumberOfErrors,
                RecordTypeId = RecordTypeCache.LOG_RECORD_TYPE_LEGACY,
                Execution_Result__c = (String.isNotBlank(executeResult) ? executeResult : '') + (String.isNotBlank(summary) ? '\n' + summary : '')
            );
            insert bjl;
        } catch (Exception ex) {
            throw new DmlException('Failed to save batch job log: ' + ex.getMessage());
        }
    }
}
