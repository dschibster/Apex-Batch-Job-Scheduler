/*
Copyright (c) Ian Huang Salesforce

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE
OR OTHER DEALINGS IN THE SOFTWARE.
*/

@isTest
public class BatchJobSchedulerTest {
    @testSetup
    static void setup() {
        BatchJobSchedulerTestDataFactory.createBatchSchedulerContext();
    }

    @isTest
    static void testExecute() {
        Id cronTriggerId = System.schedule('test job.schedule.Name', '0 3 4 5 1/3 ? *', new BatchJobScheduler());

        Batch_Job_Schedule__c sched = [SELECT Id FROM Batch_Job_Schedule__c LIMIT 1];
        sched.Cron_Trigger_Id__c = cronTriggerId;
        update sched;

        BatchJobScheduler batchJobScheduler = new BatchJobScheduler();
        batchJobScheduler.run(cronTriggerId);

        List<Account> accounts = [SELECT Id, Type FROM Account];
        System.assertEquals(3, accounts.size());
        System.assertEquals('_BJS_Testing_', accounts[0].Type);
        System.assertEquals('_BJS_Testing_', accounts[1].Type);
        System.assertEquals('_BJS_Testing_', accounts[2].Type);
    }

    @isTest
    static void testExecuteNext() {
        Id cronTriggerId = System.schedule('test job.schedule.Name', '0 3 4 5 1/3 ? *', new BatchJobScheduler());
        
        Batch_Job_Schedule__c sched = [SELECT Id FROM Batch_Job_Schedule__c LIMIT 1];
        sched.Cron_Trigger_Id__c = cronTriggerId;
        update sched;

        BatchJobScheduler batchJobScheduler = new BatchJobScheduler();
        batchJobScheduler.run(cronTriggerId);
        batchJobScheduler.executeNextJob();

        List<Account> accounts = [SELECT Id, Type FROM Account];
        System.assertEquals(3, accounts.size());
        System.assertEquals('_BJS_Testing_', accounts[0].Type);
        System.assertEquals('_BJS_Testing_', accounts[1].Type);
        System.assertEquals('_BJS_Testing_', accounts[2].Type);
    }

    @isTest static void testConstructionOfJobMap(){
        Id cronTriggerId = System.schedule('test job.schedule.Name', '0 3 4 5 1/3 ? *', new BatchJobScheduler());
        

        Batch_Job_Schedule__c sched = [SELECT Id FROM Batch_Job_Schedule__c LIMIT 1];
        sched.Cron_Trigger_Id__c = cronTriggerId;
        update sched;

        List<Batch_Apex_Job__c> batchJobs = new List<Batch_Apex_Job__c>();
        for(Batch_Apex_Job__c qAble : [SELECT Id FROM Batch_Apex_Job__c WHERE Batch_Group__c = '2']){
            qAble.Enabled__c = false;
            batchJobs.add(qAble);
        }
        
        Batch_Apex_Job__c qAbleNewGroup = new Batch_Apex_Job__c(
            Batch_Job_Schedule__c = sched.Id,
            Batch_Class_Name__c = 'testqueueable',
            Batch_Group__c = '3',
            Enabled__c = true,
            RecordTypeId = RecordTypeCache.JOB_RECORD_TYPE_QUEUEABLE
        );
        batchJobs.add(qAbleNewGroup);
        upsert batchJobs;

        
        //Expected: isEnabledMap has indices from 1 to 3, batchJobs Map only has values for 1 and 3

        BatchJobScheduler batchJobScheduler = new BatchJobScheduler();
        batchJobScheduler.batchJobs = batchJobScheduler.loadActiveBatchJobs(cronTriggerId);
        System.assertEquals(new Set<Integer>(new List<Integer>{1,2,3}), batchJobScheduler.isEnabledMap.keySet());
        System.assert(batchJobScheduler.isEnabledMap.get(1), 'Batch Jobs in Group 1 were seen as disabled');
        System.assert(!batchJobScheduler.isEnabledMap.get(2), 'Batch Jobs in Group 2 were seen as enabled');
        System.assert(batchJobScheduler.isEnabledMap.get(3), 'Batch Jobs in Group 3 were seen as disabled');
        System.assert(batchJobScheduler.batchJobs.containsKey('1'), 'Batch Jobs in Group 1 were not found');
        System.assert(!batchJobScheduler.batchJobs.containsKey('2'), 'Batch Jobs in Group 2 were found');
        System.assert(batchJobScheduler.batchJobs.containsKey('3'), 'Batch Jobs in Group 3 were not found');

    }

    @isTest
    static void testExecuteNextSkipIndex() {
        Id cronTriggerId = System.schedule('test job.schedule.Name', '0 3 4 5 1/3 ? *', new BatchJobScheduler());
        

        Batch_Job_Schedule__c sched = [SELECT Id FROM Batch_Job_Schedule__c LIMIT 1];
        sched.Cron_Trigger_Id__c = cronTriggerId;
        update sched;

        List<Batch_Apex_Job__c> batchJobs = new List<Batch_Apex_Job__c>();
        for(Batch_Apex_Job__c qAble : [SELECT Id FROM Batch_Apex_Job__c WHERE Batch_Group__c = '2']){
            qAble.Enabled__c = false;
            batchJobs.add(qAble);
        }
        
        Batch_Apex_Job__c qAbleNewGroup = new Batch_Apex_Job__c(
            Batch_Job_Schedule__c = sched.Id,
            Batch_Class_Name__c = 'testqueueable',
            Batch_Group__c = '3',
            Enabled__c = true,
            RecordTypeId = RecordTypeCache.JOB_RECORD_TYPE_QUEUEABLE
        );
        batchJobs.add(qAbleNewGroup);
        upsert batchJobs;

        BatchJobScheduler batchJobScheduler = new BatchJobScheduler();
        batchJobScheduler.run(cronTriggerId);
        batchJobScheduler.executeNextJob();

        System.assertEquals(3,batchJobScheduler.index, 'Disabled index 2 was not skipped');
        System.assert(!batchJobScheduler.batchJobs.containsKey('2'));
    }

    @isTest
    static void testlogBatchJob() {
        BatchJobHelper.logBatchJob('batchJobName', System.now(), 'errorMessages');

        List<Batch_Job_Log__c> logs = [SELECT Id FROM Batch_Job_Log__c];
        System.assertEquals(1, logs.size());
    }

    @isTest
    static void testBatchJob1() {
        BatchJobBase testBatchJob1 = (BatchJobBase) new TestBatchJob1();
        testBatchJob1.jobType = 'Batchable';
        Test.startTest();
        testBatchJob1.enqueue(100);
        Test.stopTest();

        List<Account> accounts = [SELECT Id, Type FROM Account];
        System.assertEquals(3, accounts.size());
        System.assertEquals('Prospect', accounts[0].Type);
        System.assertEquals('Prospect', accounts[1].Type);
        System.assertEquals('Prospect', accounts[2].Type);
    }

    @isTest
    static void testBatchJob2() {
        BatchJobBase testBatchJob2 = (BatchJobBase) new TestBatchJob2();
        testBatchJob2.jobType = 'Batchable';
        Test.startTest();
        testBatchJob2.enqueue(100);
        Test.stopTest();

        List<Account> accounts = [SELECT Id, Type FROM Account];
        System.assertEquals(3, accounts.size());
        System.assertEquals('Prospect', accounts[0].Type);
        System.assertEquals('Prospect', accounts[1].Type);
        System.assertEquals('Prospect', accounts[2].Type);
    }

    @isTest
    static void testBatchJob3() {
        BatchJobBase testBatchJob3 = (BatchJobBase) new TestBatchJob3();
        testBatchJob3.jobType = 'Batchable';
        Test.startTest();
        testBatchJob3.enqueue(100);
        Test.stopTest();

        List<Account> accounts = [SELECT Id, Type FROM Account];
        System.assertEquals(3, accounts.size());
        System.assertEquals('Prospect', accounts[0].Type);
        System.assertEquals('Prospect', accounts[1].Type);
        System.assertEquals('Prospect', accounts[2].Type);
    }
}