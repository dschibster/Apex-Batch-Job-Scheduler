trigger BatchApexStatusEventTrigger on BatchApexStatusEvent__e(after insert) {
    new BatchApexStatusEventHandler().execute();
}
