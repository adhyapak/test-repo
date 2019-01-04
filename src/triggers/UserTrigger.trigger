/* Trigger on the User Object
 * Chintan Adhyapak, West Monroe Partners. September 10, 2018
 */
trigger UserTrigger on User (before insert) {
    //Only run if User.No_Triggers__c is not checked. This allows nCino data load users, for example, to bypass the trigger
	boolean isNoTriggers = [Select No_Triggers__c From User Where Id = :UserInfo.getUserId()][0].No_Triggers__c;
	System.debug('CPA In UserTrigger isNoTriggers for Current User is: ' + isNoTriggers);
	if (!isNoTriggers) {
    	if (Trigger.isBefore && Trigger.isInsert) {
    		//Before Insert
    		UserTriggerHandler.onBeforeInsert(Trigger.new);
    	}
	}
}