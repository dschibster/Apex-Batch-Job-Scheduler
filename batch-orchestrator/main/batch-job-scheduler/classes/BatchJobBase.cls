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

public virtual with sharing class BatchJobBase implements Finalizer{
    public Boolean executeNextJob = false;
    public BatchJobScheduler batchJobScheduler;
    public Id scheduleId;
    public Id jobId;
    public String jobType;

    public virtual void finishBatch(Id asyncJobId) {
        String className = String.valueOf(this).split(':')[0];
        BatchJobHelper.logBatchJob(className, asyncJobId, scheduleId, jobId);
        
        if (executeNextJob) {
            batchJobScheduler.ExecuteNextJob();
        }
    }

    public void execute(FinalizerContext ctx){
        finishBatch(ctx.getAsyncApexJobId());
    }

    public void enqueue(Integer batchSize) {
        switch on jobType {
            when 'Queueable' {
                System.enqueueJob((System.Queueable) this);
            }
            when 'Batchable' {
                Database.executeBatch((Database.Batchable<Object>) this, batchSize);
            }
        }
    }
}