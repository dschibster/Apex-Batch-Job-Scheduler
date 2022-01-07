/**
 * This class is part of the sfdx-batch-orchestrator package, released under the MIT license.
 *
 * @description       : Trigger Factory Handler for Batch_Job_Schedule__c
 * @author            : dschibster
 * @group             : Scheduler
 * @last modified on  : 2021-08-27
 * @last modified by  : dschibster
 **/

public without sharing class BatchJobScheduleHandler extends BatchOrchTriggerExecutor {
    public static BatchJobScheduleHelper helper = BatchJobScheduleHelper.getInstance();

    public override void bulkBefore() {
        if (Trigger.isInsert || Trigger.isUpdate) {
            //Adjusts the CRON Expression to its new term after an update
            helper.arrangeCronExpressions(Trigger.new);
            //Removes Cron Trigger Ids for Cron Triggers that don't exist anymore
            helper.validateCronTriggers(Trigger.new);
        }
    }

    public override void beforeDelete(SObject oldObj) {
        Batch_Job_Schedule__c oldSchedule = (Batch_Job_Schedule__c) oldObj;
        helper.preventDeletionWithActiveCronTrigger(oldSchedule);
    }
}
