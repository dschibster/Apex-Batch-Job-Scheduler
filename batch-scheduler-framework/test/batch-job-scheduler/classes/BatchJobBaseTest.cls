@isTest
public with sharing class BatchJobBaseTest {
    
    @isTest static void testFinalizerInterfaceFired(){
        Test.startTest();
        BatchJobBase emptyQueueable = (BatchJobBase) new testQueueable();
        emptyQueueable.jobType = 'Queueable';
        emptyQueueable.enqueue(null);
        Test.stopTest();

        System.assert(![SELECT Id FROM Batch_Job_Log__c].isEmpty(), 'Finalizer has not created a Batch log.');
    }
    
}