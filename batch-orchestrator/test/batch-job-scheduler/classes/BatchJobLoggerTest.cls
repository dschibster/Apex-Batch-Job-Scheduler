/**
 * This class is part of the sfdx-batch-orchestrator package, released under the MIT license.
 *
 * @description       : Logger Test Class to test additional methods that aren't covered by BatchJobBaseTest
 * @author            : Dennis Grzyb
 * @group             :
 * @last modified on  : 2021-10-12
 * @last modified by  : Dennis Grzyb
 **/
@isTest
public with sharing class BatchJobLoggerTest {
    @IsTest
    static void shouldCreateEnhancedLogsForQueueable() {
        Test.startTest();
        BatchJobBase emptyQueueable = (BatchJobBase) new testQueueable();
        emptyQueueable.jobType = 'Queueable';
        emptyQueueable.className = 'testQueueable';
        emptyQueueable.enhancedLoggingEnabled = true;
        emptyQueueable.enqueue(null);
        Test.stopTest();
        Test.getEventBus().deliver();

        System.assertEquals(2, [SELECT COUNT() FROM Batch_Job_Log__c WHERE RecordTypeId = :RecordTypeCache.LOG_RECORD_TYPE_CHILD], 'No 3 log entries found');
        System.assertEquals(
            1,
            [SELECT COUNT() FROM Batch_Job_Log__c WHERE RecordTypeId = :RecordTypeCache.LOG_RECORD_TYPE_QUEUEABLE],
            'No parent log entry found'
        );
        Batch_Job_Log__c parentLog = [SELECT Id, Result__c FROM Batch_Job_Log__c WHERE RecordTypeId = :RecordTypeCache.LOG_RECORD_TYPE_QUEUEABLE LIMIT 1];
        System.assertEquals('Completed', parentLog.Result__c, 'No update to "completed" for Queuable Parent Log');
    }
}
