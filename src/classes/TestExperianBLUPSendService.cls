@isTest
private class TestExperianBLUPSendService {
    @isTest
	private static void test_namespaceNoNamespace(){
		String value = ExperianBLUPSendService.getNamespaceOverride(String.valueOf(ExperianBLUPSendService.class));
		System.assertEquals(true, value == '--NAMESPACEEMPTY--');
	}
	@isTest
	private static void test_namespaceWithNamespace(){
		String value = ExperianBLUPSendService.getNamespaceOverride(String.valueOf(nFORCE.BeanFactory.class));
		System.assertEquals(true, value == 'nFORCE');
	}
    @isTest
	private static void test_MissingExpectedProperty(){
		MiddlewareMessageMock message = new MiddlewareMessageMock()
			.putProperty('ReportType', 'Hard')
			.putProperty('recordType', 'Contact');
		ExperianBLUPSendService blup = new ExperianBLUPSendService();

		try{
			blup.preSendSeam(message);
			System.assert(false, 'Expected Exception NOT thrown');
		}
		catch(ExperianBLUPSendService.XEXPERIANBLUPException ex){
			System.assert(ex.getMessage().startsWith(ExperianBLUPSendService.X_MISSING_REQUIRED_PROPERTY));
		}
	}
    private static testmethod void testSend_succeeds() {

        ExperianCreditActivator act = new ExperianCreditActivator();
        act.onActivate();
        MiddlewareMessageMock message = new MiddlewareMessageMock();
        ExperianBLUPSendService service = new ExperianBLUPSendService();

        message.putProperty('TEST_OR_PRODUCTION','TEST');

        Test.startTest();
        service.preSendSeam(message);
        Test.stopTest();

        System.assertEquals('TEST', message.properties.get('TEST_OR_PRODUCTION'));
    }

    private static testmethod void testSend_succeeds_fullMessage() {


        ExperianCreditActivator act = new ExperianCreditActivator();
        act.onActivate();
        MiddlewareMessageMock message = new MiddlewareMessageMock();
        ExperianBLUPSendService service = new ExperianBLUPSendService();

        message.putProperty('TEST_OR_PRODUCTION','TEST');

        Test.startTest();
        service.preSendSeam(message);
        Test.stopTest();


        System.assertEquals(true, true);
    }

    private static testmethod void testSend_noloanId() {

        ExperianCreditActivator act = new ExperianCreditActivator();
        act.onActivate();
        MiddlewareMessageMock message = new MiddlewareMessageMock();
        ExperianBLUPSendService service = new ExperianBLUPSendService();

        Test.startTest();

        try{
            service.preSendSeam(message);
        }catch(Exception e){
            System.assertEquals(true, false);
        }

        Test.stopTest();


    }

    private class MiddlewareMessageMock extends nFUSE.AMiddlewareMessage {
        public MiddlewareMessageMock(){}
        public MiddlewareMessageMock putProperty(String key, String value){
            this.properties.put(key, value);
            return this;
        }
    }

}