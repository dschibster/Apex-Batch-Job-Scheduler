/**
 * Copyright (c) Ian Huang Salesforce
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
 * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
 * IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
 * DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
 * OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE
 * OR OTHER DEALINGS IN THE SOFTWARE.
 *
 * @description       : Responsible for Caching necessary RecordType Ids.
 * @author            : ianhuang
 * @group             : Batch Job Management
 * @last modified on  : 2021-08-27
 * @last modified by  : dschibster
 **/

public inherited sharing class RecordTypeCache {
    private static Map<String, Schema.RecordTypeInfo> rtInfosBatchJobSchedule = Schema.SObjectType.Batch_Job_Schedule__c.getRecordTypeInfosByDeveloperName();
    private static Map<String, Schema.RecordTypeInfo> rtInfosBatchJobApexJob = Schema.SObjectType.Batch_Apex_Job__c.getRecordTypeInfosByDeveloperName();
    public static final Id SCHEDULER_RECORD_TYPE_HOURLY_JOB = rtInfosBatchJobSchedule.get('Hourly_Job').getRecordTypeId();
    public static final Id SCHEDULER_RECORD_TYPE_DAILY_JOB = rtInfosBatchJobSchedule.get('Daily_Job').getRecordTypeId();
    public static final Id SCHEDULER_RECORD_TYPE_WEEKLY_JOB = rtInfosBatchJobSchedule.get('Weekly_Job').getRecordTypeId();
    public static final Id SCHEDULER_RECORD_TYPE_MONTHLY_JOB = rtInfosBatchJobSchedule.get('Monthly_Job').getRecordTypeId();
    public static final Id SCHEDULER_RECORD_TYPE_YEARLY_JOB = rtInfosBatchJobSchedule.get('Yearly_Job').getRecordTypeId();
    public static final Id SCHEDULER_RECORD_TYPE_CUSTOM_CRON_EXPRESSION_JOB = rtInfosBatchJobSchedule.get('Custom_Cron_Expression_Job').getRecordTypeId();
    public static final Id SCHEDULER_RECORD_TYPE_EXISTING_SCHEDULED_JOB_JOB = rtInfosBatchJobSchedule.get('Existing_Scheduled_Job').getRecordTypeId();
    public static final Id JOB_RECORD_TYPE_BATCHABLE = rtInfosBatchJobApexJob.get('Batchable').getRecordTypeId();
    public static final Id JOB_RECORD_TYPE_QUEUEABLE = rtInfosBatchJobApexJob.get('Queueable').getRecordTypeId();
}
