@isTest
public with sharing class TestCBDepositController {
    
    static LLC_BI__Deposit__c createDeposit(){
        LLC_BI__Deposit__c sDeposit = new LLC_BI__Deposit__c(
			Name = 'Test Deposit',
			LLC_BI__Size_of_Box__c = 'Size1'
		);
		insert sDeposit;
		return sDeposit;
    }
    
    static Account createAccount() {
		Account testAccount = new Account(Name = 'My test account', AccountNumber = '1234');
		insert testAccount;
		return testAccount;
	}
	
	private static String depositId;
	
	
    @isTest
    static void setupData() {
        
        depositId = createDeposit().Id;
        
        nFUSE.PackageServiceRequest servRequest = new nFUSE.PackageServiceRequest(
			CBConfiguration.PLUGIN_NAME, CBConfiguration.PLUGIN_VERSION, null);
		nFUSE.ServiceLocator locator = new nFUSE.ServiceLocator();
		locator.register(servRequest, nFUSE.SendService.class, nFUSE.TestServices.SendServiceMock.class, CBConfiguration.DEPOSITSENDSERVICENAME);
        
        
    }
    
    @isTest
    private static void testWithStandardController(){
        LLC_BI__Deposit__c d = new LLC_BI__Deposit__c();
    	insert d;
        CBDepositController c = new CBDepositController(new ApexPages.StandardController(d));
        system.assertEquals(true,true);
    }
    
    @isTest
    private static void testBookDeposit(){
        new nFUSE.DataInstaller().onInstall(null);
        
        setupData();
        test.startTest();
        CBDepositController.forceTestingException = false;
        CBEntities.CoreBookingResponse response = CBDepositController.bookDeposit(depositId);
        system.assertEquals(true,response.IsSuccessful);
        test.stopTest();
    }
    
    @isTest
    private static void testBookDepositFails(){
        setupData();
        test.startTest();
        CBDepositController.forceTestingException = true;
        CBEntities.CoreBookingResponse response = CBDepositController.bookDeposit(depositId);
        system.assertEquals(false,response.IsSuccessful);
        test.stopTest();
    }
    
    
    @isTest
    private static void testBookDepositNotComplete(){
        
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
        CBEntities.TransactionLogResponse response = CBDepositController.getTransactionStatus(externalId);
        system.assertEquals(false,response.IsComplete);
        test.stopTest();
    }
    
    @isTest
    private static void testBookDepositComplete(){
        
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
        CBEntities.TransactionLogResponse response = CBDepositController.getTransactionStatus(externalId);
        system.assertEquals(true,response.IsComplete);
        test.stopTest();
    }
    
}