<p align="center"><img alt="Logo" 
     src="https://github.com/dschibster/sfdx-batch-orchestrator/blob/master/resources/logo.png"></p>
<p align="center"><sub><span>Icons (Clock, Database) made by <a href="https://www.flaticon.com/authors/dmitri13" title="dmitri13">dmitri13</a> and <a href="https://www.flaticon.com/authors/smashicons" title="dmitri13">Smashicons</a> from <a href="https://www.flaticon.com/" title="Flaticon">www.flaticon.com</a></span></sub></p>
     
[![codecov](https://codecov.io/gh/dschibster/sfdx-batch-orchestrator/branch/master/graph/badge.svg?token=WPU1N1CNE8)](https://codecov.io/gh/dschibster/sfdx-batch-orchestrator)

# Installation
<div>
<span><a href="https://login.salesforce.com/packaging/installPackage.apexp?p0=04t09000000ijNTAAY" target="_blank">
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
    <a href="https://test.salesforce.com/packaging/installPackage.apexp?p0=04t09000000ijNTAAY" target="_blank">
  <img alt="Deploy to Salesforce"
       src="https://github.com/dschibster/sfdx-batch-orchestrator/blob/master/resources/deploy_unlocked.png">
</a></span><div>

# SFDX Batch Orchestrator

This is a fork from the original <a href="https://github.com/ianhuang/Apex-Batch-Job-Scheduler">Apex Batch Job Scheduler</a> from Salesforce Labs, including several improvements.

# Features

-   Configuration of Batch Job Schedules from within a Salesforce App
-   Options to configure Hourly, Daily, Weekly, Monthly or Yearly schedules, with automatic generation of Cron Expressions
-   If the options presented don't fit, you can also write your own Cron Expression!
-   If you already have a Batch Job running, you can even incorporate it without much hassle!
-   Grouping of Batch Jobs to handle dependencies
-   Flexible switching of Batch Sizes in case of scaling problems
-   Logging of Batch Job results to see if they were successful
-   Options to directly run any Batch Job or Schedule that is currently scheduled from the UI
-   **Enhanced Logging!** Now allows you to log information and successes/failures in a Batch Job. More information coming soon.

# Documentation

The documentation has moved! Please refer to the project GitHub Page of this repository here: https://dschibster.github.io/sfdx-batch-orchestrator
