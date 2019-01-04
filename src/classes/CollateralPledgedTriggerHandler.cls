/* Handler for the Collateral Pledged Object
 * Chintan Adhyapak, West Monroe Partners. January 19, 2018
 */
public with sharing class CollateralPledgedTriggerHandler {
	/* Before Insert Handler Method	 */
	public static void onBeforeInsert (LLC_BI__Loan_Collateral2__c[] newPledgedCollaterals) {
    	System.debug('CPA Entering CollateralPledgedTriggerHandler OnBeforeInsert');
    	//local vars
    	Map<Id, List<LLC_BI__Loan_Collateral2__c>> newCollateralMap = new Map<Id, List<LLC_BI__Loan_Collateral2__c>> ();
    	Set<Id> existingLoanIdSet = new Set<Id> ();
    	
    	//Loop through the incoming records and save to a map with the loanId as key and a list of all pledged collaterals as value 
    	for (LLC_BI__Loan_Collateral2__c collateral : newPledgedCollaterals) {
    		Id loanId = collateral.LLC_BI__Loan__c;
    		if (!newCollateralMap.containsKey(loanId))
    			newCollateralMap.put(loanId, new List<LLC_BI__Loan_Collateral2__c> ());
    		newCollateralMap.get(loanId).add(collateral);
    	}
    	
    	//Identify incoming loans that already have a Pledged Collateral
    	for (LLC_BI__Loan_Collateral2__c collateral : [Select Id, LLC_BI__Loan__c From LLC_BI__Loan_Collateral2__c Where LLC_BI__Loan__c in :newCollateralMap.keySet()]) {
    		existingLoanIdSet.add(collateral.LLC_BI__Loan__c);
    	}
    	
    	//Loop through the incoming records per loan
    	for (Id loanId : newCollateralMap.keySet()) {
    		//Check that the loan does not already have a pledged collateral. If it does we need to do nothing
    		if (!existingLoanIdSet.contains(loanId)) {
    			LLC_BI__Loan_Collateral2__c targetCollateral = null;
    			//Loop through all incoming pledged collateral records for this loan
    			for (LLC_BI__Loan_Collateral2__c collateral : newCollateralMap.get(loanId)) {
    				if (targetCollateral == null) {
	    				targetCollateral = collateral;
    				} else if (collateral.LLC_BI__Amount_Pledged__c > targetCollateral.LLC_BI__Amount_Pledged__c) {
    					targetCollateral = collateral;
    				}
    			}
    			//Set the primary on the record with the highest amount pledged
	    		targetCollateral.LLC_BI__Is_Primary__c = true;
	    		System.debug('CPA Setting collateral as Primary: ' + targetCollateral);
    		}
    	}
    	System.debug('CPA Exiting CollateralPledgedTriggerHandler OnBeforeInsert');
   	} //onBeforeInsert
	
	
	
  	/* After Delete Handler Method */
  	public static void OnAfterDelete (LLC_BI__Loan_Collateral2__c[] deletedPledgedCollaterals, Map<ID, LLC_BI__Loan_Collateral2__c> pledgedCollateralMap) {
    	System.debug('CPA Entering CollateralPledgedTriggerHandler OnAfterDelete');
    	//local vars
    	Set<Id> loanIdSet = new Set<Id> ();
    	Map<Id, List<LLC_BI__Loan_Collateral2__c>> collateralMap = new Map<Id, List<LLC_BI__Loan_Collateral2__c>> ();
    	List<LLC_BI__Loan_Collateral2__c> collateralToUpdate = new List<LLC_BI__Loan_Collateral2__c> ();
    
    	//Loop through deleted pledged collateral records and collect the loan Ids tied to them
    	for (LLC_BI__Loan_Collateral2__c collateral : deletedPledgedCollaterals) {
    		System.debug('CPA Reading deleted collateral: ' + collateral);
    		loanIdSet.add(collateral.LLC_BI__Loan__c);
    	}
    	
    	//Save in a Map with the loan Id as the key and a list of pledged collateral
    	for (LLC_BI__Loan_Collateral2__c collateral : [Select Id, LLC_BI__Is_Primary__c, LLC_BI__Loan__c, LLC_BI__Amount_Pledged__c, Account__c From LLC_BI__Loan_Collateral2__c Where LLC_BI__Loan__c in :loanIdSet]) {
    		System.debug('CPA Adding existing collateral to Map: ' + collateral);
    		Id loanId = collateral.LLC_BI__Loan__c;
    		if (!collateralMap.containsKey(loanId))
    			collateralMap.put(loanId, new List<LLC_BI__Loan_Collateral2__c> ());
    		collateralMap.get(loanId).add(collateral);
    	}
    	
    	//Ensure that there is at least one Primary Collateral Pledged
    	for (Id loanId : collateralMap.keySet()) {
    		boolean found = false;
    		LLC_BI__Loan_Collateral2__c targetCollateral = null;
    		//Loop through all existing pledged collateral records for this loan
    		for (LLC_BI__Loan_Collateral2__c collateral : collateralMap.get(loanId)) {
    			if (collateral.LLC_BI__Is_Primary__c) {
    				found = true;
    			} else if (targetCollateral == null) {
    				System.debug('CPA setting targetCollateral to: ' + collateral);
    				targetCollateral = collateral;
    			} else if (collateral.LLC_BI__Amount_Pledged__c > targetCollateral.LLC_BI__Amount_Pledged__c) {
    				System.debug('CPA setting targetCollateral to: ' + collateral);
    				targetCollateral = collateral;
    			}
    		}
    		if (!found && targetCollateral != null) {
    			//Set the Primary flag on the record with the highest pledged amount
    			targetCollateral.LLC_BI__Is_Primary__c = true;
    			System.debug('CPA Adding targetCollateral to Update: ' + targetCollateral);
    			collateralToUpdate.add(targetCollateral);
    		}
    	}
    	
    	//update pledged collateral
    	if (!collateralToUpdate.isEmpty())
    		update collateralToUpdate;
    	System.debug('CPA Exiting CollateralPledgedTriggerHandler OnAfterDelete');
  	} //OnAfterDelete
}