public with sharing class BatchApexErrorEventHandler extends TriggerHandlerExtension {
    BatchApexErrorEventHelper helper;
    String lastReplayId;

    public BatchApexErrorEventHandler() {
        super();
        helper = new BatchApexErrorEventHelper((List<BatchApexErrorEvent>) Trigger.new);
    }

    public override void bulkAfter() {
        helper.getApexJobs();
    }

    public override void afterInsert(SObject newSObject) {
        BatchApexErrorEvent evt = (BatchApexErrorEvent) newSObject;
        lstInsert.add(helper.createStatusEvent(evt));
        lastReplayId = evt.ReplayId;
    }

    public override void andFinally() {
        if (!lstInsert.isEmpty()) {
            EventBus.publish(lstInsert);
        }
        if (lastReplayId != null) {
            Eventbus.TriggerContext.currentContext().setResumeCheckpoint(lastReplayId);
        }
    }
}
