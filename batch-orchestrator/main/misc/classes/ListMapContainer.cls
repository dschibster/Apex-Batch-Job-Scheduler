/**
 * This class is part of the sfdx-batch-orchestrator package, released under the MIT license.
 *
 * @description       : Helper class that encapsulates Map<Integer,List<SObject>> for a generic SObject.
 * @author            : dschibster
 * @group             : Scheduler
 * @last modified on  : 2021-08-27
 * @last modified by  : dschibster
 **/

public class ListMapContainer {
    Map<Integer, List<SObject>> objectMap;
    SObjectType sobjectType;
    String sobjectTypeString;

    public ListMapContainer(SObjectType sobjType) {
        this.sobjectType = sobjType;
        this.sobjectTypeString = sobjType.getDescribe().getName();

        String typedMapString = 'Map<Integer,List<' + sobjectTypeString + '>>';
        Type mapType = Type.forName(typedMapString);
        objectMap = (Map<Integer, List<SObject>>) mapType.newInstance();
    }

    public Map<Integer, List<SObject>> getMap() {
        return this.objectMap;
    }

    public SObjectType getSObjectType() {
        return this.sobjectType;
    }

    public void addToMap(Integer key, SObject sobj) {
        if (sobj.getSObjectType() != this.sobjectType) {
            throw new TypeException('The SObject you wanted to add to this Map is not the one the Map is constructed with');
        }
        if (!objectMap.containsKey(key)) {
            Type listType = Type.forName('List<' + sobjectTypeString + '>');
            List<SObject> objectList = (List<SObject>) listType.newInstance();
            this.objectMap.put(key, objectList);
        }
        this.objectMap.get(key).add(sobj);
    }

    public Boolean containsKey(Integer key) {
        return this.objectMap.containsKey(key);
    }

    public List<SObject> get(Integer key) {
        return this.objectMap.get(key);
    }

    public Set<Integer> keySet() {
        return this.objectMap.keySet();
    }
}
