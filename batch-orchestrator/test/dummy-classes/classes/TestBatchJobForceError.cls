/**
 * This class is part of the sfdx-batch-orchestrator package, released under the MIT license.
 *
 * @description       : Test Batch Job for Verification of BatchApexErrorEvent Handling
 * @author            : Dennis Grzyb
 * @group             : Batch Job Management
 * @last modified on  : 2021-10-12
 * @last modified by  : Dennis Grzyb
 **/

public with sharing class TestBatchJobForceError extends BatchJobBase implements Database.Batchable<sObject>, Database.RaisesPlatformEvents {
    public Database.QueryLocator start(Database.BatchableContext BC) {
        super.startLogging(BC?.getJobId());
        return Database.getQueryLocator([SELECT Id, Type FROM Account WHERE Type = '_BJS_Testing_']);
    }

    public void execute(Database.BatchableContext BC, List<Account> scope) {
        super.logInformation(BC?.getJobId(), 'Test');
        for (Account account : scope) {
            account.Type = 'Prospect';
        }
        update scope;
        //log a failed Batch as opposed to the others
        throw new DmlException('Forced Error');
    }

    public void finish(Database.BatchableContext BC) {
        super.finishBatch(BC?.getJobId());
    }
}
