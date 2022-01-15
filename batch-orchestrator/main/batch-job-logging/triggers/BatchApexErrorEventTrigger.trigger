trigger BatchApexErrorEventTrigger on BatchApexErrorEvent(after insert) {
    new BatchApexErrorEventHandler().execute();
}
