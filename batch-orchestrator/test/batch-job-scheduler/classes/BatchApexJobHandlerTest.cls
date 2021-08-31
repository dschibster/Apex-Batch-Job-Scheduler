@isTest
public with sharing class BatchApexJobHandlerTest {
    @isTest
    static void shouldVerifyBeforeInsert() {
        Batch_Job_Schedule__c testSchedule = BatchJobSchedulerTestDataFactory.createWeeklyBatchJobSchedule();
        insert testSchedule;

        Test.startTest();
        Batch_Apex_Job__c testBatch = BatchJobSchedulerTestDataFactory.createBatchJob(testSchedule);
        testBatch.Batch_Class_Name__c = 'this_should_fail';
        Exception exceptionCaught;
        try {
            insert testBatch;
        } catch (Exception e) {
            exceptionCaught = e;
        }
        Test.stopTest();
        System.assert(exceptionCaught != null, 'The insertion of a false Batch Job was not prevented');
    }

    @isTest
    static void shouldVerifyBeforeUpdate() {
        Batch_Job_Schedule__c testSchedule = BatchJobSchedulerTestDataFactory.createWeeklyBatchJobSchedule();
        insert testSchedule;

        Test.startTest();
        Batch_Apex_Job__c testBatch = BatchJobSchedulerTestDataFactory.createBatchJob(testSchedule);
        testBatch.Batch_Class_Name__c = 'TestBatchJob1';
        insert testBatch;

        Exception exceptionCaught;
        try {
            testBatch.Batch_Class_Name__c = 'this_should_fail';
            update testBatch;
        } catch (Exception e) {
            exceptionCaught = e;
        }
        Test.stopTest();
        System.assert(exceptionCaught != null, 'The insertion of a false Batch Job was not prevented');
    }
}
