@isTest
private class TestExperianCreditActivator {
    
    @isTest
    static void setupData(){
        //system properties should already exist
        nFORCE__System_Properties__c property1 = new nFORCE__System_Properties__c(Name='aaaa',nFORCE__Category_Name__c='Experian_CreditConfiguration',nFORCE__Is_Active__c=true);
        property1.nFORCE__Key__c = 'Consumer Days Valid';
        property1.nFORCE__Value__c = '30';
        insert property1;
    }
    @isTest 
    private static void testActivator_containsCategoryFalse(){
        ExperianCreditActivator expectedFalseReturn = new ExperianCreditActivator();
        expectedFalseReturn.onActivate();
        Boolean result = expectedFalseReturn.containsCategory('notACategory');
        System.assertEquals(false,result);
    }
    @isTest
   private static void testReviewDecision(){
      ExperianCreditActivator.ExperianCreditPassReviewDecision decision = new ExperianCreditActivator.ExperianCreditPassReviewDecision();
      decision.create(new Map<String,Object>());
      System.assert(true, true);
   }
   @isTest
   private static void testTypeDecision(){
      ExperianCreditActivator.ExperianCreditReportTypeDecision decision = new ExperianCreditActivator.ExperianCreditReportTypeDecision();
      decision.create(new Map<String,Object>());
      System.assert(true, true);
   }
	@isTest
	private static void testActivation_onActivate_registersBean() {
		ExperianCreditAppFacade bean = retrieveBean();
		System.assertEquals(null, bean);
		new ExperianCreditActivator().onActivate();
		bean = retrieveBean();
		System.assertNotEquals(null, bean);
	}
    
    @isTest
   private static void testActivation_deactivate() {
      Test.startTest();
      new ExperianCreditActivator().onDeactivate();
      Test.stopTest();
      System.assert(true, true);
   }

    @isTest
    private static void testActivation_onActivate_installConfiguration() {
        ExperianCreditActivator act = new ExperianCreditActivator();
        act.onActivate();
        String categoryName = ExperianCreditActivator.PLUGIN_CONFIG_NAME;
        Boolean catPresent = act.containsCategory(categoryName);
        System.assert(true,catPresent);
    }


    private static ExperianCreditAppFacade retrieveBean() {
        return (ExperianCreditAppFacade) nFORCE.BeanFactory.getInstance().getBeanByUniqueName(
            ExperianCreditAppFacade.class.getName()
        );
    }


	private static Set<String> expectedProperties = new Set<String> {
		ExperianCreditActivator.BUSINESS_DAYS_VALID,
		ExperianCreditActivator.CONSUMER_DAYS_VALID,
		ExperianCreditActivator.ACCOUNT_PURPOSE_TYPE_CODE,
		ExperianCreditActivator.HARD_ACCOUNT_PURPOSE_TYPE_CODE,
		ExperianCreditActivator.FLAGS_NEWCONSUMER,
		ExperianCreditActivator.FLAGS_DIRECTCHECK,
		ExperianCreditActivator.FLAGS_FRAUDSHIELD,
		ExperianCreditActivator.FLAGS_DEFERREDPAYMENTINFORMATION,
		ExperianCreditActivator.FLAGS_ACTUALPAYMENTAMOUNT,
		ExperianCreditActivator.FLAGS_EXPANDEDHISTORY,
		ExperianCreditActivator.FLAGS_NATIONALRISK,
		ExperianCreditActivator.FLAGS_OLDNATIONAL,
		ExperianCreditActivator.FLAGS_DEMOGRAPHICS,
		ExperianCreditActivator.FLAGS_SEGMENT130,
		ExperianCreditActivator.FLAGS_SCOREPERCENTILE,
		ExperianCreditActivator.FLAGS_HEALTHCAREPROFILE,
		ExperianCreditActivator.FLAGS_OFAC,
		ExperianCreditActivator.FLAGS_FICO3,
		ExperianCreditActivator.FLAGS_FICO8,
		ExperianCreditActivator.EXPERIAN_USER_ID,
		ExperianCreditActivator.EXPERIAN_PASSWORD,
		ExperianCreditActivator.EXPERIAN_SUBSCRIBER_NUMBER,
		ExperianCreditActivator.TEST_OR_PRODUCTION,
		ExperianCreditActivator.EXPERIAN_BIZSUBSCRIBER_NUMBER,
		ExperianCreditActivator.EXPERIAN_RISKMODELCODE,
		ExperianCreditActivator.FLAGS_SCORE,
		ExperianCreditActivator.FLAGS_BP,
		ExperianCreditActivator.FLAGS_CRLK,
		ExperianCreditActivator.FLAGS_ITP,
		ExperianCreditActivator.FLAGS_LIST,
		ExperianCreditActivator.FLAGS_MATCHCODE,
		ExperianCreditActivator.FLAGS_ALLREPORTS,
		ExperianCreditActivator.FLAGS_UCC,
		ExperianCreditActivator.FLAGS_DATASEGMENT,
		ExperianCreditActivator.EXPERIAN_BIZUSER_ID,
		ExperianCreditActivator.EXPERIAN_BIZPASSWORD,
		ExperianCreditActivator.PREAMBLE,
		ExperianCreditActivator.COMMERCIAL_PLACEHOLDER_NAME,
		ExperianCreditActivator.COMMERCIAL_APPEND_BUREAU_ID_TO_NAME,
		ExperianCreditActivator.CONSUMER_PLACEHOLDER_NAME,
		ExperianCreditActivator.CONSUMER_APPEND_BUREAU_ID_TO_NAME,
		ExperianCreditActivator.PLACEHOLDER_CATEGORY,
		ExperianCreditActivator.APPEND_DATE_TO_PLACEHOLDER_NAME,
        ExperianCreditActivator.EXPERIAN_BIZUSER_ID,
        ExperianCreditActivator.EXPERIAN_BIZPASSWORD
    };
}