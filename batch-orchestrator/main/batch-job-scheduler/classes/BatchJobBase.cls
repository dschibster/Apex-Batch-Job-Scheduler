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
 *
 * @description       : Base Class responsible for Groupability and Batchability on a generic basis
 * @author            : ianhuang
 * @group             : Scheduler
 * @last modified on  : 2021-08-27
 * @last modified by  : dschibster
 **/

public virtual with sharing class BatchJobBase implements Finalizer {
    public Boolean executeNextJob = false;
    public BatchJobScheduler batchJobScheduler;
    public Id scheduleId;
    public Id jobId;
    public String jobType;
    public Boolean enhancedLoggingEnabled = false;
    public String className;
    public String asyncJobId;

    public static Boolean executeJobsInTestContext = true;

    public void startLogging(Id asyncApexJobId) {
        if (enhancedLoggingEnabled) {
            if (jobType == 'Queueable') {
                BatchJobLogger.writeQueueableParentLog(className, asyncApexJobId, scheduleId, jobId);
            } else {
                BatchJobLogger.logStart(className, asyncApexJobId, scheduleId, jobId);
            }
        }
    }

    public void logInformation(Id asyncApexJobId, String message) {
        if (enhancedLoggingEnabled) {
            BatchJobLogger.logExecuteInformation(asyncApexJobId, message);
        }
    }

    public void logInformation(List<SObject> scope, Id asyncApexJobId, String message) {
        if (enhancedLoggingEnabled) {
            BatchJobLogger.logExecuteInformation(scope, asyncApexJobId, message);
        }
    }

    public void logEndOfBatch(List<SObject> scope, Id asyncApexJobId, Boolean isSuccess, String message) {
        if (enhancedLoggingEnabled) {
            if (isSuccess) {
                logSuccessfulBatch(scope, asyncApexJobId, message);
            } else {
                logFailedBatch(scope, asyncApexJobId, message);
            }
        }
    }

    public void logFailedBatch(List<SObject> chunkScope, Id asyncApexJobId, String message) {
        BatchJobLogger.logExecute(chunkScope, asyncApexJobId, 'Error', message);
    }

    public void logSuccessfulBatch(List<SObject> chunkScope, Id asyncApexJobId, String message) {
        BatchJobLogger.logExecute(chunkScope, asyncApexJobId, 'Success', message);
    }

    public void logStartInformation(Id asyncApexJobId, String message) {
        if (enhancedLoggingEnabled) {
            BatchJobLogger.log(null, asyncApexJobId, 'Information', message, 'START');
        }
    }

    public void logFinishInformation(Id asyncApexJobId, String message) {
        if (enhancedLoggingEnabled) {
            BatchJobLogger.log(null, asyncApexJobId, 'Information', message, 'FINISH');
        }
    }

    public virtual void finishBatch(Id asyncApexJobId) {
        if (enhancedLoggingEnabled) {
            if (jobType == 'Batchable') {
                BatchJobLogger.logFinish(asyncApexJobId);
            } else {
                BatchJobLogger.updateParentQueueableLog(asyncApexJobId);
            }
        } else {
            BatchJobLogger.logLegacy(className, asyncApexJobId, scheduleId, jobId);
        }
        if (executeNextJob) {
            batchJobScheduler.ExecuteNextJob();
        }
    }

    public void execute(FinalizerContext ctx) {
        finishBatch(ctx.getAsyncApexJobId());
    }

    public Id enqueue(Integer batchSize) {
        if (!Test.isRunningTest() || executeJobsInTestContext) {
            switch on jobType {
                when 'Queueable' {
                    return System.enqueueJob((System.Queueable) this);
                }
                when 'Batchable' {
                    return Database.executeBatch((Database.Batchable<Object>) this, batchSize);
                }
            }
        }
        return null;
    }
}
