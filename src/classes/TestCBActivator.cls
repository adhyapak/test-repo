@isTest
private class TestCBActivator{
    
    @isTest
	private static void testActivation_onActivate_addsConfigs() {
		new CBActivator().onActivate();
		
		CBConfiguration config = new CBConfiguration();
		
		System.assertEquals(9, config.GetAllProperties(true).size());
	}
	
	@isTest
	private static void testActivation_onDeactivate_setsConfigsInactive() {
		new CBActivator().onDeactivate();
		
		CBConfiguration config = new CBConfiguration();
		System.assertEquals(0, config.GetAllProperties(true).size()); //should be zero since they are disabled
	}
	
	@isTest
	private static void testActivation_onDeactivate_setsConfigsInactive_Then_Reactive() {
		new CBActivator().onDeactivate();
		
		CBConfiguration config = new CBConfiguration();
		System.assertEquals(0, config.GetAllProperties(true).size()); //should be zero since they are disabled
		
		new CBActivator().onActivate();
		
		System.assertEquals(9, config.GetAllProperties(true).size());
	}

}