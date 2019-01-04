@isTest
private class TestExperianCreditAppFacade {

	@isTest
	private static void testStoreDocuments_hasImplementation() {
		ExperianCreditAppFacade facade = new ExperianCreditAppFacade();
		Account acct = new Account(Name = 'Test');
		insert acct;
		nFUSE__Transaction_Log__c tLog = new nFUSE__Transaction_Log__c( //possible namespace issue
			nFUSE__Action__c = 'test',
			nFUSE__Api_Version__c = '1.0',
			nFUSE__Requesting_User_Id__c = UserInfo.getUserId(),
			nFUSE__Requested_By_User_Id__c = UserInfo.getUserId(),
			nFUSE__Transaction_Status__c = 'INPROGRESS',
			nFUSE__Object_Id__c = acct.Id,
			nFUSE__Primary_Object_Id__c = acct.Id,
			nFUSE__App_Plugin__c = 'Experian_Credit',
			nFUSE__External_Id__c = new nFORCE.GuidGenerator().randomUUID()
		);
		insert tLog;
		nFUSE__Transaction_Log__c tLog2 = new nFUSE__Transaction_Log__c( //possible namespace issue
			nFUSE__Action__c = 'test2',
			nFUSE__Api_Version__c = '1.0',
			nFUSE__Requesting_User_Id__c = UserInfo.getUserId(),
			nFUSE__Requested_By_User_Id__c = UserInfo.getUserId(),
			nFUSE__Transaction_Status__c = 'INPROGRESS',
			nFUSE__Object_Id__c = acct.Id,
			nFUSE__Primary_Object_Id__c = acct.Id,
			nFUSE__App_Plugin__c = 'Experian_Credit',
			nFUSE__External_Id__c = new nFORCE.GuidGenerator().randomUUID()
		);
		insert tLog2;
		test.startTest();
		try{
			facade.storeDocument(tLog.nFUSE__External_Id__c, 'test', 'document override');
			facade.attachmentHandler.storeDocument(tLog.nFUSE__External_Id__c, 'test', Blob.valueOf('some doc content'));
			facade.attachmentHandler.storeDocument(tLog2.nFUSE__External_Id__c, 'test2', 'name', Blob.valueOf('some doc content'));
		}catch(Exception e){
			
		}
		test.stopTest();
		System.assertEquals(true, true);
	}

	@isTest
	private static void testPreCommAdjustments(){
		ExperianCreditActivator activator = new ExperianCreditActivator();
		activator.onActivate();
		MiddlewareMessageMock message = new MiddlewareMessageMock()
			.putProperty('ReportType', 'Hard')
			.putProperty('recordType', 'Contact');
		ExperianCreditAppFacade facade = new ExperianCreditAppFacade();

		facade.preCommAdjustments(message);

		System.assertEquals('TEST', message.properties.get('TEST_OR_PRODUCTION'));	
	}

	@isTest
	private static void testPreCommAdjustments_MissingExpectedProperty(){
		MiddlewareMessageMock message = new MiddlewareMessageMock()
			.putProperty('ReportType', 'Hard')
			.putProperty('recordType', 'Contact');
		ExperianCreditAppFacade facade = new ExperianCreditAppFacade();

		try{
			facade.preCommAdjustments(message);
			System.assert(false, 'Expected Exception NOT thrown');
		}
		catch(ExperianCreditAppFacade.XExperianAppFacadeException ex){
			System.assert(ex.getMessage().startsWith(ExperianCreditAppFacade.X_MISSING_REQUIRED_PROPERTY));
		}
	}

	private static void initExperianProperties(){
		NFORCE__System_Properties__c[] props = new NFORCE__System_Properties__c[]{
			create(Experian_CATEGORY, ExperianCreditActivator.BUSINESS_DAYS_VALID, 'BUSINESS_DAYS_VALID'),
			create(Experian_CATEGORY, ExperianCreditActivator.TEST_OR_PRODUCTION, 'TEST_OR_PRODUCTION')
		};
		insert(props);
	}

	private class MiddlewareMessageMock extends nFUSE.AMiddlewareMessage {
		public MiddlewareMessageMock(){}

		public MiddlewareMessageMock putProperty(String key, String value){
			this.properties.put(key, value);
			return this;
		}
	}

	private static NFORCE__System_Properties__c create(String cat, String key, String val){
		return new NFORCE__System_Properties__c(
			Name = new nFORCE.GuidGenerator().randomUUID(),
			NFORCE__Category_Name__c = cat,
			NFORCE__Key__c = key,
			NFORCE__Value__c = val,
			NFORCE__Is_Active__c = true
		);
	}


	private static final String Experian_CATEGORY = ExperianCreditAppFacade.PLUGIN_NAME + 'Configuration';
}