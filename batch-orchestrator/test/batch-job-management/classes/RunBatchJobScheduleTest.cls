/**
 * This class is part of the sfdx-batch-scheduler-framework package, released under the MIT license.
 * 
 * @description       : Test Class that verifies the Ad-Hoc run of an entire Batch Job Schedule
 * @author            : dschibster
 * @group             : Batch Job Management
 * @last modified on  : 2021-08-27
 * @last modified by  : dschibster
**/

@isTest
public with sharing class RunBatchJobScheduleTest {
    
    @testSetup static void setup() {
        BatchJobSchedulerTestDataFactory.createBatchSchedulerContext();
    }

    @isTest static void runScheduleFromCtrl(){
        Batch_Job_Schedule__c sched = [SELECT Id FROM Batch_Job_Schedule__c LIMIT 1];
        RunBatchJobScheduleController ctrl = new RunBatchJobScheduleController(new ApexPages.StandardController(sched));
        Test.startTest();
        ctrl.runSchedule();
        Test.stopTest();
    }
}
