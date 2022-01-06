# Logging

There are two ways that the Batch Orchestrator produces logs. One of them is the standard (read: legacy) way of creating logs, and one of them uses Platform Events for enhanced logs.

## Standard logging
The only thing that is being logged is the status of the `AsyncApexJob` record that was created for your Job. It contains the first error it encounters (shortened) and a few other things, but otherwise does not look spectacular. If you want to keep it that way (or feel like you do not want to refactor old jobs), simply keep everything as is.

The logs get created in `super.finishBatch()` when `EnhancedLogging__c` is set to **false** for the `Batch_Apex_Job__c` record. As this is already necessary for the framework to run, there is no additional effort involved.

## Enhanced logging
Enhanced Logging leverages Platform Events to create hierarchical logs. This means that under one Parent Log, you will find several different child logs, ideally one for each of the batches that have run (including, optionally, a few information logs).

In order to leverage enhanced Logging, here is what you need to do:

* Ensure that your Job raises platform events: [As seen here](code.md#additionally-when-using-enhanced-logging)
* Set the **Enhanced Logging** Flag on the `Batch_Apex_Job__c` record for your Batch Job to **true**.
* Use `startLogging()` and the different `log` methods detailed below.

``` java
public Database.QueryLocator start(Database.BatchableContext BC) {
    super.startLogging(BC?.getJobId());
    return Database.getQueryLocator([SELECT Id, Type FROM Account WHERE Type = '_BJS_Testing_']);
}
```


### Methods to start Logging Information and Batch Results
#### Start Method
In order to start logging, your `start()` method needs to call `super.startLogging(BC?.getJobId())`. This will create the parent Log and a note that the Batch Job has started. In the end, with enhanced Logging enabled, `super.finishBatch()` will signalize the Batch Job has ended.

If you want to want to add informational logs in the `start()` method, you can use `super.logStartInformation(BC?.getJobId(), String message)` to log additional information.
#### Execute Method

It is **required** to log the end of each batch when using enhanced logging, as the child logs are what determines that a Job has completed. In order to achieve this, you can use `super.logEndOfBatch()`, which uses the Batchable Context as well as a few other parameters:

* `List<SObject> scope`: The scope of the current batch.
* `Id asyncApexJobId`: Use `BC.getJobId()` to fetch the necessary Id here.
* `Boolean success`: If you catch errors within the Batch Job (for example with partial succeses in `Database.update`), then this method allows you to include either a failure or a success for the Batch.
* `String message`: Use this to designate a specific message for the end of a batch.

Should an Exception occur in the `execute()` method and not be caught, `BatchApexErrorEvent` will fire and fill in the blanks.

Additionally, you can use `super.logInformation([List<SObject> scope], BC?.getJobId(), String message)` to log additional information inside the EXECUTE context.

``` java
public void execute(Database.BatchableContext BC, List<Account> scope) {
    super.logInformation(BC?.getJobId(), 'Test');
    for (Account account : scope) {
        account.Type = 'Prospect';
    }
    update scope;
    //log a failed Batch as opposed to the others
    super.logEndOfBatch(scope, BC?.getJobId(), false, 'Failing for Test');
}
```

#### Finish Method

The final 'Batch Job completed' log is created as part of the `super.finishBatch()` call.

If you want to want to add informational logs in the `finish()` method, you can use `super.logFinishInformation(BC?.getJobId(), String message)` to log additional information.

```java
public void finish(Database.BatchableContext BC) {
    super.finishBatch(BC?.getJobId());
}
```

## The BatchJobLogger class

You can use `BatchJobLogger` to create custom logs to your liking, the only thing `BatchJobBase` does is encapsulate it so you don't have to worry about setting all components of the `log` method.