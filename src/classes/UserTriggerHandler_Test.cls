/**
 * This class tests the trigger on the User object
 * Chintan Adhyapak, West Monroe Partners. September 12, 2018
 */
@isTest
private class UserTriggerHandler_Test {
	//Create test data for the class
	@testSetup static void setupData() {
		System.debug('CPA Entering UserTriggerHandler_Test.setupData');
        
        //Create a Relationship
		Account relationshipA = new Account();
		relationshipA.Name = 'Apex Relationship A';
        relationshipA.SSO_GUID__c = '{d272a619-831c-4dfc-8457-6e856e1811}';
		insert relationshipA;
        System.assertNotEquals(null, relationshipA.Id, 'Relationship A not created successfully');
        
        //Create a Contact
        Contact contactA = new Contact();
        contactA.FirstName = 'Apex';
        contactA.LastName = 'Contact A';
        contactA.AccountId = relationshipA.Id;
        insert contactA;
        System.assertNotEquals(null, contactA.Id, 'Contact A not created successfully');
        
        //Create a User
        User userA = WMPTestDataFactory.createUser('nCino Community User', false, 'Apex', 'TestUserA');
        userA.ContactId = contactA.Id;
        insert userA;
        System.assertNotEquals(null, userA.Id, 'User A not created successfully');
        
        System.debug('CPA Exiting UserTriggerHandler_Test.setupData');
    } //setupData
    
    
    
    /* Test the populateFederationID method */
    @isTest 
    static void testPopulateFederationID() {
        System.debug('CPA Entering UserTriggerHandler_Test.testPopulateFederationID');
        
        //Retrieve user
        User userA = [Select Id, FederationIdentifier, Name From User Where FirstName = 'Apex' And LastName = 'TestUserA'][0];
        System.assertNotEquals(null, userA.Id, 'User A Could not be retreieved successfully');
        System.debug('CPA Retrieved User is: ' + userA);
        
        //Assert
        System.assertEquals('d272a619-831c-4dfc-8457-6e856e1811', userA.FederationIdentifier, 'userA SSO GUID not populated successfully');
        
        System.debug('CPA Exiting UserTriggerHandler_Test.testPopulateFederationID');
    } //testPopulateFederationID
}