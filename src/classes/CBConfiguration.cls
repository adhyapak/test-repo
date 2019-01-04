public without sharing class CBConfiguration implements ICBConfiguration {
    
    @testVisible
    private static Map<String,String> ConfigurationProperties;

    static {
    	
    	ConfigurationProperties = new Map<String,String>();
    	
    	//anything added to the configuration properties that is not listed here will only have the key set in the db utilized
    	//use this to override the keys to a more friendly version
    	//usage = ConfigurationProperties.put([LABEL NAME HERE],'[WHAT YOU WANT IT TO SHOW UP AS IN THE MESSAGE HERE]');
    	ConfigurationProperties.put(System.Label.LOAN_ONBOARDING_URL,'LOAN_ONBOARDING_URL');
		ConfigurationProperties.put(System.Label.RESERVE_LOAN_NUMBER_ONBOARDING_URL,'RESERVE_LOAN_NUMBER_ONBOARDING_URL');
		ConfigurationProperties.put(System.Label.LOAN_PAYMENT_SCHEDULE_ONBOARDING_URL,'LOAN_PAYMENT_SCHEDULE_ONBOARDING_URL');
    	ConfigurationProperties.put(System.Label.CUSTOMER_ONBOARDING_URL,'CUSTOMER_ONBOARDING_URL');
    	ConfigurationProperties.put(System.Label.DEPOSIT_ONBOARDING_URL,'DEPOSIT_ONBOARDING_URL');
    	ConfigurationProperties.put(System.Label.BASIC_AUTH_USERNAME,'BASIC_AUTH_USERNAME');
    	ConfigurationProperties.put(System.Label.BASIC_AUTH_PASSWORD,'BASIC_AUTH_PASSWORD');
    	ConfigurationProperties.put(System.Label.AUTHENTICATION_TYPE,'AUTHENTICATION_TYPE');
		ConfigurationProperties.put(System.Label.CLIENT_CERTIFICATE_NAME,'CLIENT_CERTIFICATE_NAME');
		
    	
    }
    
    public void LoadPluginConfigurations() {
		List<nFUSE.PluginConfigurationManager.PluginConfiguration> configs = new List<nFUSE.PluginConfigurationManager.PluginConfiguration> {};
		
		
		//insert your configurations here - be sure to use labels so that multilanguage can be supported
		//usage = configs.add(this.CreateConfig([LABEL NAME HERE], '[DEFAULT VALUE HERE]', '[SUPPORTED DATA TYPE HERE]', [BOOLEAN FOR ENCRYPTED FLAG]));
		configs.add(this.CreateConfig(System.Label.LOAN_ONBOARDING_URL, '', 'String', false));
		configs.add(this.CreateConfig(System.Label.RESERVE_LOAN_NUMBER_ONBOARDING_URL, '', 'String', false));
		configs.add(this.CreateConfig(System.Label.LOAN_PAYMENT_SCHEDULE_ONBOARDING_URL, '', 'String', false));
		configs.add(this.CreateConfig(System.Label.CUSTOMER_ONBOARDING_URL, '', 'String', false));
		configs.add(this.CreateConfig(System.Label.DEPOSIT_ONBOARDING_URL, '', 'String', false));
		configs.add(this.CreateConfig(System.Label.BASIC_AUTH_USERNAME, null, 'String', true));
		configs.add(this.CreateConfig(System.Label.BASIC_AUTH_PASSWORD, null, 'String', true));
		configs.add(this.CreateConfig(System.Label.AUTHENTICATION_TYPE, 'Basic', 'String', false));
		configs.add(this.CreateConfig(System.Label.CLIENT_CERTIFICATE_NAME, '', 'String', false));

		
		new nFUSE.PluginConfigurationManager(PLUGIN_NAME, PLUGIN_VERSION).softInsertConfigurations(configs);
		
	}

    
    public void TogglePluginConfigurations(Boolean state){
        List<nFORCE__System_Properties__c> props = [
			SELECT
				Id
			FROM
				nFORCE__System_Properties__c
			WHERE
				nFORCE__Category_Name__c = :PLUGIN_CATEGORY_NAME
		];
		if (props.size() > 0) {
			for(nFORCE__System_Properties__c p : props){
				p.nFORCE__Is_Active__c = state;
				nFORCE.DmlUtility.updateObj(p);
			}
		}
    }
    
    @testVisible
	private nFUSE.PluginConfigurationManager.PluginConfiguration CreateConfig(String key, String value, String dataType, Boolean isEncrypted){
		nFUSE.PluginConfigurationManager.PluginConfiguration config = new nFUSE.PluginConfigurationManager.PluginConfiguration();
		config.pluginName = PLUGIN_NAME;
		config.pluginVersion = PLUGIN_VERSION;
		config.category = PLUGIN_CATEGORY_NAME;
		config.key = key;
		config.valueDataType = dataType;
		config.value = value;
		config.isEncrypted = isEncrypted;
		return config;
	}
	
	public String GetTranslatedKey(String key){
		if(ConfigurationProperties.containsKey(key)){
			return ConfigurationProperties.get(key);
		}else{
			return CBUtility.NormalizeKey(key);
		}
	}
    
    public Map<String,String> GetAllProperties(Boolean translateKey){
        Map<String,String> configurationMap = this.retrieveKeyValueMap();
        Map<String,String> properties = new Map<String,String>();
        if(configurationMap.size()>0){
            for(String key : configurationMap.keySet()){
            	
            	if(translateKey){
            		if(ConfigurationProperties.containsKey(key)){
            			properties.put(ConfigurationProperties.get(key),configurationMap.get(key));
            		}else{
            			//convert to CAPS and replace spaces with underscores
            			properties.put(CBUtility.NormalizeKey(key),configurationMap.get(key));
            		}
            	}else{
            		properties.put(CBUtility.NormalizeKey(key),configurationMap.get(key));
            	}
            	
            }
        }
        return properties;
    }
    
    
    public String GetPropertyByKey(String key){
        Map<String,String> properties = this.GetAllProperties(true); //always try to translate
        if(properties != null && properties.size()>0 && properties.containsKey(CBUtility.NormalizeKey(key))){
        	
        	return properties.get(CBUtility.NormalizeKey(key));
            
        }
        return null;
    }
    
	@testVisible
	private Map<String, String> retrieveKeyValueMap(){
		nFUSE.PluginConfigurationManager configManager = new nFUSE.PluginConfigurationManager(PLUGIN_NAME, PLUGIN_VERSION);
		Map<String, String> configurationMap = new Map<String, String>();
		List<nFUSE.PluginConfigurationManager.PluginConfiguration> configs = configManager.getConfigurations();
		for(nFUSE.PluginConfigurationManager.PluginConfiguration config : configs) {
			configurationMap.put(config.key, config.value);
		}
		return configurationMap;
	}
    
    public class CBConfigurationException extends Exception {}
    
    @testVisible
	private static final String NFUSE_CONFIGURATION_KEYWORD = 'Configuration';
	public static final Set<String> KEYS_TO_OMIT_FROM_MESSAGES = new Set<String>{
		'LOAN_ONBOARDING_URL',
		'CUSTOMER_ONBOARDING_URL',
		'DEPOSIT_ONBOARDING_URL',
		'BASIC_AUTH_USERNAME',
		'BASIC_AUTH_PASSWORD',
		'AUTHENTICATION_TYPE',
		'RESERVE_LOAN_NUMBER_ONBOARDING_URL',
		'LOAN_PAYMENT_SCHEDULE_ONBOARDING_URL',
		'CLIENT_CERTIFICATE_NAME'
	};
	//these are intended to be communicated to third party
	public static final Set<String> TRANSACTION_STATUS_COMPLETION_STRINGS = new Set<String>{
		'REQUEST FAILED',
		'COMPLETE',
		'ERROR'
	};
	//Added by Chintan Adhyapak, West Monroe Partners. March 23, 2018
	public static final Set<String> BOOKLOAN_TRANSACTION_STATUS_COMPLETION_STRINGS = new Set<String>{
		'REQUEST FAILED',
		'COMPLETED',
		'ERROR',
		'ACKNOWLEDGED'
	};
	//End Modification. Chintan Adhyapak
	//error strings should be a subset of the completion strings that indicate error. these are intended to be communicated to third party
	public static final Set<String> TRANSACTION_STATUS_ERROR_STRINGS = new Set<String>{
		'REQUEST FAILED',
		'ERROR'
	};
	public static final String
            PLUGIN_NAME = 'CoreBooking',
            PLUGIN_VERSION = '1.0',
            PLUGIN_CATEGORY_NAME = PLUGIN_NAME + NFUSE_CONFIGURATION_KEYWORD,
            LOANSENDSERVICENAME = 'LoanSendService',
            CUSTOMERSENDSERVICENAME = 'CustomerSendService',
            DEPOSITSENDSERVICENAME = 'DepositSendService',
            LOANBOOKACTION = 'book_loan',
			LOANRESERVENUMBERACTION = 'reserve_loan_num',
			LOANPAYMENTSCHEDULEACTION = 'loan_payment_schedule',
            CUSTOMERBOOKACTION = 'book_customer',
            DEPOSITBOOKACTION = 'book_deposit',
            NFUSE_LOAN_XPKG_SERVICE = 'nFUSE.LoanGetXPkg',
            NFUSE_RELATIONSHIP_XPKG_SERVICE = 'nFUSE.RelationshipGetXPkg',
            NFUSE_DEPOSIT_XPKG_SERVICE = 'nFUSE.DepositGetXPkg',
            IN_PROGRESS_STATUS = 'In Progress',
			IN_ERROR_STATUS = 'Error',
			MIDDLEWARE_ACK_STATUS = 'Acknowledged',
			IN_COMPLETED_STATUS = 'Completed';
}