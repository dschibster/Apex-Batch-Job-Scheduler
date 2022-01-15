/**
 * This class is part of the sfdx-batch-orchestrator package, released under the MIT license.
 *
 * @description       : Test Class that verifies the ad-hoc runs of Schedules and Batch Jobs
 * @author            : dschibster
 * @group             : Batch Job Management
 * @last modified on  : 2022-01-15
 * @last modified by  : dschibster
 **/

@isTest
public with sharing class BatchOrchestratorTest {
    @TestSetup
    static void makeData() {
        BatchJobSchedulerTestDataFactory.createBatchSchedulerContext();
    }

    @isTest
    static void confirmApexJobRunWithObject() {
        Batch_Apex_Job__c firstJob = [
            SELECT Id, Batch_Class_Name__c, Batch_Job_Schedule__c, Batch_Size__c, RecordType.DeveloperName, EnhancedLogging__c
            FROM Batch_Apex_Job__c
            WHERE Batch_Group__c = '1'
            LIMIT 1
        ];

        Test.startTest();
        BatchOrchestrator.runBatchJob(firstJob);
        Test.stopTest();

        List<Account> accounts = [SELECT Id, Type FROM Account];

        System.assertEquals(3, accounts.size(), 'The Account were not found');
        System.assertEquals('Prospect', accounts[0].Type, 'The Type was not switched for Account 1');
        System.assertEquals('Prospect', accounts[1].Type, 'The Type was not switched for Account 2');
        System.assertEquals('Prospect', accounts[2].Type, 'The Type was not switched for Account 3');
    }

    @isTest
    static void confirmApexJobRunWithId() {
        Batch_Apex_Job__c firstJob = [
            SELECT Id, Batch_Class_Name__c, Batch_Job_Schedule__c, Batch_Size__c, RecordType.DeveloperName, EnhancedLogging__c
            FROM Batch_Apex_Job__c
            WHERE Batch_Group__c = '1'
            LIMIT 1
        ];

        Test.startTest();
        BatchOrchestrator.runBatchJob(firstJob.Id);
        Test.stopTest();

        List<Account> accounts = [SELECT Id, Type FROM Account];

        System.assertEquals(3, accounts.size(), 'The Account were not found');
        System.assertEquals('Prospect', accounts[0].Type, 'The Type was not switched for Account 1');
        System.assertEquals('Prospect', accounts[1].Type, 'The Type was not switched for Account 2');
        System.assertEquals('Prospect', accounts[2].Type, 'The Type was not switched for Account 3');
    }

    @isTest
    static void confirmScheduleRun() {
        List<Batch_Apex_Job__c> jobsToNotRun = [
            SELECT Id, Batch_Class_Name__c, Batch_Job_Schedule__c, Batch_Size__c, RecordType.DeveloperName, EnhancedLogging__c
            FROM Batch_Apex_Job__c
            WHERE Batch_Group__c = '2'
        ];
        delete jobsToNotRun;

        Batch_Job_Schedule__c sched = [SELECT Id FROM Batch_Job_Schedule__c LIMIT 1];

        Test.startTest();
        BatchOrchestrator.runBatchSchedule(sched.Id);
        Test.stopTest();

        List<Account> accounts = [SELECT Id, Type FROM Account];

        System.assertEquals(3, accounts.size(), 'The Account were not found');
        System.assertEquals('Prospect', accounts[0].Type, 'The Type was not switched for Account 1');
        System.assertEquals('Prospect', accounts[1].Type, 'The Type was not switched for Account 2');
        System.assertEquals('Prospect', accounts[2].Type, 'The Type was not switched for Account 3');
    }
}
