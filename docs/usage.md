# Using the Orchestrator in the UI

## Creating your Schedule

Inside the "Batch Orchestrator" app, first of all you need to create `Batch Job Schedule` record. You will be asked what kind of schedule you want to use and need to set the necessary fields accordingly. For Hourly Jobs, it will ask you about the starting minute and the amount of hours between jobs, and so on.

<img src="https://github.com/dschibster/sfdx-batch-orchestrator/blob/master/resources/schedule_selection.png?raw=true">

Give it a telling name, as this will be used in following configurations!

## Adding Jobs

In the `Batch Apex Jobs` Related List, you are now able to create records for the Batch Jobs you want to run. You are able to either use Queuables or Batchables, as described above.
Type in the name of the Batch Job you want to include and put it into a Batch Group. For single-job schedules, you only need to use Batch Group 1. It will become more important once you want to schedule several Batch Jobs one after the other. In that case, make sure to use incremental Batch Groups.

**If you are using the [Enhanced Logging](logging.md#enhanced-logging) functionality, make sure to check the "Enhanced Logging" checkbox**

Once you have created your Batch Job records, you can immediately run them either by clicking `Run Now` on the Highlights Panel to execute the entire Schedule, or `Run Now` on the Job Record in the Related List to execute just the one Batch Job you currently need.

## Scheduling Jobs

Once you have created your Batch Schedule records, you can go into `Batch Job Scheduler Configuration` to see your Batch Job Schedule records. If you want to schedule your groups with the Cron Expression that you have received as a result of your Batch Job Schedule record, simply check the `Scheduled` checkbox and click `Apply Changes` to create the Scheduled Jobs in the background. The Scheduled Jobs will now be connected to the Batch Job Schedule records, so the Batch Jobs inside their grouping will be executed even if you change them after the fact.

<img src="https://github.com/dschibster/sfdx-batch-orchestrator/blob/master/resources/scheduler_configuration.png?raw=true">

## Changing the Schedule

If you want to change the schedule for a certain record, you first need to unschedule it using the Batch Job configuration. After that, you are free to change the picklist values and reschedule it using the Configuration again.
