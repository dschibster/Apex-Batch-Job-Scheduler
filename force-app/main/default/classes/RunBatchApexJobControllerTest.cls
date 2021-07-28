@isTest
public with sharing class RunBatchApexJobControllerTest {

    @testSetup static void setup() {
        BatchJobSchedulerTestDataFactory.createBatchSchedulerContext();
    }

    @isTest static void runJobFromController(){
        Batch_Apex_Job__c firstJob = [SELECT Id, Batch_Class_Name__c,Batch_Job_Schedule__c, Batch_Size__c, RecordType.DeveloperName FROM Batch_Apex_Job__c LIMIT 1];
        RunBatchApexJobController ctrl = new RunBatchApexJobController(new ApexPages.StandardController(firstJob));
        Test.startTest();
        ctrl.runJob();
        Test.stopTest();
    }
}
