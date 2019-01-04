/* Trigger on the MMC Email Object
 * Chintan Adhyapak, West Monroe Partners. January 04, 2019
 */
trigger MMCEmailTrigger on MMC_Email__c (after insert) {
    MMCEmailTriggerHandler handler = new MMCEmailTriggerHandler(Trigger.isExecuting, Trigger.size);
	TriggerTransactionUtil ttu = new TriggerTransactionUtil();
  	Static final String triggerName = 'MMCEmailTrigger';
  	
  	System.debug('CPA in ' + triggerName + ' Handler Run Number: ' + MMCEmailTriggerHandler.runs + ' Skip: ' + TriggerTransactionUtil.TriggersToSkip.contains(triggerName)  + ' Cutom Metadata Runs: ' + ttu.Runs(triggerName));

	//Check if trigger is marked to be skipped and also the number of times it should run
  	if (!TriggerTransactionUtil.TriggersToSkip.contains(triggerName) && MMCEmailTriggerHandler.runs++ < ttu.Runs(triggerName)) {
    	if (Trigger.isAfter && Trigger.isInsert) {
       		System.debug('CPA Firing MMC Email After Insert Trigger');
       		handler.onAfterInsert(Trigger.new, Trigger.newMap);
    	}
  	}
}