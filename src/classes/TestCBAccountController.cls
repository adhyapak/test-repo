@isTest
public with sharing class TestCBAccountController {

    static Account createAccount() {
		Account testAccount = new Account(Name = 'My test account', AccountNumber = '1234');
		insert testAccount;
		return testAccount;
	}
	
	
	
	private static String accountId;
    
    @isTest
    static void setupData() {
        
        accountId = createAccount().Id;
        
        nFUSE.PackageServiceRequest servRequest = new nFUSE.PackageServiceRequest(
			CBConfiguration.PLUGIN_NAME, CBConfiguration.PLUGIN_VERSION, null);
		nFUSE.ServiceLocator locator = new nFUSE.ServiceLocator();
		locator.register(servRequest, nFUSE.SendService.class, nFUSE.TestServices.SendServiceMock.class, CBConfiguration.CUSTOMERSENDSERVICENAME);
        
        
    }

    @isTest
    private static void testWithStandardController(){
        Account a = new Account(Name='test');
    	insert a;
        CBAccountController c = new CBAccountController(new ApexPages.StandardController(a));
        system.assertEquals(true,true);
    }
    
    @isTest
    private static void testBookCustomer(){
        new nFUSE.DataInstaller().onInstall(null);
        
        setupData();
        test.startTest();
        CBAccountController.forceTestingException = false;
        CBEntities.CoreBookingResponse response = CBAccountController.bookCustomer(accountId);
        system.assertEquals(true,response.IsSuccessful);
        test.stopTest();
    }
    
    @isTest
    private static void testBookCustomerFails(){
        setupData();
        test.startTest();
        CBAccountController.forceTestingException = true;
        CBEntities.CoreBookingResponse response = CBAccountController.bookCustomer(accountId);
        system.assertEquals(false,response.IsSuccessful);
        test.stopTest();
    }
    
    
    @isTest
    private static void testBookCustomerNotComplete(){
        
        String accountId = createAccount().Id;
        
        nFUSE__Transaction_Log__c log = new nFUSE__Transaction_Log__c(Name='TestLog',nFUSE__External_Id__c='123123123'); //possible namespace issue
        log.nFUSE__Action__c = 'new';
        log.nFUSE__Api_Version__c = '1';
        log.nFUSE__App_Plugin__c = 'CoreBooking';
        log.nFUSE__Primary_Object_Id__c = accountId;
        log.nFUSE__Requested_By_User_Id__c = 'user';
        log.nFUSE__Transaction_Status__c = 'notcomplete';
        log.nFUSE__External_Id__c = 'test';
        insert log;
        
        String externalId = log.nFUSE__External_Id__c;
        
        test.startTest();
        CBEntities.TransactionLogResponse response = CBAccountController.getTransactionStatus(externalId);
        system.assertEquals(false,response.IsComplete);
        test.stopTest();
    }
    
    @isTest
    private static void testBookCustomerComplete(){
        
        String accountId = createAccount().Id;
        
        nFUSE__Transaction_Log__c log = new nFUSE__Transaction_Log__c(Name='TestLog',nFUSE__External_Id__c='123123123'); //possible namespace issue
        log.nFUSE__Action__c = 'new';
        log.nFUSE__Api_Version__c = '1';
        log.nFUSE__App_Plugin__c = 'CoreBooking';
        log.nFUSE__Primary_Object_Id__c = accountId;
        log.nFUSE__Requested_By_User_Id__c = 'user';
        log.nFUSE__Transaction_Status__c = 'eRRor';
        log.nFUSE__External_Id__c = 'test';
        insert log;
        
        String externalId = log.nFUSE__External_Id__c;
        
        test.startTest();
        CBEntities.TransactionLogResponse response = CBAccountController.getTransactionStatus(externalId);
        system.assertEquals(true,response.IsComplete);
        test.stopTest();
    }
    
    
}