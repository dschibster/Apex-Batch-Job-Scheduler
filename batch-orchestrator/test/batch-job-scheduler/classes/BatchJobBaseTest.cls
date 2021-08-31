/**
 * This class is part of the sfdx-batch-scheduler-framework package, released under the MIT license.
 *
 * @description       : Test Class to verify the Finalizer Interface in BatchJobBase works.
 * @author            : dschibster
 * @group             : Scheduler
 * @last modified on  : 2021-08-27
 * @last modified by  : dschibster
 **/

@isTest
public with sharing class BatchJobBaseTest {
    @isTest
    static void testFinalizerInterfaceFired() {
        Test.startTest();
        BatchJobBase emptyQueueable = (BatchJobBase) new testQueueable();
        emptyQueueable.jobType = 'Queueable';
        emptyQueueable.enqueue(null);
        Test.stopTest();

        System.assert(![SELECT Id FROM Batch_Job_Log__c].isEmpty(), 'Finalizer has not created a Batch log.');
    }
}
