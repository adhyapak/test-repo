/* Handler for the Account Object Trigger
 * Chintan Adhyapak, West Monroe Partners. April 16, 2018
 */
public without sharing class AccountTriggerHandler {
	//Class variables  
  	public static Integer runs = 0;
  	private boolean m_isExecuting = false;
  	private integer batchSize = 0;
  	
  	//Constructor
  	public AccountTriggerHandler(boolean isExecuting, integer size) {
    	m_isExecuting = isExecuting;
    	batchSize = size;
  	} //AccountTriggerHandler
  	
  	
  	//
  	//Public Methods
  	//
   	
   	/* After Update Handler Method */
 	public void OnAfterUpdate(List<Account> oldAccounts, List<Account> updatedAccounts, Map<Id, Account> oldAccountMap, Map<Id, Account> updatedAccountMap) {
    	System.debug('CPA Entering AccountTriggerHandler.OnAfterUpdate');

    	//Populate the FederationID on User records for Portal Users
		populateFederationId(oldAccounts, updatedAccounts, oldAccountMap, updatedAccountMap);

    	System.debug('CPA Exiting AccountTriggerHandler.OnAfterUpdate');
   	} //OnAfterUpdate
	
	
    
    
    /* Set the Federation Id on Users for Portal Users */
    private void populateFederationId(List<Account> oldAccounts, List<Account> updatedAccounts, Map<Id, Account> oldAccountMap, Map<Id, Account> updatedAccountMap) {
    	System.debug('CPA Entering AccountTriggerHandler.populateFederationId');
    	
    	//local vars
    	List<Id> accountIdList = new List<Id> ();

    	//Loop through the incoming Accounts and add qualifying accounts to a List 
    	for (Id accountId : oldAccountMap.keySet()) {
    		Account oldAccount = oldAccountMap.get(accountId);
    		Account updatedAccount = updatedAccountMap.get(accountId);
    		if ((oldAccount.SSO_GUID__c == null && updatedAccount.SSO_GUID__c != null) ||
    				(oldAccount.SSO_GUID__c != null && updatedAccount.SSO_GUID__c == null) ||
    				(oldAccount.SSO_GUID__c != null && updatedAccount.SSO_GUID__c != null && oldAccount.SSO_GUID__c != updatedAccount.SSO_GUID__c)) {
    			accountIdList.add(accountId);
    		}
    	}
    	System.debug('CPA accountIdList is: ' + accountIdList);
    	
    	//Pass the accountId list to a @future method to update Users
    	if (!accountIdList.isEmpty()) {
    	    AccountTriggerHandler.updateUsers(accountIdList);
    	}
    	
    	System.debug('CPA Exiting AccountTriggerHandler.populateFederationId');
    } //populateFederationId
    
    
    
    //Future method to update Users to avoid Mixed DML operation error
    @future
    private static void updateUsers(List<Id> accountIdList) {
    	System.debug('CPA Entering @future AccountTriggerHandler.updateUsers');
    	//local vars
    	Map<Id, Contact> contactMap;
    	List<User> usersToUpdate = new List<User> ();
    	
    	//Find Matching Contacts for these Accounts and store in a Map with the Contact Id as the key
    	contactMap = new Map<Id, Contact> ([Select Id, Name, Account.SSO_GUID__c From Contact Where AccountId in :accountIdList]);
    	System.debug('CPA contactMap is: ' + contactMap);
    	
    	//Find Users tied to the contacts and update their Federation Id
    	if (contactMap != null && !contactMap.isEmpty()) {
    		for (User user : [Select Id, FederationIdentifier, ContactId From User Where ContactId in :contactMap.keySet()]) {
    			String accountGuid = contactMap.get(user.ContactId).Account.SSO_GUID__c;
	    		user.FederationIdentifier = String.isBlank(accountGuid) ? null : accountGuid.replaceFirst('^\\{', '').replaceFirst('\\}$', '');
    			usersToUpdate.add(user);
    		}
    		System.debug('CPA usersToUpdate is: ' + usersToUpdate);
    	
    		//Update these users
    		if (!usersToUpdate.isEmpty()) {
	    		update usersToUpdate;
    		}
    	}
    	System.debug('CPA Exiting @future AccountTriggerHandler.updateUsers');
    } //updateUsers
}