/* Trigger on the Account Object
 * Chintan Adhyapak, West Monroe Partners. April 16, 2018
 */
trigger AccountTrigger on Account (after update) {
	//Only run if User.No_Triggers__c is not checked. This allows nCino data load users, for example, to bypass the trigger
	//boolean isNoTriggers = [Select No_Triggers__c From User Where Id = :UserInfo.getUserId()][0].No_Triggers__c;
	//System.debug('CPA In AccountTrigger isNoTriggers for Current User is: ' + isNoTriggers);
	
	AccountTriggerHandler handler = new AccountTriggerHandler(Trigger.isExecuting, Trigger.size);
	TriggerTransactionUtil ttu = new TriggerTransactionUtil();
  	Static final String triggerName = 'AccountTrigger';
  	
  	System.debug('CPA in ' + triggerName + ' Handler Run Number: ' + AccountTriggerHandler.runs + ' Skip: ' + TriggerTransactionUtil.TriggersToSkip.contains(triggerName)  + ' Cutom Metadata Runs: ' + ttu.Runs(triggerName));

	//if (!isNoTriggers) {
		//Check if trigger is marked to be skipped and also the number of times it should run
  		if (!TriggerTransactionUtil.TriggersToSkip.contains(triggerName) && AccountTriggerHandler.runs++ < ttu.Runs(triggerName)) { 
    		if (Trigger.isAfter && Trigger.isUpdate) {
        		System.debug('CPA Firing Account After Update Trigger');
        		//After Update
        		handler.onAfterUpdate(Trigger.old, Trigger.new, Trigger.oldMap, Trigger.newMap);
    		}
  		}
	//}
}