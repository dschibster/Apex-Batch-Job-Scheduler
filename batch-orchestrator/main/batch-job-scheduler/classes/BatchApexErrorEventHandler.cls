public with sharing class BatchApexErrorEventHandler extends TriggerHandlerExtension {
    BatchApexErrorEventHelper helper;

    public BatchApexErrorEventHandler() {
        super();
        helper = new BatchApexErrorEventHelper((List<BatchApexErrorEvent>) Trigger.new);
    }

    public override void bulkAfter() {
        helper.getApexJobs();
        helper.getParentLogs();
    }

    public override void afterInsert(SObject newSObject) {
        lstInsert.add(helper.createChildLogRecord((BatchApexErrorEvent) newSObject));
    }

    public override void andFinally() {
        lstUpdate.addAll(helper.parentLogsById.values());
        if (!lstUpdate.isEmpty()) {
            update lstUpdate;
        }
        if (!lstInsert.isEmpty()) {
            insert lstInsert;
        }
    }
}
