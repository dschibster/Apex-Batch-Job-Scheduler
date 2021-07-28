public class ListMapContainer {

    Map<String, List<SObject>> objectMap;
    SObjectType sobjectType;
    String sobjectTypeString;

    public ListMapContainer(SObjectType sobjType) {
        this.sobjectType = sobjType;
        this.sobjectTypeString = sobjType.getDescribe().getName();

        String typedMapString = 'Map<String,List<' + sobjectTypeString + '>>';
        Type mapType = Type.forName(typedMapString);
        objectMap = (Map<String, List<SObject>>) mapType.newInstance();

    }

    public Map<String, List<SObject>> getMap() {
        return this.objectMap;
    }

    public SObjectType getSObjectType() {
        return this.sobjectType;
    }

    public void addToMap(String key, SObject sobj) {
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

    public Boolean containsKey(String key) {
        return this.objectMap.containsKey(key);
    }

    public List<SObject> get(String key) {
        return this.objectMap.get(key);
    }

    public Set<String> keySet() {
        return this.objectMap.keySet();
    }
}
