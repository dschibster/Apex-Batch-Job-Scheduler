public without sharing class BatchJobScheduleHandler extends TriggerHandlerExtension {
    public static BatchJobScheduleHelper helper = BatchJobScheduleHelper.getInstance();

    public BatchJobScheduleHandler() {
        super();
    }

    public override void bulkBefore() {
        if (Trigger.isInsert || Trigger.isUpdate) {
            //Adjusts the CRON Expression to its new term after an update
            helper.arrangeCronExpressions(Trigger.new);
            //Removes Cron Trigger Ids for Cron Triggers that don't exist anymore
            helper.validateCronTriggers(Trigger.new);
        }
    }
}