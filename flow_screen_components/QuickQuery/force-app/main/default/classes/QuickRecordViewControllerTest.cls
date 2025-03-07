@isTest
public with sharing class QuickRecordViewControllerTest {
    @testSetup
    static void setup(){
        insert new Case(Origin = 'Web', Status = 'New');
        insert new List<FlowTableViewDefinition__c>{
                                            new FlowTableViewDefinition__c(
                                                Field_API_Names__c = 'FirstName,LastName,Email',
                                                Object_API_Name__c = 'Contact',
                                                View_Name__c = 'Contact'),
                                            new FlowTableViewDefinition__c(
                                                Field_API_Names__c = 'CaseNumber,Status',
                                                Object_API_Name__c = 'Case',
                                                View_Name__c = 'Case'),
                                            new FlowTableViewDefinition__c( 
                                                Field_API_Names__c = 'Owner, LastActivity,Amout,Stage',
                                                Object_API_Name__c = 'Opportunity',
                                                View_Name__c = 'Opportunity'),
                                            new FlowTableViewDefinition__c(
                                                Field_API_Names__c = 'Name,Site,Rating',
                                                Object_API_Name__c = 'Account',
                                                View_Name__c = 'Account1'),
                                            new FlowTableViewDefinition__c(
                                                Field_API_Names__c = 'Name,Site,Rating',
                                                Object_API_Name__c = 'Account',
                                                View_Name__c = 'Account2'),
                                            new FlowTableViewDefinition__c(  
                                                Field_API_Names__c = 'FirstName,LastName,Email',
                                                Object_API_Name__c = 'OrderItem',
                                                View_Name__c = 'OrderItem')
        };
    }

    // Default behavior: when a change is made to the object name specified in the object lookup,
    // attempt to retrieve any QuickRecordView that have a matching object name. If more than 1 result comes back, 
    // thrown an error. If zero results come back, define a virtual QuickRecordView that uses as its columns Name, Owner, Create Date. 
    // The idea here is that any custom object should work, even if a view record doesn’t exist.

    // {"type": "text","fieldName": "FirstName", "label": "First Name"}
    // {"type": "text","fieldName": "LastName","label": "Last Name"}
    // {"type": "text","fieldName": "Email", "label": "Email"} 

    // Retrieve any QuickRecordView that have a matching object name
    @isTest
    static void testMatchingObjectName() {
        List<String> type = new List<String>{'text','text','text'};
        List<String> fieldName = new List<String>{'FirstName','LastName','Email'};
        List<String> label = new List<String>{'First Name','Last Name','Email'};
        FlowTableViewDefinition__c  flowDef = [
            SELECT  Id, 
                    Name, 
                    View_Name__c 
            FROM    FlowTableViewDefinition__c 
            WHERE   Object_API_Name__c = 'Contact'
            LIMIT   1
        ];

        List <FilterObjectRepresentation> contactFilter = QuickRecordViewController.searchFilterFileds(flowDef.Id, 'Contact');
        for (FilterObjectRepresentation contactFilterIterator : contactFilter){
            System.assert(fieldName.contains(contactFilterIterator.fieldName));
            System.assert(label.contains(contactFilterIterator.label));
            System.assert(type.contains(contactFilterIterator.type));
        }
    }

    // If input is null. 
    @isTest
    static void testNoObjectName() {

        List <FilterObjectRepresentation> contactFilter = QuickRecordViewController.searchFilterFileds(null, 'Account');

        System.assert(contactFilter.size() > 0);
    }

    // If zero results come back, define a virtual QuickRecordView that uses as its columns Name, Owner, Create Date. 
    // {"type": "text","fieldName": "Name","label": "Name"}, 
    // {"type": "datetime","fieldName": "CreatedDate","label": "Created Date"}, 
    // {"type": "text","fieldName": "Owner","label": "Owner"} 

    @isTest
    static void testDefaultBehaviourObjectName() {
        List<String> type = new List<String>{'text','datetime','text'};
        List<String> fieldName = new List<String>{'OwnerId','CreatedDate','Name'};
        List<String> label = new List<String>{'Owner','Created Date','Name'};

        List <FilterObjectRepresentation> contactFilter = QuickRecordViewController.searchFilterFileds('', 'Account');


        for (FilterObjectRepresentation contactFilterIterator : contactFilter){
            System.assert(fieldName.contains(contactFilterIterator.fieldName));
            System.assert(label.contains(contactFilterIterator.label));
            System.assert(type.contains(contactFilterIterator.type));
        }
    }


    // Convert operator testing. LWC component use text representation of operators like = - 'equal'
    @isTest
    static void testOperatorConverter() {
        Map<String, String> salesforceOperatorLWCComponentOperator = new Map<String, String>{   
                                                                                                'equals' => '=',
                                                                                                'not_equal_to' => '!=',
                                                                                                'greater_then' => '>',
                                                                                                'greater_or_equal' => '>=',
                                                                                                'less_then' => '<',
                                                                                                'less_or_equal' => '<=',
                                                                                                'contains' => 'IN',
                                                                                                'starts_with' => 'starts_with',
                                                                                                'end_with' => 'end_with'
                                                                                             };
        
        for (String key : salesforceOperatorLWCComponentOperator.keySet()){
            System.assertEquals(salesforceOperatorLWCComponentOperator.get(key), QuickRecordViewController.operatorConverter(key));
        }
        
        System.assertEquals(null, QuickRecordViewController.operatorConverter('Anything what is not operator return null.'));
    }

     // Convert operator testing. LWC component use text representation of operators like = - 'equal'
     @isTest
     static void testGetRecordDataString() {
         Account accnt = new Account(Name = 'TestAccount');
         insert accnt;
         String viewId = QuickRecordViewController.upsertView('', 'Test View Name', 'Account', new List<String>{'Name', 'CreatedDate', 'OwnerId'});
         String serializedString = JSON.serialize(QuickRecordViewController.getRecordDataString(viewId, '', 'Account'));
         System.debug('serializedString' + serializedString);

         System.assert(String.isNotEmpty(serializedString));
     }

    @isTest
    static void testPlaceQueryContainsTwoElement() {
        FilterObjectRepresentation filter = new FilterObjectRepresentation();
        filter.fieldName = 'Status';
        filter.label = 'Status';
        filter.operator = 'contains';
        filter.type = 'text';
        filter.value = 'New, Working';
        String response = QuickRecordViewController.placeQuery(JSON.serialize(new List<FilterObjectRepresentation>{filter}), 'Case');
        System.assertEquals('WHERE Status  LIKE  \'%New, Working%\'', response); 
    }

    @isTest
    static void testPlaceQueryStartWith() {
        FilterObjectRepresentation filter = new FilterObjectRepresentation();
        filter.fieldName = 'Status';
        filter.label = 'Status';
        filter.operator = 'starts_with';
        filter.type = 'text';
        filter.value = 'N';
        String response = QuickRecordViewController.placeQuery(JSON.serialize(new List<FilterObjectRepresentation>{filter}), 'Case');
        System.assertEquals('WHERE Status  LIKE \'N%\'', response); 
    }

    @isTest
    static void testPlaceQueryEndWith() {
        FilterObjectRepresentation filter = new FilterObjectRepresentation();
        filter.fieldName = 'Status';
        filter.label = 'Status';
        filter.operator = 'end_with';
        filter.type = 'text';
        filter.value = 'w';
        String response = QuickRecordViewController.placeQuery(JSON.serialize(new List<FilterObjectRepresentation>{filter}), 'Case');
        System.assertEquals('WHERE Status  LIKE \'%w\'', response); 
    }

    @isTest
    static void testUsertView() {
        Account accnt = new Account(Name = 'TestAccount');
        insert accnt;
        String viewId = QuickRecordViewController.upsertView('', 'Test View Name', 'Account', new List<String>{'Name', 'CreatedDate', 'OwnerId'});
        FlowTableViewDefinition__c  flowDef = [
            SELECT  Id, 
                    Name, 
                    View_Name__c 
            FROM    FlowTableViewDefinition__c 
            WHERE   Id = :viewId
            LIMIT   1
        ];

        System.assertEquals(flowDef.View_Name__c, 'Test View Name');
        viewId = QuickRecordViewController.upsertView(viewId, 'Test View Name2', 'Account', new List<String>{'Name', 'CreatedDate', 'OwnerId'});

        System.assertEquals(viewId, flowDef.Id);

        flowDef = [
            SELECT  Id, 
                    Name, 
                    View_Name__c 
            FROM    FlowTableViewDefinition__c 
            WHERE   Id = :viewId
            LIMIT   1
        ];

        System.assertEquals(flowDef.View_Name__c, 'Test View Name2');
    }

    @isTest
    static void tesGetFlowTableViewDefinition() {
        List<Map<String, String>> flowDefMap =  QuickRecordViewController.getFlowTableViewDefinition('Account');

        System.assert(flowDefMap.size() == 2);

        //for object that Flow Table View Definition record isn't existing
        flowDefMap =  QuickRecordViewController.getFlowTableViewDefinition('Lead');
        System.assert(flowDefMap.size() == 1);
    }
}