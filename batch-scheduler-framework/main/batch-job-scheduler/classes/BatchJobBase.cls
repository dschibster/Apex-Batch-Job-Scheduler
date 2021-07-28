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