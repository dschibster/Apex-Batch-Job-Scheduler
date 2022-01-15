/**
 * This class is part of the sfdx-batch-orchestrator package, released under the MIT license.
 *
 * @description       : Test Class that verifies a Queueable Job runs when fired via BatchJobScheduler
 * @author            : dschibster
 * @group             : Batch Job Management
 * @last modified on  : 2021-08-27
 * @last modified by  : dschibster
 **/

public with sharing class TestQueueable extends BatchJobBase implements Queueable {
    public testqueueable() {
    }

    public void execute(QueueableContext QC) {
        System.attachFinalizer(this);
        super.startLogging(QC?.getJobId());

        super.logInformation(QC?.getJobId(), 'Testing Queueable Logging');
    }
}
