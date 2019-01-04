/* Trigger on the Collateral Pledged Object
 * Chintan Adhyapak, West Monroe Partners. January 19, 2018
 */
trigger CollateralPledgedTrigger on LLC_BI__Loan_Collateral2__c (after delete, after insert, after undelete, after update, before delete, before insert, before update) {
    //Only run if User.No_Triggers__c is not checked. This allows nCino data load users to bypass all triggers
	boolean isNoTriggers = [Select No_Triggers__c From User Where Id = :UserInfo.getUserId()][0].No_Triggers__c;
	System.debug('CPA In CollateralPledgedTrigger isNoTriggers for Current User is: ' + isNoTriggers);
	if (!isNoTriggers) {
    	if (Trigger.isInsert && Trigger.isBefore) {
	    	//Before Insert
      		CollateralPledgedTriggerHandler.OnBeforeInsert(Trigger.new);
    	} else if (Trigger.isDelete && Trigger.isAfter) {
	    	//After Delete
      		CollateralPledgedTriggerHandler.OnAfterDelete(Trigger.old, Trigger.oldMap);
    	}
	}
}