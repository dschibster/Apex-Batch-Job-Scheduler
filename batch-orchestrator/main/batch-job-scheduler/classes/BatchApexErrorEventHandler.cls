/**
 * This class is part of the sfdx-batch-orchestrator package, released under the MIT license.
 *
 * @description       : Handler Class for Trigger on BatchApexErrorEvent
 * @author            : Dennis Grzyb
 * @group             : Scheduler
 * @last modified on  : 2021-10-12
 * @last modified by  : Dennis Grzyb
 **/
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
