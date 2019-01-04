/**
 * This class contains unit tests for validating the behavior of Apex class AccountTriggerHandler
 * Chintan Adhyapak, West Monroe Partners. April 18, 2018
 */
@isTest
private class AccountTriggerHandler_Test {
	//Create test data for the class
	@testSetup 
	static void setupData() {
		System.debug('CPA Entering AccountTriggerHandler_Test.setupData');
        
        //Create 2 Relationships
		Account relationshipA = new Account();
		relationshipA.Name = 'Apex Relationship A';
		
		Account relationshipB = new Account();
		relationshipB.Name = 'Apex Relationship B';
		relationshipB.SSO_GUID__c = '{Initial GUID String}';
		
		List<Account> accountList = new List<Account> ();
		accountList.add(relationshipA);
		accountList.add(relationshipB);
		
		insert accountList;
		For (Account account : accountList)
        	System.assertNotEquals(null, account.Id, 'Relationship not created successfully');
        
        //Create 2 Contacts
        Contact contactA = new Contact();
        contactA.FirstName = 'Apex';
        contactA.LastName = 'Contact A';
        contactA.AccountId = relationshipA.Id;
        
        Contact contactB = new Contact();
        contactB.FirstName = 'Apex';
        contactB.LastName = 'Contact B';
        contactB.AccountId = relationshipB.Id;
        
        List<Contact> contactList = new List<Contact> ();
        contactList.add(contactA);
        contactList.add(contactB);
        
        insert contactList;
        For (Contact contact : contactList)
        	System.assertNotEquals(null, contact.Id, 'Contact not created successfully');
        
        //Create 2 Users
        User userA = WMPTestDataFactory.createUser('nCino Community User', false, 'West Monroe1', 'Partners');
        userA.ContactId = contactA.Id;
        User userB = WMPTestDataFactory.createUser('nCino Community User', false, 'West Monroe2', 'Partners');
        userB.ContactId = contactB.Id;
        
        List<User> userList = new List<User> ();
        userList.add(userA);
        userList.add(userB);
        
        insert userList;
        for (User user : userList)
        	System.assertNotEquals(null, user.Id, 'User not created successfully');
		
		System.debug('CPA Exiting AccountTriggerHandler_Test.setupData');
	} //setupData
	


	//Test the populateFederationId method with Federation ID being set from being null earlier
	@isTest
	static void testPopulateFederationId1() {
		System.debug('CPA Entering AccountTriggerHandler_Test.testPopulateFederationId1');
		
		//Retrieve user
        User userA = [Select Id, FederationIdentifier, Name From User Where FirstName = 'West Monroe1'][0];
        System.assertNotEquals(null, userA.Id, 'User A Could not be retrieved successfully');
        System.debug('CPA Retrieved User is: ' + userA);
        
        //Assert
        System.assertEquals(null, userA.FederationIdentifier, 'userA SSO GUID is not null');
        
        Test.startTest();
                
        //Update Account SSO GUID from null to not null
        Account relationshipA = [Select Id, Name, SSO_GUID__c From Account Where Name = 'Apex Relationship A'][0];
        System.assertNotEquals(null, relationshipA.Id, 'Could not retrieve relationshipA');
        relationshipA.SSO_GUID__c = 'Test GUID String}';
        update relationshipA;
        
        Test.stopTest();
                
        //Retrieve user
        userA = [Select Id, FederationIdentifier, Name From User Where FirstName = 'West Monroe1'][0];
        System.assertNotEquals(null, userA.Id, 'UserA Could not be retrieved successfully');
        System.debug('CPA Retrieved User is: ' + userA);
        
        //Assert
        System.assertEquals('Test GUID String', userA.FederationIdentifier, 'userA SSO GUID is not set');
		
		System.debug('CPA Exiting AccountTriggerHandler_Test.testPopulateFederationId1');
	} //testPopulateFederationId1
	
	
	
	//Test the populateFederationId method with Federation ID being modified to another value
	@isTest
	static void testPopulateFederationId2() {
		System.debug('CPA Entering AccountTriggerHandler_Test.testPopulateFederationId2');
		
		//Retrieve user
        User userB = [Select Id, FederationIdentifier, Name From User Where FirstName = 'West Monroe2'][0];
        System.assertNotEquals(null, userB.Id, 'User B Could not be retrieved successfully');
        System.debug('CPA Retrieved User is: ' + userB);
        
        //Assert
        System.assertEquals('Initial GUID String', userB.FederationIdentifier, 'userB SSO GUID is not set correctly');
        
        Test.startTest();
                
        //Update Account SSO GUID from one string to another
        Account relationshipB = [Select Id, Name, SSO_GUID__c From Account Where Name = 'Apex Relationship B'][0];
        System.assertNotEquals(null, relationshipB.Id, 'Could not retrieve relationshipB');
        relationshipB.SSO_GUID__c = '{Modified GUID String}';
        update relationshipB;
        
        Test.stopTest();
                
        //Retrieve user
        userB = [Select Id, FederationIdentifier, Name From User Where FirstName = 'West Monroe2'][0];
        System.assertNotEquals(null, userB.Id, 'UserB Could not be retrieved successfully');
        System.debug('CPA Retrieved User is: ' + userB);
        
        //Assert
        System.assertEquals('Modified GUID String', userB.FederationIdentifier, 'userB SSO GUID was not modifiedsuccessfully');
		
		System.debug('CPA Exiting AccountTriggerHandler_Test.testPopulateFederationId2');
	} //testPopulateFederationId2
	
	
	
	//Test the populateFederationId method with Federation ID being deleted from a previously set value
	@isTest
	static void testPopulateFederationId3() {
		System.debug('CPA Entering AccountTriggerHandler_Test.testPopulateFederationId3');
		
		//Retrieve user
        User userB = [Select Id, FederationIdentifier, Name From User Where FirstName = 'West Monroe2'][0];
        System.assertNotEquals(null, userB.Id, 'User B Could not be retrieved successfully');
        System.debug('CPA Retrieved User is: ' + userB);
        
        //Assert
        System.assertEquals('Initial GUID String', userB.FederationIdentifier, 'userB SSO GUID is not set correctly');
        
        Test.startTest();
                
        //Update Account SSO GUID to set it to null
        Account relationshipB = [Select Id, Name, SSO_GUID__c From Account Where Name = 'Apex Relationship B'][0];
        System.assertNotEquals(null, relationshipB.Id, 'Could not retrieve relationshipB');
        relationshipB.SSO_GUID__c = null;
        update relationshipB;
        
        Test.stopTest();
                
        //Retrieve user
        userB = [Select Id, FederationIdentifier, Name From User Where FirstName = 'West Monroe2'][0];
        System.assertNotEquals(null, userB.Id, 'UserB Could not be retrieved successfully');
        System.debug('CPA Retrieved User is: ' + userB);
        
        //Assert
        System.assertEquals(null, userB.FederationIdentifier, 'userB SSO GUID was not modifiedsuccessfully');
		
		System.debug('CPA Exiting AccountTriggerHandler_Test.testPopulateFederationId3');
	} //testPopulateFederationId3
}