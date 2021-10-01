public with sharing class BatchApexStatusEventHelper {
    List<BatchApexStatusEvent__e> triggerNew;
    ListMapContainer mapParentLogIdToStatusEvent = new ListMapContainer(BatchApexStatusEvent__e.SObjectType);

    public BatchApexStatusEventHelper(List<BatchApexStatusEvent__e> triggerNew) {
        this.triggerNew = triggerNew;
    }
}
