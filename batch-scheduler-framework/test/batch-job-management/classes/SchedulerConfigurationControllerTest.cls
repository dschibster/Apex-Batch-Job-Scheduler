@isTest
private class SchedulerConfigurationControllerTest {
    @testSetup
    static void setup() {
        Batch_Job_Schedule__c sch1 = new Batch_Job_Schedule__c();
        sch1.RecordTypeId = RecordTypeCache.SCHEDULER_RECORD_TYPE_HOURLY_JOB;
        sch1.Name = 'Test Hourly Name 001';
        sch1.Every_Number_of_Hours__c = 1;
        sch1.Preferred_Start_Minute__c = '0';

        Batch_Job_Schedule__c sch2 = new Batch_Job_Schedule__c();
        sch2.RecordTypeId = RecordTypeCache.SCHEDULER_RECORD_TYPE_MONTHLY_JOB;
        sch2.Name = 'Test Monthly Name 001';
        sch2.Every_Number_of_Months__c = 3;
        sch2.Preferred_Start_Day__c = '5';
        sch2.Preferred_Start_Hour__c = '4';
        sch2.Preferred_Start_Minute__c = '3';

        Batch_Job_Schedule__c sch3 = new Batch_Job_Schedule__c();
        sch3.RecordTypeId = RecordTypeCache.SCHEDULER_RECORD_TYPE_YEARLY_JOB;
        sch3.Name = 'Test Yearly Name 001';
        sch3.Preferred_Start_Month__c = 'December';
        sch3.Preferred_Start_Minute__c = '4';

        insert new List<Batch_Job_Schedule__c>{ sch1, sch2, sch3 };
        Id myUserId = UserInfo.getUserId();

        User testUser = [SELECT Id FROM User WHERE isActive = TRUE AND Profile.Name LIKE '%Administrator%' AND Id != :UserInfo.getUserId() LIMIT 1];
        System.runAs(testUser) {
            PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'Batch_Job_Scheduler' LIMIT 1];
            PermissionSetAssignment psa = new PermissionSetAssignment(AssigneeId = myUserId, PermissionSetId = ps.Id);
            Database.insert(psa, false); //There will be errors where there already is a PermSetAssignment on the Target Org. But for fresh Deployments on Fresh Orgs this is essential.
        }
    }

    @isTest
    static void testLoad() {
        PageReference pageRef = Page.SchedulerConfiguration;
        Test.setCurrentPage(pageRef);

        SchedulerConfigurationController controller = new SchedulerConfigurationController();

        System.assertEquals(3, controller.scheduledApexJobs.size());
    }

    @isTest
    static void testSave() {
        PageReference pageRef = Page.SchedulerConfiguration;
        Test.setCurrentPage(pageRef);

        Test.startTest();

        SchedulerConfigurationController controller = new SchedulerConfigurationController();
        controller.scheduledApexJobs[0].scheduled = true;
        controller.save();

        controller.scheduledApexJobs[0].scheduled = false;
        controller.save();

        Test.stopTest();

        System.assertEquals(3, controller.scheduledApexJobs.size());
        System.assertEquals(false, controller.scheduledApexJobs[0].scheduled);
    }
}