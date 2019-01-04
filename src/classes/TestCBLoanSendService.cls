@isTest
private class TestCBLoanSendService{
    
    public class TestMsg extends nFUSE.AMiddlewareMessage {
    	
    	public TestMsg(){
    		this.messageHeader.action = CBConfiguration.LOANBOOKACTION;
    	}
    	
    	public override String toMsg(){
            String serializedMessage = null;
            
            serializedMessage = 'loan=123'; //NOTE: custom serialization goes here
            
            return serializedMessage;
        }
    }
    
    @isTest
	private static void testMiddlwareMessage() {
	    
	    
	    new CBActivator().onActivate();
	    
	    String response = 'loan=123';
	    
	    CBConfiguration config = new CBConfiguration();
	    
	    Map<String,String> properties = config.GetAllProperties(true);
	    
	    TestMsg message = new TestMsg();
	    
	    message.messageHeader.action = CBConfiguration.LOANBOOKACTION;
		message.properties.put('loan', '123');
		
		CBLoanSendService sendService = new CBLoanSendService();
		sendService.preSendSeam(message);
		
		System.assertEquals(response, message.toMsg());

	}
	
	@isTest
	private static void testMiddlwareMessageWithAdditionalProperties() {
	    
	    
	    new CBActivator().onActivate();
	    
	    nFORCE__System_Properties__c property1 = new nFORCE__System_Properties__c(Name='aaaa',nFORCE__Category_Name__c='CoreBookingConfiguration',nFORCE__Is_Active__c=true);
        property1.nFORCE__Key__c = 'this is another property';
        property1.nFORCE__Value__c = 'this is another property values';
        insert property1;
	    
	    String response = 'loan=123';
	    
	    CBConfiguration config = new CBConfiguration();
	    
	    Map<String,String> properties = config.GetAllProperties(true);
	    
	    TestMsg message = new TestMsg();
	    
	    message.messageHeader.action = CBConfiguration.LOANBOOKACTION;
		message.properties.put('loan', '123');
		
		CBLoanSendService sendService = new CBLoanSendService();
		sendService.preSendSeam(message);
		
		System.assertEquals(response, message.toMsg());

	}
	
	@isTest
	private static void testMiddlwareMessageWithOverrideSessionId() {
	    
	    
	    new CBActivator().onActivate();
	    
	    nFORCE__System_Properties__c property1 = new nFORCE__System_Properties__c(Name='aaaa',nFORCE__Category_Name__c='CoreBookingConfiguration',nFORCE__Is_Active__c=true);
        property1.nFORCE__Key__c = 'this is another property';
        property1.nFORCE__Value__c = 'this is another property values';
        insert property1;
	    
	    String response = 'loan=123';
	    
	    CBConfiguration config = new CBConfiguration();
	    
	    Map<String,String> properties = config.GetAllProperties(true);
	    
	    TestMsg message = new TestMsg();
	    
	    message.messageHeader.action = CBConfiguration.LOANBOOKACTION;
		message.properties.put('loan', '123');
		message.properties.put('salesforce_session_id', 'this is a custom sessionid');
		
		CBLoanSendService sendService = new CBLoanSendService();
		sendService.preSendSeam(message);
		
		System.assertEquals(response, message.toMsg());

	}
	
	@isTest
	private static void testPreProcessSeamDoesNotSetAuthorizationWhenNotBasic() {
        
        CBConfiguration config = new CBConfiguration();
	    
        nFORCE__System_Properties__c property1 = new nFORCE__System_Properties__c(Name='aaaa',nFORCE__Category_Name__c='CoreBookingConfiguration',nFORCE__Is_Active__c=true);
        property1.nFORCE__Key__c = System.Label.AUTHENTICATION_TYPE;
        property1.nFORCE__Value__c = 'cheese';
        insert property1;
        
        nFORCE__System_Properties__c property2 = new nFORCE__System_Properties__c(Name='bbbb',nFORCE__Category_Name__c='CoreBookingConfiguration',nFORCE__Is_Active__c=true);
        property2.nFORCE__Key__c = System.Label.LOAN_ONBOARDING_URL;
        property2.nFORCE__Value__c = 'http://www.google.com';
        insert property2;
        
        nFORCE__System_Properties__c property3 = new nFORCE__System_Properties__c(Name='cccc',nFORCE__Category_Name__c='CoreBookingConfiguration',nFORCE__Is_Active__c=true);
        property3.nFORCE__Key__c = System.Label.BASIC_AUTH_USERNAME;
        property3.nFORCE__Value__c = '';
        insert property3;
        
        nFORCE__System_Properties__c property4 = new nFORCE__System_Properties__c(Name='dddd',nFORCE__Category_Name__c='CoreBookingConfiguration',nFORCE__Is_Active__c=true);
        property4.nFORCE__Key__c = System.Label.BASIC_AUTH_PASSWORD;
        property4.nFORCE__Value__c = '';
        insert property4;
        
        nFORCE__System_Properties__c property5 = new nFORCE__System_Properties__c(Name='eeee',nFORCE__Category_Name__c='CoreBookingConfiguration',nFORCE__Is_Active__c=true);
        property5.nFORCE__Key__c = System.Label.CLIENT_CERTIFICATE_NAME;
        //Chintan Adhyapak, West Monroe Partners. 4/22/2018
        if ([SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox)
        	property5.nFORCE__Value__c = 'blos_sandbox';
        else
        	property5.nFORCE__Value__c = 'SelfSignedCert_30Nov2017_160337';
        insert property5;
        
	    System.assertEquals('Core Booking Endpoint Authentication Type', System.Label.AUTHENTICATION_TYPE);
	    
	    //System.debug(config.GetAllProperties(true));
	    
	    String translatedKey = config.GetTranslatedKey(System.Label.AUTHENTICATION_TYPE);
	    
	    System.assertEquals('cheese', config.GetPropertyByKey(translatedKey));
	    
        String outputmessage = 'loan=123';

        TestMsg message = new TestMsg();
        message.httpresponse = new HttpResponse();
		message.httpResponse.setBody(outputmessage);
		message.properties.put('loan', '123');

        HttpRequest req = new HttpRequest();

		CBLoanSendService sendService = new CBLoanSendService();
		
		try {
			Object container = sendService.preSendRequest(req,message);
		  	System.assertEquals(true, true);
		} catch(Exception e) {
			System.debug('CPA Exception caught: ' + e.getMessage());
			System.assertEquals(true, false);
		}
		
	}

	@isTest
	private static void testPostSendSeam() {
        
        String outputmessage = 'loan=123';

        TestMsg message = new TestMsg();
        message.httpresponse = new HttpResponse();
		message.httpResponse.setBody(outputmessage);
		message.properties.put('loan', '123');

		CBLoanSendService sendService = new CBLoanSendService();
		sendService.postSendSeam(message);

        System.assertEquals(outputmessage, message.toMsg());
        
	}
	
	@isTest
	private static void testPreProcessSeam() {
        
        CBConfiguration config = new CBConfiguration();
	    
        nFORCE__System_Properties__c property1 = new nFORCE__System_Properties__c(Name='aaaa',nFORCE__Category_Name__c='CoreBookingConfiguration',nFORCE__Is_Active__c=true);
        property1.nFORCE__Key__c = System.Label.AUTHENTICATION_TYPE;
        property1.nFORCE__Value__c = 'Basic';
        insert property1;
        
        nFORCE__System_Properties__c property2 = new nFORCE__System_Properties__c(Name='bbbb',nFORCE__Category_Name__c='CoreBookingConfiguration',nFORCE__Is_Active__c=true);
        property2.nFORCE__Key__c = System.Label.LOAN_ONBOARDING_URL;
        property2.nFORCE__Value__c = 'http://www.google.com';
        insert property2;
        
        nFORCE__System_Properties__c property3 = new nFORCE__System_Properties__c(Name='cccc',nFORCE__Category_Name__c='CoreBookingConfiguration',nFORCE__Is_Active__c=true);
        property3.nFORCE__Key__c = System.Label.BASIC_AUTH_USERNAME;
        property3.nFORCE__Value__c = 'Basic';
        insert property3;
        
        nFORCE__System_Properties__c property4 = new nFORCE__System_Properties__c(Name='dddd',nFORCE__Category_Name__c='CoreBookingConfiguration',nFORCE__Is_Active__c=true);
        property4.nFORCE__Key__c = System.Label.BASIC_AUTH_PASSWORD;
        property4.nFORCE__Value__c = 'Basic';
        insert property4;
        
        nFORCE__System_Properties__c property5 = new nFORCE__System_Properties__c(Name='eeee',nFORCE__Category_Name__c='CoreBookingConfiguration',nFORCE__Is_Active__c=true);
        property5.nFORCE__Key__c = System.Label.CLIENT_CERTIFICATE_NAME;
        //Chintan Adhyapak, West Monroe Partners. 4/22/2018
        if ([SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox)
        	property5.nFORCE__Value__c = 'blos_sandbox';
        else
        	property5.nFORCE__Value__c = 'SelfSignedCert_30Nov2017_160337';
        insert property5;
        
        
	    
	    System.assertEquals('Core Booking Endpoint Authentication Type', System.Label.AUTHENTICATION_TYPE);
	    
	    //System.debug(config.GetAllProperties(true));
	    
	    String translatedKey = config.GetTranslatedKey(System.Label.AUTHENTICATION_TYPE);
	    
	    System.assertEquals('Basic', config.GetPropertyByKey(translatedKey));
	    
        String outputmessage = 'loan=123';

        TestMsg message = new TestMsg();
        message.httpresponse = new HttpResponse();
		message.httpResponse.setBody(outputmessage);
		message.properties.put('loan', '123');

        HttpRequest req = new HttpRequest();

		CBLoanSendService sendService = new CBLoanSendService();
		Object container = sendService.preSendRequest(req,message);
		
// 		if(container instanceof HttpRequest){
// 			System.assertEquals(CBConfiguration.ActionEndpoints.get(message.messageHeader.action), ((HttpRequest)container).getEndpoint());
// 		}else{
// 			System.assertEquals(false, true);
// 		}

        System.assertEquals(outputmessage, message.toMsg());
        
	}
	
	@isTest
	private static void testPreProcessSeamErrorsOnEndpointBlank() {
        
        CBConfiguration config = new CBConfiguration();
	    
        nFORCE__System_Properties__c property1 = new nFORCE__System_Properties__c(Name='aaaa',nFORCE__Category_Name__c='CoreBookingConfiguration',nFORCE__Is_Active__c=true);
        property1.nFORCE__Key__c = System.Label.AUTHENTICATION_TYPE;
        property1.nFORCE__Value__c = 'Basic';
        insert property1;
        
        nFORCE__System_Properties__c property2 = new nFORCE__System_Properties__c(Name='bbbb',nFORCE__Category_Name__c='CoreBookingConfiguration',nFORCE__Is_Active__c=true);
        property2.nFORCE__Key__c = System.Label.LOAN_ONBOARDING_URL;
        property2.nFORCE__Value__c = '';
        insert property2;
        
        nFORCE__System_Properties__c property3 = new nFORCE__System_Properties__c(Name='cccc',nFORCE__Category_Name__c='CoreBookingConfiguration',nFORCE__Is_Active__c=true);
        property3.nFORCE__Key__c = System.Label.BASIC_AUTH_USERNAME;
        property3.nFORCE__Value__c = 'Basic';
        insert property3;
        
        nFORCE__System_Properties__c property4 = new nFORCE__System_Properties__c(Name='dddd',nFORCE__Category_Name__c='CoreBookingConfiguration',nFORCE__Is_Active__c=true);
        property4.nFORCE__Key__c = System.Label.BASIC_AUTH_PASSWORD;
        property4.nFORCE__Value__c = 'Basic';
        insert property4;
        
        
	    
	    System.assertEquals('Core Booking Endpoint Authentication Type', System.Label.AUTHENTICATION_TYPE);
	    
	    //System.debug(config.GetAllProperties(true));
	    
	    String translatedKey = config.GetTranslatedKey(System.Label.AUTHENTICATION_TYPE);
	    
	    System.assertEquals('Basic', config.GetPropertyByKey(translatedKey));
	    
        String outputmessage = 'loan=123';

        TestMsg message = new TestMsg();
        message.httpresponse = new HttpResponse();
		message.httpResponse.setBody(outputmessage);
		message.properties.put('loan', '123');

        HttpRequest req = new HttpRequest();

		CBLoanSendService sendService = new CBLoanSendService();
		
		try{
			Object container = sendService.preSendRequest(req,message);
		  	System.assertEquals(true, false);
		}catch(Exception e){
			System.assertEquals('Functionality requires the "Loan Booking Url" to be filled in.', e.getMessage());
		}
		
	}
	
	@isTest
	private static void testPreProcessSeamErrorsOnBasicAuthKeysBlank() {
        
        CBConfiguration config = new CBConfiguration();
	    
        nFORCE__System_Properties__c property1 = new nFORCE__System_Properties__c(Name='aaaa',nFORCE__Category_Name__c='CoreBookingConfiguration',nFORCE__Is_Active__c=true);
        property1.nFORCE__Key__c = System.Label.AUTHENTICATION_TYPE;
        property1.nFORCE__Value__c = 'Basic';
        insert property1;
        
        nFORCE__System_Properties__c property2 = new nFORCE__System_Properties__c(Name='bbbb',nFORCE__Category_Name__c='CoreBookingConfiguration',nFORCE__Is_Active__c=true);
        property2.nFORCE__Key__c = System.Label.LOAN_ONBOARDING_URL;
        property2.nFORCE__Value__c = 'http://www.google.com';
        insert property2;
        
        nFORCE__System_Properties__c property3 = new nFORCE__System_Properties__c(Name='cccc',nFORCE__Category_Name__c='CoreBookingConfiguration',nFORCE__Is_Active__c=true);
        property3.nFORCE__Key__c = System.Label.BASIC_AUTH_USERNAME;
        property3.nFORCE__Value__c = '';
        insert property3;
        
        nFORCE__System_Properties__c property4 = new nFORCE__System_Properties__c(Name='dddd',nFORCE__Category_Name__c='CoreBookingConfiguration',nFORCE__Is_Active__c=true);
        property4.nFORCE__Key__c = System.Label.BASIC_AUTH_PASSWORD;
        property4.nFORCE__Value__c = '';
        insert property4;
        
        
	    
	    System.assertEquals('Core Booking Endpoint Authentication Type', System.Label.AUTHENTICATION_TYPE);
	    
	    //System.debug(config.GetAllProperties(true));
	    
	    String translatedKey = config.GetTranslatedKey(System.Label.AUTHENTICATION_TYPE);
	    
	    System.assertEquals('Basic', config.GetPropertyByKey(translatedKey));
	    
        String outputmessage = 'loan=123';

        TestMsg message = new TestMsg();
        message.httpresponse = new HttpResponse();
		message.httpResponse.setBody(outputmessage);
		message.properties.put('loan', '123');

        HttpRequest req = new HttpRequest();

		CBLoanSendService sendService = new CBLoanSendService();
		
		try{
			Object container = sendService.preSendRequest(req,message);
		  	System.assertEquals(true, false);
		}catch(Exception e){
			System.assertEquals('Basic Authentication requires the "Encrypted Core Booking Basic Authentication Username" to be filled in.Basic Authentication requires the "Encrypted Core Booking Basic Authentication Password" to be filled in.', e.getMessage());
		}
		
	}
	
	@isTest
	private static void testPreProcessSeamFails() {
        
        String outputmessage = 'loan=123';

        TestMsg message = new TestMsg();
        message.messageHeader.action='Unsupported';
        message.httpresponse = new HttpResponse();
		message.httpResponse.setBody(outputmessage);
		message.properties.put('loan', '123');

        HttpRequest req = new HttpRequest();

		CBLoanSendService sendService = new CBLoanSendService();
		
		try {
			Object container = sendService.preSendRequest(req,message);
			System.assertEquals(true, false);
		} catch(CBLoanSendService.CBSendServiceException e){
			System.assertEquals('The action specified "Unsupported" is not supported.', e.getMessage());
		}
		
	}
	
	@isTest
	private static void testPreProcessSeamFailsHttpError() {
        
        String outputmessage = 'loan=123';

        TestMsg message = new TestMsg();
        message.messageHeader.action='Unsupported';
        message.httpresponse = new HttpResponse();
		message.httpResponse.setBody(outputmessage);
		message.properties.put('loan', '123');

        HttpRequest req = new HttpRequest();

		CBLoanSendService sendService = new CBLoanSendService();
		
		try {
			Object container = sendService.preSendRequest(new Account(),message);
			System.assertEquals(true, false);
		} catch(CBLoanSendService.CBSendServiceException e){
			System.assertEquals('Core Booking Messaging is expecting a HttpRequest', e.getMessage());
		}
		
	}
    
}