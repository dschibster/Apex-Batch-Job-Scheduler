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
