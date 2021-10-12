trigger BatchApexStatusEventTrigger on BatchApexStatusEvent__e(after insert) {
    TriggerFactory.executeTriggerHandlers(BatchApexStatusEvent__e.SObjectType);
}
