/**
 * @author nCino
 * Implements the IPlugin Activator Interface and creates SystemProperties,
 * SystemConfiguration, and registers a bean for the CreditAppFacade on Activate.
 * Then does nothing on deactivate.
 **/
global with sharing class ExperianCreditActivator implements nFUSE.IPluginActivator {
    
    global with sharing class ExperianCreditPassReviewDecision extends nFUSE.ACreditPassReviewDecision {
        global override Flow.Interview create(Map<String,Object> inputs) {
            return new Flow.Interview.Credit_Pass_Review(inputs);
        }
    }
    
    global with sharing class ExperianCreditReportTypeDecision extends nFUSE.ACreditReportTypeDecision {
        global override Flow.Interview create(Map<String,Object> inputs) {
            return new Flow.Interview.Credit_Report_Type(inputs);
        }
    }
    
    public void onActivate() {
        
        // register Experian credit app facade
        nFORCE.BeanRegistry.getInstance().registerBean(
            ExperianCreditAppFacade.class.getName(),
            nFUSE.CreditAppFacade.class,
            ExperianCreditAppFacade.class,
            new Map<String, Object>{},
            true);
        
        // load default configurations
		this.LoadPluginConfigurations();
        
        // register credit pass review and report type flows
        nFUSE.ACreditPassReviewDecision.register(ExperianCreditPassReviewDecision.class);
        nFUSE.ACreditReportTypeDecision.register(ExperianCreditReportTypeDecision.class);

        nFUSE.PackageServiceRequest request = new nFUSE.PackageServiceRequest(PLUGIN_NAME,PLUGIN_VERSION, null);
        nFUSE.ServiceLocator locator = new nFUSE.ServiceLocator();

        // Register service extension in the App Plugin Activator on activation
        locator.register(request, nFUSE.SendService.class, ExperianBLUPSendService.class, 'ExperianBLUPSendService');
    }

    public void onDeactivate() {
        nFUSE.PackageServiceRequest request = new nFUSE.PackageServiceRequest(PLUGIN_NAME,PLUGIN_VERSION, null);
        nFUSE.ServiceLocator locator = new nFUSE.ServiceLocator();
        locator.deregister(request, nFUSE.SendService.class, 'ExperianBLUPSendService');
    }
    
    /**
     * Purpose : Create all configuration properties in one method following nFUSE.PluginConfigurationManager specifications
     * Details : To utilize nFUSE.PluginConfigurationManager and deprecate nForce.SystemsProperties usage as of Fall 2017 Release
     *			 Inserts new configurations into a list of configurations,
     *			 If configuration already exists in the data layer, then the existing config value is kept
     */ 
    @TestVisible
    private void LoadPluginConfigurations(){
        this.configs = new List<nFUSE.PluginConfigurationManager.PluginConfiguration> {};

        //Boiler Plate settings + DATA-1491
		this.configs.add(this.CreateConfig(BUSINESS_DAYS_VALID, '30', 'String', false));  
		this.configs.add(this.CreateConfig(CONSUMER_DAYS_VALID, '30', 'String', false)); 
		this.configs.add(this.CreateConfig(COMMERCIAL_PLACEHOLDER_NAME, 'Credit Report', 'String', false)); 
		this.configs.add(this.CreateConfig(COMMERCIAL_APPEND_BUREAU_ID_TO_NAME, 'Y', 'String', false)); 
		this.configs.add(this.CreateConfig(CONSUMER_PLACEHOLDER_NAME, 'Credit Report', 'String', false)); 
		this.configs.add(this.CreateConfig(CONSUMER_APPEND_BUREAU_ID_TO_NAME, 'Y', 'String', false)); 
		this.configs.add(this.CreateConfig(PLACEHOLDER_CATEGORY,'Credit Reports', 'String', false)); 
		this.configs.add(this.CreateConfig(APPEND_DATE_TO_PLACEHOLDER_NAME, 'Y', 'String', false)); 
        
        //Experian Specific Settings
        this.configs.add(this.CreateConfig(ACCOUNT_PURPOSE_TYPE_CODE, '', 'String', false));
        this.configs.add(this.CreateConfig(HARD_ACCOUNT_PURPOSE_TYPE_CODE, '', 'String', false));
        this.configs.add(this.CreateConfig(FLAGS_NEWCONSUMER, 'N', 'String', false));
        this.configs.add(this.CreateConfig(FLAGS_DIRECTCHECK, 'N', 'String', false));
        this.configs.add(this.CreateConfig(FLAGS_FRAUDSHIELD, 'Y', 'String', false));
        this.configs.add(this.CreateConfig(FLAGS_DEFERREDPAYMENTINFORMATION, 'N', 'String', false));
        this.configs.add(this.CreateConfig(FLAGS_ACTUALPAYMENTAMOUNT, 'N', 'String', false));
        this.configs.add(this.CreateConfig(FLAGS_EXPANDEDHISTORY, 'N', 'String', false));
        this.configs.add(this.CreateConfig(FLAGS_NATIONALRISK, 'N', 'String', false));
        this.configs.add(this.CreateConfig(FLAGS_OLDNATIONAL, 'N', 'String', false));
        this.configs.add(this.CreateConfig(FLAGS_DEMOGRAPHICS, 'Y', 'String', false));
        this.configs.add(this.CreateConfig(FLAGS_SEGMENT130, 'Y', 'String', false));
        this.configs.add(this.CreateConfig(FLAGS_SCOREPERCENTILE, 'N', 'String', false));
        this.configs.add(this.CreateConfig(FLAGS_HEALTHCAREPROFILE, 'N', 'String', false));
        this.configs.add(this.CreateConfig(FLAGS_OFAC, 'Y', 'String', false));
        this.configs.add(this.CreateConfig(FLAGS_FICO3, 'Y', 'String', false));
        this.configs.add(this.CreateConfig(FLAGS_FICO8, 'N', 'String', false));
        this.configs.add(this.CreateConfig(EXPERIAN_BIZSUBSCRIBER_NUMBER, '', 'String', true));
        this.configs.add(this.CreateConfig(EXPERIAN_RISKMODELCODE, '', 'String', false));
        this.configs.add(this.CreateConfig(FLAGS_SCORE, 'Y', 'String', false));
        this.configs.add(this.CreateConfig(FLAGS_BP, 'Y', 'String', false));
        this.configs.add(this.CreateConfig(FLAGS_CRLK, 'N', 'String', false));
        this.configs.add(this.CreateConfig(FLAGS_ITP, 'N', 'String', false));
        this.configs.add(this.CreateConfig(FLAGS_LIST, 'N', 'String', false));
        this.configs.add(this.CreateConfig(FLAGS_MATCHCODE, 'N', 'String', false));
        this.configs.add(this.CreateConfig(FLAGS_ALLREPORTS, 'N', 'String', false));
        this.configs.add(this.CreateConfig(FLAGS_UCC, 'Y', 'String', false));
        this.configs.add(this.CreateConfig(FLAGS_DATASEGMENT, 'N', 'String', false));
        this.configs.add(this.CreateConfig(EXPERIAN_USER_ID, '', 'String', true));
        this.configs.add(this.CreateConfig(EXPERIAN_PASSWORD, '', 'String', true));
        this.configs.add(this.CreateConfig(EXPERIAN_SUBSCRIBER_NUMBER, '', 'String', true));
        this.configs.add(this.CreateConfig(TEST_OR_PRODUCTION, 'TEST', 'String', false));
        this.configs.add(this.CreateConfig(PREAMBLE, '', 'String', false));
        this.configs.add(this.CreateConfig(EXPERIAN_BIZUSER_ID, '', 'String', true));
        this.configs.add(this.CreateConfig(EXPERIAN_BIZPASSWORD, '', 'String', true));
        
        new nFUSE.PluginConfigurationManager(PLUGIN_NAME, PLUGIN_VERSION).softInsertConfigurations(configs);
    }
    
      /*
	* Purpose : Create configuration properties by using the nFUSE class PluginConfigurationManager.cls
	* @param String key : config key, example: 'Business Days Valid'
	* @param String value : config default value: example: '30'
	* @param String dataType : it is always a string
	* @param Boolean isEncrypted : none of the configs are encrypted for this specific plugin
	* returns a list of configurations [PluginConfigurationManager.Configurations]
	*/
	@TestVisible 
	private nFUSE.PluginConfigurationManager.PluginConfiguration CreateConfig(String key, String value, String dataType, Boolean isEncrypted){
		nFUSE.PluginConfigurationManager.PluginConfiguration config = new nFUSE.PluginConfigurationManager.PluginConfiguration();
		config.pluginName = PLUGIN_NAME;
		config.pluginVersion = PLUGIN_VERSION;
		config.category = PLUGIN_NAME;
		config.key = key;
		config.valueDataType = dataType;
		config.value = value;
		config.isEncrypted = isEncrypted;
		return config;
	}
	
	/*
	* Purpose : Check for existence of category in configuration properties by using the nFUSE class PluginConfigurationManager.cls
	* @param String category : config category, example: 'Experian_Credit'
	*/ 
	@TestVisible 
	private Boolean containsCategory(String category){
		for(nFUSE.PluginConfigurationManager.PluginConfiguration config : this.configs) {
				if (config.category == category){
					return true;
				}
		}
		return false;
	}
    
    @TestVisible
    private List<nFUSE.PluginConfigurationManager.PluginConfiguration> configs;
    
    private static final String NFUSE_CONFIGURATION_KEYWORD = 'Configuration';
    
    public static final String PLUGIN_NAME = 'Experian_Credit',
        PLUGIN_VERSION = '1.0',
        PLUGIN_CONFIG_NAME ='Experian_Credit' + NFUSE_CONFIGURATION_KEYWORD,
        PLUGIN_HELP_TEXT = 'Experian Plugin Category for Property Configuration',
    
        //Boiler Plate properties
        BUSINESS_DAYS_VALID = 'Business Days Valid',
        CONSUMER_DAYS_VALID = 'Consumer Days Valid',
        COMMERCIAL_PLACEHOLDER_NAME = 'Commercial Credit Placeholder Name',
		COMMERCIAL_APPEND_BUREAU_ID_TO_NAME = 'Append Bureau ID to Commercial Placeholder Name',
		CONSUMER_PLACEHOLDER_NAME = 'Consumer Credit Placeholder Name',
		CONSUMER_APPEND_BUREAU_ID_TO_NAME = 'Append Bureau ID to Consumer Placeholder Name',
		PLACEHOLDER_CATEGORY = 'Credit Report Category',
		APPEND_DATE_TO_PLACEHOLDER_NAME = 'Append Date/Time to Placeholder Name',
		
        //Experian-specific settings
        ACCOUNT_PURPOSE_TYPE_CODE = 'Soft Account Purpose Type Code',
        HARD_ACCOUNT_PURPOSE_TYPE_CODE = 'Hard Account Purpose Type Code',
        FLAGS_NEWCONSUMER = 'Add-on: New Consumer',
        FLAGS_DIRECTCHECK = 'Add-on: Direct Check',
        FLAGS_FRAUDSHIELD = 'Add-on: Fraud Shield',
        FLAGS_DEFERREDPAYMENTINFORMATION = 'Add-on: Deferred Payment Information',
        FLAGS_ACTUALPAYMENTAMOUNT = 'Add-on: Actual Payment Amount',
        FLAGS_EXPANDEDHISTORY = 'Add-on: Expanded History',
        FLAGS_NATIONALRISK = 'Add-on: National Risk',
        FLAGS_OLDNATIONAL = 'Add-on: Old National',
        FLAGS_DEMOGRAPHICS = 'Add-on: Demographics',
        FLAGS_SEGMENT130 = 'Add-on: Segment 130',
        FLAGS_SCOREPERCENTILE = 'Add-on: Score Percentile',
        FLAGS_HEALTHCAREPROFILE = 'Add-on: Healthcare Profile',
        FLAGS_OFAC = 'Add-on: OFAC',
        FLAGS_FICO3 = 'Add-on: FICO3',
        FLAGS_FICO8 = 'Add-on: FICO8',
        EXPERIAN_BIZSUBSCRIBER_NUMBER = 'Encrypted Experian Business Subscriber Number',
        EXPERIAN_RISKMODELCODE = 'Business Risk Model Code Override',
        FLAGS_SCORE = 'Bus. Add-on: KeyModelElements data',
        FLAGS_BP = 'Bus. Add-on: Business Profile',
        FLAGS_CRLK = 'Bus. Add-on: Corporate Linkage Data',
        FLAGS_ITP = 'Bus. Add-on: Industry Trade Profile Data',
        FLAGS_LIST = 'Bus. Add-on: List of Similars',
        FLAGS_MATCHCODE = 'Bus. Add-on: Match Reliability Code',
        FLAGS_ALLREPORTS = 'Bus. Add-on: All Reports',
        FLAGS_UCC = 'Bus. Add-on: Business Summary Data',
        FLAGS_DATASEGMENT = 'Bus. Add-on: Data Segments',
        EXPERIAN_USER_ID = 'Encrypted Experian User Id',
        EXPERIAN_PASSWORD = 'Encrypted Experian Password',
        EXPERIAN_SUBSCRIBER_NUMBER = 'Encrypted Experian Subscriber Number',
        TEST_OR_PRODUCTION = 'Test or Production',
		PREAMBLE = 'Preamble',
		EXPERIAN_BIZUSER_ID = 'Encrypted Experian Business User Id',
		EXPERIAN_BIZPASSWORD = 'Encrypted Experian Business Password';

}