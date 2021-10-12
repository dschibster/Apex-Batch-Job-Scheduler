trigger BatchApexErrorEventTrigger on BatchApexErrorEvent(after insert) {
    TriggerFactory.executeTriggerHandlers(BatchApexErrorEvent.SObjectType);
}
