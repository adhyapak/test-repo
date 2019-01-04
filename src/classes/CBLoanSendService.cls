global without sharing class CBLoanSendService extends nFUSE.SendService {
    public class CBSendServiceException extends Exception {}

    @testVisible
    private CBConfiguration configuration = new CBConfiguration();
    @testVisible
    private CBUtility utility = new CBUtility();

    /* Constructor */
    public CBLoanSendService(){
        super();
    }

    //use this to set headers
    global protected override Object preSendRequest(Object request, nFUSE.AMiddlewareMessage msg){
        if (!(request instanceof HttpRequest)) {
            throw new CBSendServiceException(System.Label.CBHttpRequestExpected);
        }
        if (request instanceof HttpRequest) {
            //NOTE: This is where the custom handling of the response takes place.     
            request = super.preSendRequest(request, msg);
            HttpRequest httpReq = (HttpRequest)request;
            
            //Set the Navy_Core_Code HTTP header to indicate to Middleware which Core to book the loan to
            //Chintan Adhyapak, West Monroe Partners. December 14, 2017
           	//Read the Navy_Core_Code value from message properties that was set in CBOrchestrator
        	String navyCoreCode = String.valueOf(msg.properties.get('Navy_Core_Code'));
        	System.debug('In CBLoanSendService Navy_Core_Code read is: ' + navyCoreCode);
        	if (!String.isBlank(navyCoreCode)) {
            	utility.UpdateOrAddHeader(httpReq, 'Navy_Core_Code', navyCoreCode);
        	}
            

            //boiler plate
            //always make sure the content type is set to json
            utility.UpdateOrAddHeader(httpReq, 'Content-Type', 'application/json');
            utility.UpdateOrAddHeader(httpReq, 'Accept', 'application/json');

            //enforce we are on the correct action
            /*
            if(msg.messageHeader.action != CBConfiguration.LOANBOOKACTION && msg.messageHeader.action != CBConfiguration.LOANRESERVENUMBERACTION ){
                throw new CBSendServiceException(String.format(System.Label.CBSendServiceException,
                    new String[]{
                        msg.messageHeader.action
                    }));
            }

            */
            //Set the endpoint to send the message to
            String endpointToUse = null;
            if(msg.messageHeader.action == CBConfiguration.LOANBOOKACTION ) {
                String translatedUrlKey = configuration.GetTranslatedKey(System.Label.LOAN_ONBOARDING_URL);
                endpointToUse = configuration.GetPropertyByKey(translatedUrlKey);
            } else if ( msg.messageHeader.action == CBConfiguration.LOANRESERVENUMBERACTION ) {
                String translatedUrlKey = configuration.GetTranslatedKey(System.Label.RESERVE_LOAN_NUMBER_ONBOARDING_URL);
                endpointToUse = configuration.GetPropertyByKey(translatedUrlKey);
            } else if (msg.messageHeader.action == CBConfiguration.LOANPAYMENTSCHEDULEACTION ) {

                String translatedUrlKey = configuration.GetTranslatedKey(System.Label.LOAN_PAYMENT_SCHEDULE_ONBOARDING_URL);
                endpointToUse = configuration.GetPropertyByKey(translatedUrlKey);

            } else {
                throw new CBSendServiceException(String.format(System.Label.CBSendServiceException,
                        new String[]{
                                msg.messageHeader.action
                        }));
            }
            System.debug('endpointToUse:--' + endpointToUse);

            /*
            String translatedUrlKey = configuration.GetTranslatedKey(System.Label.LOAN_ONBOARDING_URL);
            String endpointToUse = configuration.GetPropertyByKey(translatedUrlKey);

            */
			//Set the authentication type
            String translatedAuthTypeKey = configuration.GetTranslatedKey(System.Label.AUTHENTICATION_TYPE);
            String endpointAuthorizationType = configuration.GetPropertyByKey(translatedAuthTypeKey);
            System.debug('endpointAuthorizationType:--' + endpointAuthorizationType);
            String translatedAuthUsernameKey = configuration.GetTranslatedKey(System.Label.BASIC_AUTH_USERNAME);
            String endpointAuthorizationUsername = configuration.GetPropertyByKey(translatedAuthUsernameKey);
            System.debug('endpointAuthorizationUsername:--' + endpointAuthorizationUsername);
            String translatedAuthPasswordKey = configuration.GetTranslatedKey(System.Label.BASIC_AUTH_PASSWORD);
            String endpointAuthorizationPassword = configuration.GetPropertyByKey(translatedAuthPasswordKey);
            System.debug('endpointAuthorizationPassword:--' + endpointAuthorizationPassword);
            String translatedClientCertificate = configuration.GetTranslatedKey(System.Label.CLIENT_CERTIFICATE_NAME);
            String endpointClientCertificate = configuration.GetPropertyByKey(translatedClientCertificate);
            System.debug('endpointClientCertificate:--' + endpointClientCertificate);


            //build a list of error messages (concat System.Label.CBServiceRequiredFieldBlankException where {0} is the translated property)
            if (endpointAuthorizationType.toLowerCase() == 'basic') {
            	System.debug('CPA Read BASIC authentication type');
                if (String.isBlank(endpointAuthorizationUsername) || String.isBlank(endpointAuthorizationPassword)) {
                    String message = '';
                    if (String.isBlank(endpointAuthorizationUsername)) {
                        message += String.format(System.Label.BasicAuthenticationMissingField, new String[]{
                                System.Label.BASIC_AUTH_USERNAME
                        });
                    }
                    if (String.isBlank(endpointAuthorizationPassword)) {
                        message += String.format(System.Label.BasicAuthenticationMissingField, new String[]{
                                System.Label.BASIC_AUTH_PASSWORD
                        });
                    }
                    throw new CBSendServiceException(message);
                } else {
                	System.debug('Setting BASIC Authentication Header');
                    utility.UpdateOrAddHeader(httpReq, 'Authorization', 'Basic ' + EncodingUtil.base64Encode(Blob.valueOf(endpointAuthorizationUsername + ':' + endpointAuthorizationPassword)));
                }
            } else {
            	System.debug('CPA Removing authorization header');
                //remove the value of the authorization header because nothing is meant to be configured
                utility.UpdateOrAddHeader(httpReq, 'Authorization', '');
            }

            //error handling for endpoint being blank if not set
            if (String.isBlank(endpointToUse)) {
                throw new CBSendServiceException(String.format(System.Label.MissingField, new String[]{
                        System.Label.LOAN_ONBOARDING_URL
                }));
            }
            //SETS THE ENDPOINT
            httpReq.setEndpoint(endpointToUse);
            
            //Start Modifications. Chintan Adhyapak, West Monroe Partners, March 28, 2018
            if (!String.isBlank(endpointClientCertificate)) {
            	httpReq.setClientCertificateName(endpointClientCertificate);
            }
            httpReq.setTimeout(20000);
            //End Modifications

            //override the authorization header if Basic

            //if a custom timeout to be used, add it here
            //example: httpReq.setTimeout(60000); //timeout after 60 seconds
            //if a certificate is intended to be used, add it here (the name should probably be in the plugin configuration)
            //example: httpReq.setClientCertificateName(certNamefromPluginConfiguration);
        }
        //return the request
        return request;
    } //preSendRequest
    
    

    /** The preSendSeam method */
    public protected override nFUSE.AMiddlewareMessage preSendSeam(nFUSE.AMiddlewareMessage message) {
        //NOTE: This is where the custom handling of the response takes place.     
        nFUSE.AMiddlewareMessage m = super.preSendSeam(message);

        Map<String,String> properties = configuration.GetAllProperties(true);
        for (String key : properties.keySet()) {
            if (!CBConfiguration.KEYS_TO_OMIT_FROM_MESSAGES.contains(key))
                m.properties.put(key, properties.get(key));
        }

        //now take the session id override if it was provided and shove it in the messageheader
        String overrideSessionId = String.valueof(m.properties.get('salesforce_session_id'));
        if (!String.isBlank(overrideSessionId)) {
            m.messageHeader.userSalesforceSessionId = overrideSessionId;
        }

        //if a different verb is intended to be used set it here
        //example: m.method = 'GET';
        //return the message
        return m;
    } //preSendSeam
    
    
	/** The ppostSendSeam message */
    public override nFUSE.AMiddlewareMessage postSendSeam(nFUSE.AMiddlewareMessage message) {
        //NOTE: This is where the custom handling of the response takes place.     
        return message;
    } //postSendSeam
}