global without sharing class CBCustomerSendService extends nFUSE.SendService {
    
    public class CBSendServiceException extends Exception {}
    
    @testVisible
    private CBConfiguration configuration = new CBConfiguration();
    @testVisible
    private CBUtility utility = new CBUtility();
    
    public CBCustomerSendService(){
        super();
    }
    
    //use this to set headers
    global protected override Object preSendRequest(Object request, nFUSE.AMiddlewareMessage msg){
        if (!(request instanceof HttpRequest)) {
			throw new CBSendServiceException(System.Label.CBHttpRequestExpected);
		}
        if(request instanceof HttpRequest){
            
            HttpRequest httpReq = (HttpRequest)request;
            
            //boiler plate
            //always make sure the content type is set to json
            utility.UpdateOrAddHeader(httpReq, 'Content-Type', 'application/json');
            utility.UpdateOrAddHeader(httpReq, 'Accept', 'application/json');
            
            //enforce we are on the correct action
            if(msg.messageHeader.action != CBConfiguration.CUSTOMERBOOKACTION){
                throw new CBSendServiceException(String.format(System.Label.CBSendServiceException, 
                    new String[]{
                        msg.messageHeader.action
                    }));
            }
            
            //else we are ok to continue
            
            String translatedUrlKey = configuration.GetTranslatedKey(System.Label.CUSTOMER_ONBOARDING_URL);
            String endpointToUse = configuration.GetPropertyByKey(translatedUrlKey);
            
            String translatedAuthTypeKey = configuration.GetTranslatedKey(System.Label.AUTHENTICATION_TYPE);
            String endpointAuthorizationType = configuration.GetPropertyByKey(translatedAuthTypeKey);
            
            String translatedAuthUsernameKey = configuration.GetTranslatedKey(System.Label.BASIC_AUTH_USERNAME);
            String endpointAuthorizationUsername = configuration.GetPropertyByKey(translatedAuthUsernameKey);
            
            String translatedAuthPasswordKey = configuration.GetTranslatedKey(System.Label.BASIC_AUTH_PASSWORD);
            String endpointAuthorizationPassword = configuration.GetPropertyByKey(translatedAuthPasswordKey);
            
            //build a list of error messages (concat System.Label.CBServiceRequiredFieldBlankException where {0} is the translated property)
            if(endpointAuthorizationType.toLowerCase() == 'basic'){
                if(String.isBlank(endpointAuthorizationUsername) || String.isBlank(endpointAuthorizationPassword)){
                    String message = '';
                    if(String.isBlank(endpointAuthorizationUsername)){
                        message += String.format(System.Label.BasicAuthenticationMissingField, new String[]{
                            System.Label.BASIC_AUTH_USERNAME
                        });
                    }
                    if(String.isBlank(endpointAuthorizationPassword)){
                        message += String.format(System.Label.BasicAuthenticationMissingField, new String[]{
                            System.Label.BASIC_AUTH_PASSWORD
                        });
                    }
                    throw new CBSendServiceException(message);
                }else{
                    utility.UpdateOrAddHeader(httpReq, 'Authorization', 'Basic ' + EncodingUtil.base64Encode(Blob.valueOf(endpointAuthorizationUsername + ':' + endpointAuthorizationPassword)));
                }
            }else{
                //remove the value of the authorization header because nothing is meant to be configured
                utility.UpdateOrAddHeader(httpReq, 'Authorization', '');
            }
            
            //error handling for endpoint being blank if not set
            if(String.isBlank(endpointToUse)){
                throw new CBSendServiceException(String.format(System.Label.MissingField, new String[]{
                        System.Label.CUSTOMER_ONBOARDING_URL
                    }));
            }
            //SETS THE ENDPOINT
            httpReq.setEndpoint(endpointToUse);
            
            //override the authorization header if Basic
            
            //if a custom timeout to be used, add it here
            //example: httpReq.setTimeout(60000); //timeout after 60 seconds
            //if a certificate is intended to be used, add it here (the name should probably be in the plugin configuration)
            //example: httpReq.setClientCertificateName(certNamefromPluginConfiguration);
            
             
        }
        return request;
    }
    
    public protected override nFUSE.AMiddlewareMessage preSendSeam(nFUSE.AMiddlewareMessage message) {

        //NOTE: This is where the custom handling of the response takes place.     
        nFUSE.AMiddlewareMessage m = super.preSendSeam(message);

        Map<String,String> properties = configuration.GetAllProperties(true);
        for (String key : properties.keySet())
        {
            if(!CBConfiguration.KEYS_TO_OMIT_FROM_MESSAGES.contains(key))
                m.properties.put(key, properties.get(key));
        }
        
        //now take the session id override if it was provided and shove it in the messageheader
        String overrideSessionId = String.valueof(m.properties.get('salesforce_session_id'));
        
        if(!String.isBlank(overrideSessionId))
        {
            m.messageHeader.userSalesforceSessionId = overrideSessionId;
        }
        
        
        //if a different verb is intended to be used set it here
        //example: m.method = 'GET';
        
        
    	return m;
    
    }
    
    public override nFUSE.AMiddlewareMessage postSendSeam(nFUSE.AMiddlewareMessage message) {
         
        //NOTE: This is where the custom handling of the response takes place.     
 
        return message;
    }


}