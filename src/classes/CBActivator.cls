/**
 * @author nCino
 * Implements the IPlugin Activator Interface and creates SystemProperties,
 * SystemConfiguration, and registers a bean for the CreditAppFacade on Activate.
 * Then does nothing on deactivate.
 **/
global with sharing class CBActivator implements nFUSE.IPluginActivator {
	
	@testVisible
	private CBConfiguration config = new CBConfiguration();
	@testVisible
	private nFUSE.ServiceLocator locator = new nFUSE.ServiceLocator();
	
	public void onActivate() {
		
		config.LoadPluginConfigurations();
        config.TogglePluginConfigurations(true);
        
        nFUSE.PackageServiceRequest request = new nFUSE.PackageServiceRequest(CBConfiguration.PLUGIN_NAME, CBConfiguration.PLUGIN_VERSION, null);
		locator.register(request, nFUSE.SendService.class, CBLoanSendService.class, CBConfiguration.LOANSENDSERVICENAME);
		locator.register(request, nFUSE.SendService.class, CBCustomerSendService.class, CBConfiguration.CUSTOMERSENDSERVICENAME);
		locator.register(request, nFUSE.SendService.class, CBDepositSendService.class, CBConfiguration.DEPOSITSENDSERVICENAME);
        
	}
	public void onDeactivate() {
		
		config.TogglePluginConfigurations(false);
        
        nFUSE.PackageServiceRequest request = new nFUSE.PackageServiceRequest(CBConfiguration.PLUGIN_NAME, CBConfiguration.PLUGIN_VERSION, null);
		locator.deregister(request, nFUSE.SendService.class, CBConfiguration.LOANSENDSERVICENAME);
		locator.deregister(request, nFUSE.SendService.class, CBConfiguration.CUSTOMERSENDSERVICENAME);
		locator.deregister(request, nFUSE.SendService.class, CBConfiguration.DEPOSITSENDSERVICENAME);
        
	}
}