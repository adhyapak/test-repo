/* Handler for the User Object Trigger
 * Chintan Adhyapak, West Monroe Partners. September 10, 2018
 */
public without sharing class UserTriggerHandler {

    /* Before Insert Handler Method */
    public static void onBeforeInsert(List<User> newUsers) {
        System.debug('CPA Entering UserTriggerHandler.onBeforeInsert');

        //Populate Federation ID for Member SSO
        populateFederationId(newUsers);

        System.debug('CPA Exiting UserTriggerHandler.onBeforeInsert');
    } //onBeforeInsert
    
    
    
    
    /* If the Customer Portal User checkbox is checked, signifying a Community user, copy the SSO GUID from the 
     * Account tied to the matching Contact to the Federation ID field on the User
     */
    private static void populateFederationId(List<User> newUsers) {
        System.debug('CPA Entering UserTriggerHandler.populateFederationId');

        //local vars
        List<User> userList = new List<User> ();
        List<Id> contactIdlist = new List<Id> ();
        Map<Id, Contact> contactSSOMap;

        //Loop through the incoming users
        for (User user : newUsers) {
            System.debug('CPA user.IsPortalEnabled is: ' + user.IsPortalEnabled + ' and Contact is: ' + user.ContactId);
            //System.debug('CPA SSO GUID is: ' + user.Contact.Account.SSO_GUID__c);
            if (user.ContactId != null) {
                userList.add(user);
                contactIdList.add(user.ContactId);
            }
        }
        System.debug('CPA contactIdList is: ' + contactIdList);
        System.debug('CPA userList is: ' + userList);
        
        //Get the SSO GUID From the Contact->Account
        if (!contactIdList.isEmpty()) {
            contactSSOMap = new Map<Id, Contact>([Select Id, Account.SSO_GUID__c From Contact Where Id in :contactIdList]);
            System.debug('CPA contactSSOMap is: ' + contactSSOMap);
        }
        
        //Populate the GUID on the User records
        for (User user : userList) {
        	if (contactSSOMap.get(user.ContactId) != null && contactSSOMap.get(user.ContactId).AccountId != null && contactSSOMap.get(user.ContactId).Account.SSO_GUID__c != null) {
        		String accountGuid = contactSSOMap.get(user.ContactId).Account.SSO_GUID__c;
        		System.debug('CPA For User: ' + user.FirstName + ' ' + user.LastName + ' setting GUID to: ' + accountGuid);
            	user.FederationIdentifier = String.isBlank(accountGuid) ? null : accountGuid.replaceFirst('^\\{', '').replaceFirst('\\}$', '');
        	}
        }
        
        System.debug('CPA Exiting UserTriggerHandler.populateFederationId');
    } //populateFederationId
}