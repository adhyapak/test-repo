/* Trigger on the Loan Object
 * Chintan Adhyapak, West Monroe Partners. January 25, 2018
 */
trigger LoanTrigger on LLC_BI__Loan__c (after delete, after insert, after undelete, after update, before delete, before insert, before update) {
	//Only run if User.No_Triggers__c is not checked. This allows nCino data load users to bypass all triggers
	//boolean isNoTriggers = [Select No_Triggers__c From User Where Id = :UserInfo.getUserId()][0].No_Triggers__c;
	//System.debug('CPA In LoanTrigger isNoTriggers for Current User is: ' + isNoTriggers);
	
	WMPLoanTriggerHandler handler = new WMPLoanTriggerHandler(Trigger.isExecuting, Trigger.size);
	TriggerTransactionUtil ttu = new TriggerTransactionUtil();
  	Static final String triggerName = 'LoanTrigger';
  	
  	System.debug('CPA in ' + triggerName + ' Handler Run Number: ' + WMPLoanTriggerHandler.runs + ' Skip: ' + TriggerTransactionUtil.TriggersToSkip.contains(triggerName)  + ' Cutom Metadata Runs: ' + ttu.Runs(triggerName));
  	
	//if (!isNoTriggers) {
    	if (Trigger.isBefore && Trigger.isInsert) {
    		//Before Insert
    		handler.onBeforeInsert(Trigger.new);
    	} else if (Trigger.isBefore && Trigger.isUpdate) {
	    	//Before Update
    		handler.onBeforeUpdate(Trigger.old, Trigger.new, Trigger.oldMap, Trigger.newMap);
    	} else if(Trigger.isAfter && Trigger.isUpdate) {
	    	//After Update
    		handler.OnAfterUpdate(Trigger.old, Trigger.new, Trigger.oldMap, Trigger.newMap);
    	}
	//}
}