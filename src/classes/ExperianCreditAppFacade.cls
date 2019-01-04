/**
 * Credit AppFacade Extension for Experian
 */
global with sharing class ExperianCreditAppFacade extends nFUSE.CreditAppFacade {
	
	@TestVisible private DocManAttachmentHandler attachmentHandler = new DocManAttachmentHandler();
	
	/**
	 * Stores Documents returned from the Middleware
	 * @param The external transaction identifier
	 * @param The document name (not used with this plugin)
	 * @param The document content
	 */
	global override void storeDocument(String transactionId, String docName, String docContent) {
		Blob content = Blob.valueOf(docContent);
		attachmentHandler.storeDocument(transactionId, REPORT_NAME, content);
	}

	
	/**
	 * Alters the outbound middleware message
	 * @param outbound AMiddlewareMessage
	 */
	global override nFUSE.AMiddlewareMessage preCommAdjustments(nFUSE.AMiddlewareMessage message){
		//load default configurations
		this.Loader();
		
		//FROM DATA-1491 ----- Boiler Plate settings
		message.properties.put('COMMERCIAL_PLACEHOLDER_NAME', this.retrieveValueFromKey(COMMERCIAL_PLACEHOLDER_NAME));
		message.properties.put('COMMERCIAL_APPEND_BUREAU_ID_TO_NAME', this.retrieveValueFromKey(COMMERCIAL_APPEND_BUREAU_ID_TO_NAME));
		message.properties.put('CONSUMER_PLACEHOLDER_NAME', this.retrieveValueFromKey(CONSUMER_PLACEHOLDER_NAME));
		message.properties.put('CONSUMER_APPEND_BUREAU_ID_TO_NAME', this.retrieveValueFromKey(CONSUMER_APPEND_BUREAU_ID_TO_NAME));
		message.properties.put('PLACEHOLDER_CATEGORY', this.retrieveValueFromKey(PLACEHOLDER_CATEGORY));
		message.properties.put('APPEND_DATE_TO_PLACEHOLDER_NAME', this.retrieveValueFromKey(APPEND_DATE_TO_PLACEHOLDER_NAME));
		
		// --------------- everthing below in this override preCommAdjustments are experian specific settings -----------------------------
		//the settings needed
		message.properties.put('EXPERIAN_USER_ID', this.retrieveValueFromKey(EXPERIAN_USER_ID));
		message.properties.put('EXPERIAN_PASSWORD', this.retrieveValueFromKey(EXPERIAN_PASSWORD));
		message.properties.put('EXPERIAN_SUBSCRIBER_NUMBER', this.retrieveValueFromKey(EXPERIAN_SUBSCRIBER_NUMBER));
		message.properties.put('TEST_OR_PRODUCTION', this.retrieveValueFromKey(TEST_OR_PRODUCTION));
		
		//FROM DATA-2094
		message.properties.put('ACCOUNT_PURPOSE_TYPE_CODE', this.retrieveValueFromKey(ACCOUNT_PURPOSE_TYPE_CODE));
		message.properties.put('HARD_ACCOUNT_PURPOSE_TYPE_CODE', this.retrieveValueFromKey(HARD_ACCOUNT_PURPOSE_TYPE_CODE));
		
		message.properties.put('FLAGS_NEWCONSUMER', this.retrieveValueFromKey(FLAGS_NEWCONSUMER));
		message.properties.put('FLAGS_DIRECTCHECK', this.retrieveValueFromKey(FLAGS_DIRECTCHECK));
		message.properties.put('FLAGS_FRAUDSHIELD', this.retrieveValueFromKey(FLAGS_FRAUDSHIELD));
		message.properties.put('FLAGS_DEFERREDPAYMENTINFORMATION', this.retrieveValueFromKey(FLAGS_DEFERREDPAYMENTINFORMATION));
		message.properties.put('FLAGS_ACTUALPAYMENTAMOUNT', this.retrieveValueFromKey(FLAGS_ACTUALPAYMENTAMOUNT));
		message.properties.put('FLAGS_EXPANDEDHISTORY', this.retrieveValueFromKey(FLAGS_EXPANDEDHISTORY));
		message.properties.put('FLAGS_NATIONALRISK', this.retrieveValueFromKey(FLAGS_NATIONALRISK));
		message.properties.put('FLAGS_OLDNATIONAL', this.retrieveValueFromKey(FLAGS_OLDNATIONAL));
		message.properties.put('FLAGS_DEMOGRAPHICS', this.retrieveValueFromKey(FLAGS_DEMOGRAPHICS));
		message.properties.put('FLAGS_SEGMENT130', this.retrieveValueFromKey(FLAGS_SEGMENT130));
		message.properties.put('FLAGS_SCOREPERCENTILE', this.retrieveValueFromKey(FLAGS_SCOREPERCENTILE));
		message.properties.put('FLAGS_HEALTHCAREPROFILE', this.retrieveValueFromKey(FLAGS_HEALTHCAREPROFILE));
		message.properties.put('FLAGS_OFAC', this.retrieveValueFromKey(FLAGS_OFAC));
		message.properties.put('FLAGS_FICO3', this.retrieveValueFromKey(FLAGS_FICO3));
		message.properties.put('FLAGS_FICO8', this.retrieveValueFromKey(FLAGS_FICO8));
								
		message.properties.put('EXPERIANBIZ_SUBSCRIBER_NUMBER', this.retrieveValueFromKey(EXPERIAN_BIZSUBSCRIBER_NUMBER));
		message.properties.put('RISKMODELCODE', this.retrieveValueFromKey(EXPERIAN_RISKMODELCODE));
		message.properties.put('FLAGS_SCORE', this.retrieveValueFromKey(FLAGS_SCORE));
		message.properties.put('FLAGS_BP', this.retrieveValueFromKey(FLAGS_BP));
		
		message.properties.put('FLAGS_CRLK', this.retrieveValueFromKey(FLAGS_CRLK));
		message.properties.put('FLAGS_ITP', this.retrieveValueFromKey(FLAGS_ITP));
		message.properties.put('FLAGS_LIST', this.retrieveValueFromKey(FLAGS_LIST));
		message.properties.put('FLAGS_MATCHCODE', this.retrieveValueFromKey(FLAGS_MATCHCODE));
		message.properties.put('FLAGS_ALLREPORTS', this.retrieveValueFromKey(FLAGS_ALLREPORTS));
		message.properties.put('FLAGS_UCC', this.retrieveValueFromKey(FLAGS_UCC));
		message.properties.put('FLAGS_DATASEGMENT', this.retrieveValueFromKey(FLAGS_DATASEGMENT));
		
		message.properties.put('EXPERIAN_BIZUSER_ID', this.retrieveValueFromKey(EXPERIAN_BIZUSER_ID));
		message.properties.put('EXPERIAN_BIZPASSWORD', this.retrieveValueFromKey(EXPERIAN_BIZPASSWORD));
		
		message.properties.put('PREAMBLE', this.retrieveValueFromKey(PREAMBLE));
		return message;
	}

	@TestVisible
	private virtual class DocManAttachmentHandler {
		@TestVisible
		public virtual void storeDocument(String transactionId, String templateName, Blob docContent) {
			nFUSE.DocManAttachment att = new nFUSE.DocManAttachment(transactionId, REPORT_NAME);
			att.storeDocument(docContent);
		}    
		@TestVisible
		public virtual void storeDocument(String transactionId, String templateName, String templateFileName, Blob docContent) {
			nFUSE.DocManAttachment att = new nFUSE.DocManAttachment(transactionId, REPORT_NAME, templateFileName);
			att.storeDocument(docContent);
		}
	}
	
	/**
	 * Purpose : to load configuration properties for the nFuse.PluginConfigurationManager
	 * Notes : This avoids a null pointer exception when PluginConfiguration is empty, modular for use in other methods
	 *			and outside of the class itself for testing purposes
	*/
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
		throw new XExperianAppFacadeException(X_MISSING_REQUIRED_PROPERTY + ': ' + configKey);
	}
	
	// Purpose : Plugin Configuration List 
	private List<nFUSE.PluginConfigurationManager.PluginConfiguration> configs;
	
	@TestVisible private class XExperianAppFacadeException extends Exception {}
	
	@TestVisible
	private static final String NFUSE_CONFIGURATION_KEYWORD = 'Configuration';
	
	@TestVisible private static String REPORT_NAME = 'Experian_Credit';
	
	@TestVisible private static String X_MISSING_REQUIRED_PROPERTY = 'Missing Experian configured property';
	
	
	public static final String PLUGIN_NAME = 'Experian_Credit',
		PLUGIN_VERSION = '1.0',
		PLUGIN_CONFIG_NAME ='Experian_Credit' + NFUSE_CONFIGURATION_KEYWORD,
		PLUGIN_HELP_TEXT = 'Experian Plugin Category for Property Configuration',
	
		BUSINESS_DAYS_VALID = 'Business Days Valid',
		CONSUMER_DAYS_VALID = 'Consumer Days Valid',
		
		//FROM DATA-2094
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
		EXPERIAN_BIZPASSWORD = 'Encrypted Experian Business Password',
		
		//FROM DATA-1491 aka Boiler Plate 
		COMMERCIAL_PLACEHOLDER_NAME = 'Commercial Credit Placeholder Name',
		COMMERCIAL_APPEND_BUREAU_ID_TO_NAME = 'Append Bureau ID to Commercial Placeholder Name',
		CONSUMER_PLACEHOLDER_NAME = 'Consumer Credit Placeholder Name',
		CONSUMER_APPEND_BUREAU_ID_TO_NAME = 'Append Bureau ID to Consumer Placeholder Name',
		PLACEHOLDER_CATEGORY = 'Credit Report Category',
		APPEND_DATE_TO_PLACEHOLDER_NAME = 'Append Date/Time to Placeholder Name';
}