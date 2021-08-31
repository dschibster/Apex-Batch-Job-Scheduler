/**
 * This class is part of the sfdx-batch-scheduler-framework package, released under the MIT license.
 *
 * @description       : Test Class that verifies a Batch Job runs when fired via Visualforce Page
 * @author            : dschibster
 * @group             : Batch Job Management
 * @last modified on  : 2021-08-27
 * @last modified by  : dschibster
 **/

@isTest
public with sharing class RunBatchApexJobControllerTest {
    @testSetup
    static void setup() {
        BatchJobSchedulerTestDataFactory.createBatchSchedulerContext();
    }

    @isTest
    static void runJobFromController() {
        Batch_Apex_Job__c firstJob = [
            SELECT Id, Batch_Class_Name__c, Batch_Job_Schedule__c, Batch_Size__c, RecordType.DeveloperName
            FROM Batch_Apex_Job__c
            LIMIT 1
        ];
        RunBatchApexJobController ctrl = new RunBatchApexJobController(new ApexPages.StandardController(firstJob));
        Test.startTest();
        ctrl.runJob();
        Test.stopTest();
    }
}
