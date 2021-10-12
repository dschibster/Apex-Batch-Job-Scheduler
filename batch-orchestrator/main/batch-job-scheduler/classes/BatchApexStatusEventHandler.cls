/**
 * This class is part of the sfdx-batch-orchestrator package, released under the MIT license.
 *
 * @description       : Flow Control for the Trigger on Batch Apex Status Event
 * @author            : Dennis Grzyb
 * @group             : Scheduler
 * @last modified on  : 2021-10-12
 * @last modified by  : Dennis Grzyb
 **/

public without sharing class BatchApexStatusEventHandler extends TriggerHandlerExtension {
    BatchApexStatusEventHelper helper;
    String lastReplayId;

    public BatchApexStatusEventHandler() {
        super();
        helper = new BatchApexStatusEventHelper(Trigger.new);
    }

    public override void bulkAfter() {
        helper.createParentLogsFromSObjectJSON();
        helper.getApexJobs();
        helper.getParentLogs();
    }

    public override void afterInsert(SObject newSObject) {
        BatchApexStatusEvent__e evt = (BatchApexStatusEvent__e) newSObject;
        if (evt.SObjectJSON__c == null) {
            lstInsert.add(helper.createChildLogRecord(evt));
        }
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
