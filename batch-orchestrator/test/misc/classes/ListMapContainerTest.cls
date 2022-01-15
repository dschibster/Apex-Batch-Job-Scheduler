/**
 * This class is part of the sfdx-batch-orchestrator package, released under the MIT license.
 *
 * @description       : Test Class for ListMapContainer
 * @author            : dschibster
 * @group             : Scheduler
 * @last modified on  : 2021-08-27
 * @last modified by  : dschibster
 **/

@IsTest
public with sharing class ListMapContainerTest {
    @IsTest
    static void testTwoContainersWithDifferentSObjectTypes() {
        ListMapContainer mapContact = new ListMapContainer(Contact.SObjectType);
        ListMapContainer mapCase = new ListMapContainer(Case.SObjectType);

        Contact newContact = new Contact(LastName = 'test');
        Contact newContact2 = new Contact(LastName = 'test2');

        mapContact.addToMap(1, newContact);
        mapContact.addToMap(2, newContact2);

        Case cas = new Case(Subject = 'ppatest');
        Case cas2 = new Case(Subject = 'ppa2test2');

        mapCase.addToMap(1, cas);
        mapCase.addToMap(1, cas2);

        List<Contact> contactListTest = new List<Contact>{ newContact };
        List<Contact> contactListTest2 = new List<Contact>{ newContact2 };
        List<Case> caseListTest = new List<Case>{ cas, cas2 };

        System.assertEquals(new Map<Integer, List<Contact>>{ 1 => contactListTest, 2 => contactListTest2 }, mapContact.getMap());
        System.assertEquals(new Map<Integer, List<Case>>{ 1 => caseListTest }, mapCase.getMap());
    }

    @IsTest
    static void testWrongSObjectType() {
        ListMapContainer mapContact = new ListMapContainer(Contact.SObjectType);

        Exception ex;
        try {
            mapContact.addToMap(1, new Account());
        } catch (Exception e) {
            ex = e;
        }

        System.assert(ex != null);
    }

    @IsTest
    static void testMapFunctions() {
        ListMapContainer mapContact = new ListMapContainer(Contact.SObjectType);

        System.assert(!mapContact.containsKey(1));
        System.assertEquals(Contact.SObjectType, mapContact.getSObjectType());

        Contact newCon = new Contact(LastName = 'Test1');
        mapContact.addToMap(1, newCon);

        System.assertEquals(new List<Contact>{ newCon }, mapContact.get(1));
    }
}
