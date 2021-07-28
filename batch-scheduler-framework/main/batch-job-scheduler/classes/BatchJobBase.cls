global virtual with sharing class BatchJobBase implements Finalizer{
    global Boolean executeNextJob = false;
    global BatchJobScheduler batchJobScheduler;
    global Id scheduleId;
    global Id jobId;
    global String jobType;

    global virtual void finishBatch(Id asyncJobId) {
        String className = String.valueOf(this).split(':')[0];
        BatchJobHelper.logBatchJob(className, asyncJobId, scheduleId, jobId);
        
        if (executeNextJob) {
            batchJobScheduler.ExecuteNextJob();
        }
    }

    public void execute(FinalizerContext ctx){
        finishBatch(ctx.getAsyncApexJobId());
    }

    global void enqueue(Integer batchSize) {
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