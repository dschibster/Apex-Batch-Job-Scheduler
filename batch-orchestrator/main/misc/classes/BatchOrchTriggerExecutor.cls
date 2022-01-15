/**
 * @description       : Resolves dependency on sfdx-trigger-factory by offsetting key
 *                      functionality of the framework into a virtual class.
 * @author            : Dennis Grzyb
 * @group             : batch-job-scheduler
 * @last modified on  : 2022-01-07
 * @last modified by  : Dennis Grzyb
 **/

public virtual class BatchOrchTriggerExecutor {
    //Context relevant variables
    public Map<Id, SObject> triggerNewMap;
    public List<SObject> triggerNew;
    public Map<Id, SObject> triggerOldMap;
    public List<SObject> triggerOld;
    public String triggerOperation;

    //SObject Lists used within the Handler Classes
    public List<sObject> lstInsert;
    public List<sObject> lstUpsert;
    public List<sObject> lstUpdate;
    public List<sObject> lstDelete;

    public BatchOrchTriggerExecutor() {
        triggerNewMap = Trigger.newMap;
        triggerNew = Trigger.new;
        triggerOldMap = Trigger.oldMap;
        triggerOld = Trigger.old;
        triggerOperation = Trigger.OperationType.name();

        lstInsert = new List<sObject>();
        lstUpsert = new List<sObject>();
        lstUpdate = new List<sObject>();
        lstDelete = new List<sObject>();
    }

    public void execute() {
        //Split the operationtype (for example AFTER_INSERT) into its two pieces to determine what we need.
        List<String> operations = triggerOperation.split('_');
        Boolean isBefore = operations[0] == 'BEFORE';
        String dmlOperation = operations[1];

        // Before Trigger
        if (isBefore) {
            // Call the bulk before to handle any caching of data and enable bulkification
            bulkBefore();

            switch on dmlOperation {
                when 'DELETE' {
                    for (SObject obj : triggerOldMap.values()) {
                        beforeDelete(obj);
                    }
                }
                when 'INSERT' {
                    for (SObject obj : triggerNew) {
                        beforeInsert(obj);
                    }
                }
                when 'UPDATE' {
                    for (SObject obj : triggerNew) {
                        beforeUpdate(triggerOldMap.get(obj.Id), obj);
                    }
                }
            }
        } else {
            // Call the bulk after to handle any caching of data and enable bulkification
            bulkAfter();

            switch on dmlOperation {
                when 'DELETE' {
                    for (SObject obj : triggerOldMap.values()) {
                        afterDelete(obj);
                    }
                }
                when 'INSERT' {
                    for (SObject obj : triggerNew) {
                        afterInsert(obj);
                    }
                }
                when 'UPDATE' {
                    for (SObject obj : triggerNew) {
                        afterUpdate(triggerOldMap.get(obj.Id), obj);
                    }
                }
                when 'UNDELETE' {
                    for (SObject obj : triggerNew) {
                        afterUndelete(obj);
                    }
                }
            }
        }

        // Perform any post processing
        andFinally();
    }

    /**
     * @description Helps you call methods or collect data that you need before the processing of data in a "before" Context
     * Example: Caching of Data Before Insert to supplement the inputs given by your user. (Cache Related Object Data for your new records)
     * @author mindsquare AG
     */
    virtual public void bulkBefore() {
    }

    /**
     * @description Helps you call methods or collect data that you need before the processing of data in an "after" Context
     * Example: Caching of Data After Update to help determine if further Updates on other objects are necessary later on.
     * @author mindsquare AG
     */
    virtual public void bulkAfter() {
    }

    /**
     * @description Called for every single record in a Before Insert Context. Do not use DML or SOQL in here as this will cause failures with bulk data processing.
     * Typecast the parameters into the proper SObject type for proper dot notation.
     * @author mindsquare AG
     * @param  newSObj The current SObject you are checking from Trigger.new. Typecast into the SObject's proper type to use dot notation (rec.field__c)
     */
    virtual public void beforeInsert(SOBject newSObj) {
    }

    /**
     * @description Called for every single record in a Before Insert Context. Do not use DML or SOQL in here as this will cause failures with bulk data processing.
     * Typecast the parameters into the proper SObject type for proper dot notation.
     * @author mindsquare AG
     * @param  oldSObj The current SObject you are checking from Trigger.old. Represents the record before it was updated
     * @param  newSObj The current SObject you are checking from Trigger.new. Represents the record as it will land on the database after the Trigger.
     */
    virtual public void beforeUpdate(SOBject oldSObj, SOBject newSObj) {
    }

    /**
     * @description Called for every single record in a Before Delete Context. Use to throw exceptions for your record, should you not be allowed to delete them.
     * Do not use DML or SOQL in here as this will cause failures with bulk data processing.
     * Typecast the parameters into the proper SObject type for proper dot notation.
     * @author mindsquare AG
     * @param  oldSObj The current record that is iterated over
     */
    virtual public void beforeDelete(SOBject oldSObj) {
    }

    /**
     * @description Called for every single record in an After Insert Conetxt.
     * Do not use DML or SOQL in here as this will cause failures with bulk data processing.
     * @author mindsquare AG
     * @param  newSObj newSObj The newly inserted record (it now has an Id)
     */
    virtual public void afterInsert(SOBject newSObj) {
    }

    /**
     * @description Called for every single record in an After Update Conetxt.
     * Do not use DML or SOQL in here as this will cause failures with bulk data processing.
     * @author mindsquare AG
     * @param  oldSObj oldSObj The record as it was before the database update
     * @param  newSObj newSObj The record as it is on the database now after triggers
     */
    virtual public void afterUpdate(SOBject oldSObj, SOBject newSObj) {
    }

    /**
     * @description Called for every single record in an After Delete Conetxt.
     * Do not use DML or SOQL in here as this will cause failures with bulk data processing.
     * Typecast the parameters into the proper SObject type for proper dot notation.
     * @author mindsquare AG
     * @param  oldSObj Single Deleted record
     */
    virtual public void afterDelete(SOBject oldSObj) {
    }

    /**
     * @description Called for every single record in an After Undelete Conetxt.
     * Do not use DML or SOQL in here as this will cause failures with bulk data processing.
     * Typecast the parameters into the proper SObject type for proper dot notation.
     * @author mindsquare AG
     * @param  oldSObj Single Undeleted record
     */
    virtual public void afterUndelete(SOBject oldSObj) {
    }

    /**
     * @description Used for processing of data collected in record processing
     * Use to commit new records to database or fire updates
     * @author mindsquare AG
     */
    virtual public void andFinally() {
    }
}
