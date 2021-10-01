/**
 * This class is part of the sfdx-batch-orchestrator package, released under the MIT license.
 *
 * @description       : Test Data Factory to create the correct Data for Test Cases
 * @author            : dschibster
 * @group             : Batch Job Management
 * @last modified on  : 2021-08-27
 * @last modified by  : dschibster
 **/

@isTest
public with sharing class BatchJobSchedulerTestDataFactory {
    public static void createBatchSchedulerContext() {
        Batch_Job_Schedule__c sch = new Batch_Job_Schedule__c();
        sch.RecordTypeId = RecordTypeCache.SCHEDULER_RECORD_TYPE_HOURLY_JOB;
        sch.Name = 'Test Hourly Name 001';
        sch.Every_Number_of_Hours__c = 1;
        sch.Preferred_Start_Minute__c = '0';
        insert sch;

        Batch_Apex_Job__c batchJob1 = new Batch_Apex_Job__c(
            Batch_Job_Schedule__c = sch.Id,
            Batch_Class_Name__c = 'TestBatchJob1',
            Batch_Group__c = '1',
            Enabled__c = true,
            RecordTypeId = RecordTypeCache.JOB_RECORD_TYPE_BATCHABLE
        );
        Batch_Apex_Job__c batchJob2 = new Batch_Apex_Job__c(
            Batch_Job_Schedule__c = sch.Id,
            Batch_Class_Name__c = 'TestBatchJob2',
            Batch_Group__c = '1',
            Enabled__c = true,
            RecordTypeId = RecordTypeCache.JOB_RECORD_TYPE_BATCHABLE
        );
        Batch_Apex_Job__c batchJob3 = new Batch_Apex_Job__c(
            Batch_Job_Schedule__c = sch.Id,
            Batch_Class_Name__c = 'TestBatchJob3',
            Batch_Group__c = '2',
            Enabled__c = true,
            RecordTypeId = RecordTypeCache.JOB_RECORD_TYPE_BATCHABLE
        );
        Batch_Apex_Job__c queueableJob1 = new Batch_Apex_Job__c(
            Batch_Job_Schedule__c = sch.Id,
            Batch_Class_Name__c = 'testqueueable',
            Batch_Group__c = '2',
            Enabled__c = true,
            RecordTypeId = RecordTypeCache.JOB_RECORD_TYPE_QUEUEABLE
        );

        insert new List<Batch_Apex_Job__c>{ batchJob1, batchJob2, batchJob3, queueableJob1 };

        Account account1 = new Account(Name = '__BatchJobSchedulerTest001', Type = '_BJS_Testing_');
        Account account2 = new Account(Name = '__BatchJobSchedulerTest002', Type = '_BJS_Testing_');
        Account account3 = new Account(Name = '__BatchJobSchedulerTest003', Type = '_BJS_Testing_');
        insert new List<Account>{ account1, account2, account3 };
    }

    public static Batch_Job_Schedule__c createWeeklyBatchJobSchedule() {
        Batch_Job_Schedule__c sch = new Batch_Job_Schedule__c();
        sch.RecordTypeId = RecordTypeCache.SCHEDULER_RECORD_TYPE_WEEKLY_JOB;
        sch.Name = 'Test Weekly Name 001';
        sch.Preferred_Start_Week_Day__c = 'MON;TUE;WED';
        sch.Preferred_Start_Hour__c = '3';
        sch.Preferred_Start_Minute__c = '2';
        return sch;
    }

    public static Batch_Apex_Job__c createBatchJob(Batch_Job_Schedule__c schedule) {
        Batch_Apex_Job__c batchJob = new Batch_Apex_Job__c(
            Batch_Job_Schedule__c = schedule.Id,
            Batch_Class_Name__c = 'TestBatchJob1',
            Batch_Group__c = '1',
            Enabled__c = true,
            RecordTypeId = RecordTypeCache.JOB_RECORD_TYPE_BATCHABLE
        );
        return batchJob;
    }
}
