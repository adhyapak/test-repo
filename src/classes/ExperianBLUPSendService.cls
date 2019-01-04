/**
 * Created by jane.boles on 8/18/2017.
 */

global with sharing class ExperianBLUPSendService extends nFUSE.SendService{
    global ExperianBLUPSendService(){
        super();
    }
    global override nFUSE.AMiddlewareMessage preSendSeam(nFUSE.AMiddlewareMessage message) {
        this.Loader();
        
        message.properties.put('EXPERIAN_USER_ID', this.retrieveValueFromKey(EXPERIAN_USER_ID));
        message.properties.put('EXPERIAN_PASSWORD', this.retrieveValueFromKey(EXPERIAN_PASSWORD));
        message.properties.put('EXPERIAN_SUBSCRIBER_NUMBER', this.retrieveValueFromKey(EXPERIAN_SUBSCRIBER_NUMBER));

        //the settings needed
        message.properties.put('EXPERIAN_BIZUSER_ID', this.retrieveValueFromKey(EXPERIAN_BIZUSER_ID));
        message.properties.put('EXPERIAN_BIZPASSWORD', this.retrieveValueFromKey(EXPERIAN_BIZPASSWORD));
        message.properties.put('EXPERIAN_BIZSUBSCRIBER_NUMBER', this.retrieveValueFromKey(EXPERIAN_BIZSUBSCRIBER_NUMBER));

        message.properties.put('TEST_OR_PRODUCTION', this.retrieveValueFromKey(TEST_OR_PRODUCTION));

        message.properties.put('namespaceoverride', getNamespaceOverride(String.valueOf(ExperianBLUPSendService.class)));

        return message;
    }
    
    @TestVisible
    private static String getNameSpacePrefix(String className, String delimiter) {
        String nameSpace = null;
        String[] classparts = className.split('\\.');
        if (classparts.size() >= 2) {
            nameSpace = classparts[0];
            return namespace+delimiter;
        }
        return '';
    }
    
    @TestVisible
    private static String getNameSpace(String className) {
        return getNameSpacePrefix(className,'');
    }
    
    @TestVisible
    private static String getNamespaceOverride(String className){
        String ns = getNameSpace(className);
        if(!String.isBlank(ns)){
            return ns;
        }
        return '--NAMESPACEEMPTY--';
    }
    
    /**
	 * Purpose : to load configuration properties for the nFuse.PluginConfigurationManager
	 * Notes : This avoids a null pointer exception when PluginConfiguration is empty, modular for use in other methods
	 *			and outside of the class itself for testing purposes
	*/
	@TestVisible
	private void Loader(){
		//since activator class already created an instance of PluginManager
        //instantiating a new config manager with the same plugin name and version will retreive the values 
        //that were already created from the credit app facade class 
		this.configs = new nFUSE.PluginConfigurationManager(PLUGIN_NAME, PLUGIN_VERSION).getConfigurations();
	}
    
    /* 
	* Purpose : retrieves the value associated with the specific config key
	*/
	@TestVisible
	private String retrieveValueFromKey(String configKey){
		for(nFUSE.PluginConfigurationManager.PluginConfiguration config : this.configs) {
			if (config.key == configKey){
				return config.value;
			} 
		}
		throw new XEXPERIANBLUPException(X_MISSING_REQUIRED_PROPERTY + ': ' + configKey);
	}
    
	// Purpose : Plugin Configuration List 
	private List<nFUSE.PluginConfigurationManager.PluginConfiguration> configs;
    
    public class XEXPERIANBLUPException extends Exception {}

    @TestVisible private static String X_MISSING_REQUIRED_PROPERTY = Label.EXPERIAN_BLUP_missing_property;

    public static final String
            PLUGIN_NAME = 'Experian_Credit',
            PLUGIN_VERSION = '1.0',
            TEST_OR_PRODUCTION ='Test or Production',
            NFUSE_CONFIGURATION_KEYWORD = 'Configuration',
            EXPERIAN_USER_ID = 'Encrypted Experian User Id',
            EXPERIAN_PASSWORD = 'Encrypted Experian Password',
            EXPERIAN_SUBSCRIBER_NUMBER = 'Encrypted Experian Subscriber Number',
            EXPERIAN_BIZUSER_ID = 'Encrypted Experian Business User Id',
            EXPERIAN_BIZPASSWORD = 'Encrypted Experian Business Password',
            EXPERIAN_BIZSUBSCRIBER_NUMBER = 'Encrypted Experian Business Subscriber Number',
            PLUGIN_CONFIG_NAME ='Experian_Credit' + NFUSE_CONFIGURATION_KEYWORD;

}