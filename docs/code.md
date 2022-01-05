# Adjusting your Batch Jobs

SFDX Batch Orchestrator runs based on a generic Scheduler class which in turn is able to invoke our separate Jobs. For this, we need to adjust our Batch Jobs to be compatible with the Base class. 

## Batch Jobs

Depending on if you use [Enhanced Logging](logging.md), the implementation of the `BatchJobBase` class differs slightly. In a standard case, you 
need only extend the `BatchJobBase` class:

**Important:** The Batch Job requires a no-parameter constructor for generic scheduling purposes. You can however have it call another constructor inside with constructor overloading to get your parameters when needed.

``` java
public class YourBatchJob extends BatchJobBase implements Database.Batchable<SObject>{

  public YourBatchJob(){

  }
```

``` java
public class YourBatchJob extends BatchJobBase implements Database.Batchable<SObject>{

  public YourBatchJob(){
    this(getStartingParameter());
  }

  public YourBatchJob(String necessaryParameter){

  }

  public static String getStartingParameter(){
    return 'example';
  }
```

In the end, the last thing you need to do is call `super.finishBatch(ctx?.getJobId())` with `ctx` being the name of your Database.BatchableContext variable. This needs to happen in the `finish()` method of your Batch Job.

## Queueables
If you want to schedule a Queueable for one-off automations that do not need the Batchable interface, the Queueable needs to also extend `BatchJobBase`, but here the `execute()` method needs to include the following line first: `System.attachFinalizer(this);`.
This will execute a Finalizer that logs the result of the Queueable after it has finished executing.

``` java
public class YourQueueable extends BatchJobBase implements Queueable{

    public void execute(QueueableContext QC){
        System.attachFinalizer(this);
    }
}
```

## Workaround for required parameters 

If you need parameter to be passed into your constructor to properly run your Job, you can make use of constructor overloading to call `this()` with a set of standard values that you can get via methods of your choosing.

``` java
public YourBatchJob(){
  this(fetchStandardInitialValue());
}
```

This will make sure to invoke the Batch Job with the necessary parameters.

## Additionally when using Enhanced Logging

In case you use enhanced Logging and you want to listen to the Standard `BatchApexErrorEvent` when something occurs in the async context, you need to additionally implement `Database.RaisesPlatformEvents` interface.

``` java
public class YourBatchJob extends BatchJobBase implements Database.Batchable<SObject>, Database.RaisesPlatformEvents{

  public YourBatchJob(){

  }
}
```


