/**
 * This class is part of the sfdx-batch-orchestrator package, released under the MIT license.
 *
 * @description       : Builder class for Batch Apex Status Event
 * @author            : Dennis Grzyb
 * @group             : Scheduler
 * @last modified on  : 2021-10-12
 * @last modified by  : Dennis Grzyb
 **/

public with sharing class BatchApexStatusEventBuilder {
    BatchApexStatusEvent__e statusEvent;

    public BatchApexStatusEventBuilder() {
        this.statusEvent = new BatchApexstatusEvent__e();
    }

    public BatchApexStatusEventBuilder withJobId(Id jobId) {
        this.statusEvent.AsyncApexJobId__c = jobId;
        return this;
    }

    public BatchApexStatusEventBuilder withContext(String context) {
        this.statusEvent.Context__c = context;
        return this;
    }

    public BatchApexStatusEventBuilder withScope(String scope) {
        this.statusEvent.Scope__c = scope;
        return this;
    }

    public BatchApexStatusEventBuilder withStatus(String status) {
        this.statusEvent.Status__c = status;
        return this;
    }

    public BatchApexStatusEventBuilder withMessage(String message) {
        this.statusEvent.Message__c = message;
        return this;
    }

    public BatchApexStatusEventBuilder withTimestamp(Long timestamp) {
        this.statusEvent.Timestamp__c = timestamp;
        return this;
    }

    public BatchApexStatusEventBuilder withClassName(String className) {
        this.statusEvent.ClassName__c = className;
        return this;
    }

    public BatchApexStatusEventBuilder withLimits() {
        this.statusEvent.AsyncApexCallsLimit__c = Limits.getLimitAsyncCalls();
        this.statusEvent.AsyncApexCallsUsed__c = Limits.getAsyncCalls();
        this.statusEvent.CPUTimeLimit__c = Limits.getLimitCpuTime();
        this.statusEvent.CPUTimeUsed__c = Limits.getCpuTime();
        this.statusEvent.DMLRowsLimit__c = Limits.getLimitDMLRows();
        this.statusEvent.DMLRowsUsed__c = Limits.getDMLRows();
        this.statusEvent.DMLStatementsLimit__c = Limits.getLimitDmlStatements();
        this.statusEvent.DMLStatementsUsed__c = Limits.getDmlStatements();
        this.statusEvent.SOQLQueriesLimit__c = Limits.getLimitQueries();
        this.statusEvent.SOQLQueriesUsed__c = Limits.getQueries();
        this.statusEvent.SOQLRowsLimit__c = Limits.getLimitQueryRows();
        this.statusEvent.SOQLRowsUsed__c = Limits.getQueryRows();

        return this;
    }

    public BatchApexStatusEventBuilder withSObjectJSON(String sObjectJSON) {
        this.statusEvent.SObjectJSON__c = SObjectJSON;
        return this;
    }

    public BatchApexStatusEvent__e getRecord() {
        return this.statusEvent;
    }
}
