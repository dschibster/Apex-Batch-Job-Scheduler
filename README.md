<p align="center"><img alt="Logo" 
     src="https://github.com/dschibster/sfdx-batch-orchestrator/blob/master/resources/logo.png"></p>
<p align="center"><sub><span>Icons (Clock, Database) made by <a href="https://www.flaticon.com/authors/dmitri13" title="dmitri13">dmitri13</a> and <a href="https://www.flaticon.com/authors/smashicons" title="dmitri13">Smashicons</a> from <a href="https://www.flaticon.com/" title="Flaticon">www.flaticon.com</a></span></sub></p>
     
     
# Installation
<div>
<span><a href="https://login.salesforce.com/packaging/installPackage.apexp?p0=04t09000000ibsmAAA">
  <img alt="Deploy to Salesforce"
       src="https://github.com/dschibster/sfdx-batch-orchestrator/blob/master/resources/deploy_unlocked.png">
</a>
<span>
<a href="https://githubsfdeploy.herokuapp.com">
  <img alt="Deploy to Salesforce"
       src="https://github.com/dschibster/sfdx-batch-orchestrator/blob/master/resources/deploy_unmanaged.png">
</a>
</span>
<div>
For your Sandbox:
  <div><span>
    <a href="https://test.salesforce.com/packaging/installPackage.apexp?p0=04t09000000ibsmAAA">
  <img alt="Deploy to Salesforce"
       src="https://github.com/dschibster/sfdx-batch-orchestrator/blob/master/resources/deploy_unlocked.png">
</a></span><div>

# SFDX Batch Orchestrator

This is a fork from the original <a href="https://github.com/ianhuang/Apex-Batch-Job-Scheduler">Apex Batch Job Scheduler</a> from Salesforce Labs, including several improvements.

# Features
- Configuration of Batch Job Schedules from within a Salesforce App
- Options to configure Hourly, Daily, Weekly, Monthly or Yearly schedules, with automatic generation of Cron Expressions
- If the options presented don't fit, you can also write your own Cron Expression!
- If you already have a Batch Job running, you can even incorporate it without much hassle!
- Grouping of Batch Jobs to handle dependencies
- Flexible switching of Batch Sizes in case of scaling problems
- Logging of Batch Job results to see if they were successful
- Options to directly run any Batch Job or Schedule that is currently scheduled from the UI

# Installation
Simply click on one of the Buttons to install the App (it's recommended to install the Unlocked Package to easily benefit from future updates). After this, assign the "Batch Job Scheduler" Permission Set to anyone who needs to access. Administrators automatically get access to the App.

This package requires <a href="https://github.com/dschibster/sfdx-trigger-factory">SFDX Trigger Factory</a> to be installed for the processing of Trigger Handlers.
       
# How to use the Orchestrator

## Making your jobs usable
### Batch Jobs
The functionality of the app hinges on the use of `BatchJobBase` in the Batch Jobs you want to run. Additionally, each of your Batch Jobs you want to orchestrate needs to be able to run off of a no-parameter constructor. In practice it can look something like this:

```
public class YourBatchJob extends BatchJobBase implements Database.Batchable<SObject>{

  public YourBatchJob(){

  }

  //...rest of your class
}
```

If you need parameter to be passed into your constructor to properly run your Job, you can make use of constructor overloading to call `this()` with a set of standard values that you can get via methods of your choosing. 

```
public YourBatchJob(){
  this(fetchStandardInitialValue());
}
```

In the end, the last thing you need to do is call `super.finishBatch(ctx.getJobId())` with `ctx` being the name of your Database.BatchableContext variable.
**Future updates may require you to add addditional method calls to constructor or execute methods for logging purposes.**
### Queueables
If you want to schedule a Queueable for one-off automations that do not need the Batchable interface, the Queueable needs to also extend `BatchJobBase`, but here the `execute()` method needs to include the following line first: `System.attachFinalizer(this);`.
This will execute a Finalizer that logs the result of the Queueable after it has finished executing.


## Creating your Schedule

Inside the "Batch Orchestrator" app, first of all you need to create `Batch Job Schedule` record. You will be asked what kind of schedule you want to use and need to set the necessary fields accordingly. For Hourly Jobs, it will ask you about the starting minute and the amount of hours between jobs, and so on. 

<img src="https://github.com/dschibster/sfdx-batch-orchestrator/blob/master/resources/schedule_selection.png">

Give it a telling name, as this will be used in following configurations!


## Adding Jobs
In the `Batch Apex Jobs` Related List, you are now able to create records for the Batch Jobs you want to run. You are able to either use Queuables or Batchables, as described above.
Type in the name of the Batch Job you want to include and put it into a Batch Group. For single-job schedules, you only need to use Batch Group 1. It will become more important once you want to schedule several Batch Jobs one after the other. In that case, make sure to use incremental Batch Groups. 

Once you have created your Batch Job records, you can immediately run them either by clicking `Run Now` on the Highlights Panel to execute the entire Schedule, or `Run Now` on the Job Record in the Related List to execute just the one Batch Job you currently need.

## Scheduling Jobs
Once you have created your Batch Schedule records, you can go into `Batch Job Scheduler Configuration` to see your Batch Job Schedule records. If you want to schedule your groups with the Cron Expression that you have received as a result of your Batch Job Schedule record, simply check the `Scheduled` checkbox and click `Apply Changes` to create the Scheduled Jobs in the background. The Scheduled Jobs will now be connected to the Batch Job Schedule records, so the Batch Jobs inside their grouping will be executed even if you change them after the fact.

<img src="https://github.com/dschibster/sfdx-batch-orchestrator/blob/master/resources/scheduler_configuration.png">


## Changing the Schedule
If you want to change the schedule for a certain record, you first need to unschedule it using the Batch Job configuration. After that, you are free to change the picklist values and reschedule it using the Configuration again.
