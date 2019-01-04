/**
 * Batch process to update the ExcludeFromExposureCalc field on all Household records
 *
 * @author Chintan Adhyapak, West Monroe Partners
 * @created 10/25/2017
 *
 */
global class BatchSetExcludeFromExposureCalc implements Database.Batchable<sObject> {
	//local vars
	global String recordTypeId;
	global Map<Id, Set<Id>> household2HouseholdmemberMap;
	global Map<Id, Set<LLC_BI__Legal_Entities__c>> household2EntityInvolvementMap;
	global Map<Id, Set<LLC_BI__Loan__c>> household2LoanMap;
	global Map<Id, Decimal> household2AmountMap;

	// The start method returns a SOQL query locator containing the records to be worked on
	global Database.QueryLocator start(Database.BatchableContext BC) {
		//Get the RecordTypeId for the Household Account record
		recordTypeId = [SELECT Id, Name, sObjectType FROM RecordType Where sObjectType ='Account' and Name = 'Household'][0].Id;
		System.debug('CPA Household Record Id is: ' + recordTypeId);
		
		return Database.getQueryLocator('SELECT LLC_BI__Connected_From__c, LLC_BI__Connected_To__c FROM LLC_BI__Connection__c WHERE LLC_BI__Connected_From__r.RecordTypeId = \'' + recordTypeId + '\' AND  LLC_BI__Connected_From__r.Total_Relationship_Exposure__c> 0 AND LLC_BI__Connection_Role__r.Name = \'Household Member\'');
	} //start


	// The execute method is called for each chunk of records returned from start
	global void execute(Database.BatchableContext BC, List<sObject> scope) {
		List<LLC_BI__Connection__c> connections = (List<LLC_BI__Connection__c>)scope;
		
		//Initialize Maps
		household2HouseholdmemberMap = new Map<Id, Set<Id>>();
		household2EntityInvolvementMap = new Map<Id,Set<LLC_BI__Legal_Entities__c>>();
		household2LoanMap = new Map<Id, Set<LLC_BI__Loan__c>>();
		household2AmountMap = new Map<Id, Decimal>();
		
		//Loop through the connection records to populate the household2HouseholdmemberMap
		for (LLC_BI__Connection__c connection : connections) {
			System.debug('CPA Read connection: ' + connection);
			if (household2HouseholdmemberMap == null) System.debug('CPA household2HouseholdmemberMap is null');
			//Create a Map record if one does not exist
			if (!household2HouseholdmemberMap.containsKey(connection.LLC_BI__Connected_From__c))
				household2HouseholdmemberMap.put(connection.LLC_BI__Connected_From__c, new Set<Id>());
			
			//Add the Household member to the set matching its household
			household2HouseholdmemberMap.get(connection.LLC_BI__Connected_From__c).add(connection.LLC_BI__Connected_To__c);
		}
		System.debug('CPA household2HouseholdmemberMap is: ' + household2HouseholdmemberMap);
		
		//Loop through the Household Member account records and collect the Entity Involvement records tied to them
		for (Id householdId : household2HouseholdmemberMap.keySet()) {
			//Create a Map record if one does not exist
			if (!household2EntityInvolvementMap.containsKey(householdId))
				household2EntityInvolvementMap.put(householdId, new Set<LLC_BI__Legal_Entities__c>());
		
			//Add all EIs tied to any of the household members tied to this household
			household2EntityInvolvementMap.get(householdId).addAll([SELECT Id, LLC_BI__Loan__c, LLC_BI__Account__c, LLC_BI__Loan__r.LLC_BI__Principal_Balance__c FROM LLC_BI__Legal_Entities__c WHERE LLC_BI__Loan__r.LLC_BI__Product_Reference__r.Exclude_from_exposure__c = true AND LLC_BI__Account__c IN :household2HouseholdmemberMap.get(householdId)]);
		}
		System.debug('CPA household2EntityInvolvementMap is: ' + household2EntityInvolvementMap);
		
		//Loop through all the Entity Invovlement records for a household and collect the loan amounts for distinct Loans tied to them
		for (Id householdId : household2EntityInvolvementMap.keySet()) {
			System.debug('CPA working on Household ID: ' + householdId);
			//Set of loanIds for current household
			Set<Id> loanIdSet = new Set<Id>();
			//Loop through all the Entity Involvement records for the household
			for (LLC_BI__Legal_Entities__c ei : household2EntityInvolvementMap.get(householdId)) {
				System.debug('CPA Working on EI: ' + ei);
				//If loan tied to the entity involvement is already in the set, ignore it, else store principal balance
				if (!loanIdSet.contains(ei.LLC_BI__Loan__c)) {
					System.debug('CPA Qualifying Loan Found: ' + ei.LLC_BI__Loan__c);
					//Is household already has a loan tied to it, get its amount so we can add to it 
					if (household2AmountMap.containsKey(householdId)) {
						Decimal amount = household2AmountMap.get(householdId);
						System.debug('CPA Existing amount found: ' + amount);
						System.debug('CPA Adding to Existing Amount: ' + ei.LLC_BI__Loan__r.LLC_BI__Principal_Balance__c);
						household2AmountMap.put(householdId, amount + ei.LLC_BI__Loan__r.LLC_BI__Principal_Balance__c);
					} else {
						System.debug('CPA Adding New Amount: ' + ei.LLC_BI__Loan__r.LLC_BI__Principal_Balance__c);
						household2AmountMap.put(householdId, ei.LLC_BI__Loan__r.LLC_BI__Principal_Balance__c);
					}
					//Add Loan Id to Set
					loanIdSet.add(ei.LLC_BI__Loan__c);
				} else {
					System.debug('CPA Duplicate Loan Found: ' + ei.LLC_BI__Loan__c);
				}
			}
		}
		System.debug('CPA household2AmountMap is: ' + household2AmountMap);
		
		//Pull all the Household Account Records for updating
		Map<Id, Account>accountMap = new Map<Id, Account>([Select Id, Excluded_Exposure__c, Excluded_Exposure_Last_Updated__c FROM Account Where Id in :household2AmountMap.keySet()]);
		for (Id householdId : accountMap.keySet()) {
			Account household = accountMap.get(householdId);
			System.debug('CPA Setting Excluded Amount for Household Id ' + householdId + ' to ' + household2AmountMap.get(householdId));
			household.Excluded_Exposure__c = household2AmountMap.get(householdId);
			household.Excluded_Exposure_Last_Updated__c = System.now();
			accountMap.put(householdId, household);
		}
		
		//Update the Household Account records
		update accountMap.values();
	} //execute
	

	// // The finish method is called at the end of each calculation
	global void finish(Database.BatchableContext BC) {
	} //finish
} //BatchSetExcludeFromExposureCalc