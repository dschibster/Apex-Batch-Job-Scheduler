public without sharing class BatchApexStatusEventHandler extends TriggerHandlerExtension {
    BatchApexStatusEventHelper helper;
    String lastReplayId;

    public BatchApexStatusEventHandler() {
        super();
        helper = new BatchApexStatusEventHelper(Trigger.new);
    }

    public override void bulkAfter() {
        helper.getApexJobs();
        helper.getParentLogs();
    }

    public override void afterInsert(SObject newSObject) {
        BatchApexStatusEvent__e evt = (BatchApexStatusEvent__e) newSObject;
        lstInsert.add(helper.createChildLogRecord(evt));
        lastReplayId = evt.ReplayId;
    }

    public override void andFinally() {
        lstUpdate.addAll(helper.parentLogsById.values());
        if (lastReplayId != null) {
            EventBus.TriggerContext.currentContext().setResumeCheckpoint(lastReplayId);
        }

        if (!lstInsert.isEmpty()) {
            insert lstInsert;
        }
        if (!lstUpdate.isEmpty()) {
            update lstUpdate;
        }
    }
}
