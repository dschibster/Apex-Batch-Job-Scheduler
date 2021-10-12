# Installation

<div>
<span><a href="https://login.salesforce.com/packaging/installPackage.apexp?p0=04t09000000iih4AAA">
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
    <a href="https://test.salesforce.com/packaging/installPackage.apexp?p0=04t09000000iih4AAA">
  <img alt="Deploy to Salesforce"
       src="https://github.com/dschibster/ms-triggerframework/blob/master/resources/deploy_unlocked.png">
</a></span><div>

# Batch Job Scheduler Framework

This is a fork from the original <a href="https://github.com/ianhuang/Apex-Batch-Job-Scheduler">Apex Batch Job Scheduler</a> from Salesforce Labs, including several improvements:

-   Optimized the Organization of Batch Groups
-   Leveraging the Finalizer Interface to also make use of Queueables (as a separate way to fire single-use Schedulable Jobs without Batch Logic)
-   Giving the option to Run ad-hoc Schedules and Jobs
-   Outfitting everything with a nice Lightning App that gives you a quick overview of everything

-   **Enhanced Logging!** Now allows you to log messages and successes failures in hierarchical logs. Readme adjustment coming soon.
