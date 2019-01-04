/* Handler for the Loan Object Trigger
 * Chintan Adhyapak, West Monroe Partners. January 25, 2018
 */
public without sharing class WMPLoanTriggerHandler {
	//class variables
	private static final String CHECKING = 'Checking';
	private static final String SAVINGS = 'Savings';
	private static final String PRIMARY_OWNER = 'Primary Owner';
	private static final String VALID_STATUS = 'VALID';
	private static final String INVALID_STATUS = 'INVALID';
	private static final String CREDITCARD = 'Credit Card';
	private static final String FROM_STAGE = 'Decisioning';
    private static final String TO_STAGE = 'Doc Prep/Due Diligence';
    private static final String LOAN_BOOKED = 'Booked';
    private static final String LOAN_COMPLETE = 'Complete';
  	public static Integer runs = 0;
  	private boolean m_isExecuting = false;
  	private integer batchSize = 0;
  	
  	//Constructor
  	public WMPLoanTriggerHandler(boolean isExecuting, integer size) {
    	m_isExecuting = isExecuting;
    	batchSize = size;
  	} //WMPLoanTriggerHandler
  	
  	
  	
  	//
  	//Public Methods
  	//

	/* Before Insert Handler Method */
	public void onBeforeInsert(List<LLC_BI__Loan__c> newLoans) {
		System.debug('CPA Entering WMPLoanTriggerHandler.onBeforeInsert');

		//Populate Checking Account Status for CLOC Loans
		populateCheckingAccountStatus(newLoans);

		//Populate Primary Savings Account for TSYS Loans
		populatePrimarySavingsAccount(newLoans);

		//Populate Household for Loans
		populateHousehold(newLoans);
		
		//Populate Savings Account Status for SFBL and TSYS Loans
		populateSavingsAccountStatus(newLoans);

		System.debug('CPA Exiting WMPLoanTriggerHandler.onBeforeInsert');
	} //onBeforeInsert



	/* Before Update Handler Method */
 	public void OnBeforeUpdate(LLC_BI__Loan__c[] oldLoans, LLC_BI__Loan__c[] updatedLoans, Map<ID, LLC_BI__Loan__c> oldLoanMap, Map<ID, LLC_BI__Loan__c> updatedLoanMap) {
    	System.debug('CPA Entering WMPLoanTriggerHandler.OnBeforeUpdate');

    	//Populate Checking Account Status for CLOC Loans
		populateCheckingAccountStatus(oldLoans, updatedLoans, oldLoanMap, updatedLoanMap);

		//Populate Primary Savings Account for TSYS Loans
		populatePrimarySavingsAccount(oldLoans, updatedLoans, oldLoanMap, updatedLoanMap);

		//Populate Household for Loans
		populateHousehold(oldLoans, updatedLoans, oldLoanMap, updatedLoanMap);
		
		//Populate Savings Account Status for SFBL and TSYS Loans
		populateSavingsAccountStatus(oldLoans, updatedLoans, oldLoanMap, updatedLoanMap);

    	System.debug('CPA Exiting WMPLoanTriggerHandler.OnBeforeUpdate');
   	} //OnBeforeUpdate



	/* After Update Handler Method */
    public void OnAfterUpdate(LLC_BI__Loan__c[] oldLoans, LLC_BI__Loan__c[] updatedLoans, Map<ID, LLC_BI__Loan__c> oldLoanMap,  Map<ID, LLC_BI__Loan__c> newLoanMap) {
    	System.debug('CPA Entering WMPLoanTriggerHandler.OnAfterUpdate');

		//Set Primary Pledged Collateral
		setPrimaryPledgedCollateral(oldLoans, updatedLoans, oldLoanMap, newLoanMap);

		//Auto create AdverseAction
		createAdverseAction(newLoanMap);

		//Set product package approval process
		//No longer needed, per Brandon 05/25/2018
		//updateProductPackage(newLoanMap);
		
		//Populate Member Access Number on Accounts
		populateMemberAccessNumber(oldLoans, updatedLoans, oldLoanMap, newLoanMap);
		
		//Modify the Borrower Type on existing Entity Involvement records
		modifyBorrowerType(oldLoans, updatedLoans, oldLoanMap, newLoanMap);

    	System.debug('CPA Exiting WMPLoanTriggerHandler.onAfterUpdate');
 	} //OnAfterUpdate



 	/* Inner class to represent a Savings Account */
    @TestVisible
    public class SavingsAccount implements Comparable {
        String accountNumber;
        Decimal amount;

        //Constructor
        @TestVisible
        SavingsAccount(String acctNbr, Decimal amt) {
            accountNumber = acctNbr;
            amount = amt;
        }

        //Implement the compareTo() method
    	public Integer compareTo(Object compareTo) {
        	SavingsAccount compareToAccount = (SavingsAccount)compareTo;
        	if (amount == compareToAccount.amount) return 0;
        	if (amount > compareToAccount.amount) return -1;
        	return 1;
    	} //compareTo
    } //SavingsAccount



    /* If a checking account is populated on the loan, signifying a CLOC Loan, set the Checking Account Status
	 * field based on if the account is tied to the primary borrower of the loan
     */
    private void populateCheckingAccountStatus(List<LLC_BI__Loan__c> newloans) {
    	System.debug('CPA Entering WMPLoanTriggerHandler.populateCheckingAccountStatus');

    	//local vars
    	List<Id> borrowerList = new List<Id> ();
    	Map<Id, Set<String>> borrowerToDepositMap = new Map<Id, Set<String>> ();
    	List<LLC_BI__Loan__c> loansToUpdate = new List<LLC_BI__Loan__c> ();

    	//Loop through the incoming loans and save the Primary Borrowers for the ones where the Checking Account is populated
    	for (LLC_BI__Loan__c loan : newLoans) {
    		if (loan.LLC_BI__Account__c != null && !String.isBlank(loan.Checking_Account__c)) {
    			borrowerList.add(loan.LLC_BI__Account__c);
      			loansToUpdate.add(loan);
      			System.debug('CPA Borrower: ' + loan.LLC_BI__Account__c + ' has Checking Account: ' + loan.Checking_Account__c);
    		}
    	}

    	//For these Borrowers, find all checking account numbers where they are the Primary Owner
    	for (LLC_BI__Legal_Entities__c ei : [Select LLC_BI__Account__c, LLC_BI__Deposit__r.LLC_BI__Account_Number__c From LLC_BI__Legal_Entities__c
    			Where LLC_BI__Account__c in :borrowerList
				and LLC_BI__Deposit__c <> null
				and LLC_BI__Relationship_Type__c = :PRIMARY_OWNER
				and LLC_BI__Deposit__r.LLC_BI__Product_Reference__r.LLC_BI__Product_Type__r.Name = :CHECKING]) {
			if (borrowerToDepositMap.get(ei.LLC_BI__Account__c) == null)
				borrowerToDepositMap.put(ei.LLC_BI__Account__c, new Set<String>());
			borrowerToDepositMap.get(ei.LLC_BI__Account__c).add(ei.LLC_BI__Deposit__r.LLC_BI__Account_Number__c.trim());
		}
		System.debug('CPA Borrower to Checking Account Map is: ' + borrowerToDepositMap);

    	//Set the loan Check Account Status field is the Checking Account is valid
    	for (LLC_BI__Loan__c loan : loansToUpdate) {
    		if (borrowerToDepositMap.get(loan.LLC_BI__Account__c) != null && borrowerToDepositMap.get(loan.LLC_BI__Account__c).contains(loan.Checking_Account__c.trim()))
    			loan.Checking_Account_Status__c = VALID_STATUS;
    		else
    			loan.Checking_Account_Status__c = INVALID_STATUS;
    		System.debug('CPA Set the Checking Account Status for loan Name ' + loan.Name + ' to: ' + loan.Checking_Account_Status__c);
    	}

    	System.debug('CPA Exiting WMPLoanTriggerHandler.populateCheckingAccountStatus');
    } //populateCheckingAccountStatus



 	/* If a checking account is populated on the loan, signifying a CLOC Loan, set the Checking Account Status
	 * field based on if the account is tied to the primary borrower of the loan
     */
 	private void populateCheckingAccountStatus(List<LLC_BI__Loan__c> oldLoans, List<LLC_BI__Loan__c> updatedLoans, Map<ID, LLC_BI__Loan__c> oldLoanMap, Map<ID, LLC_BI__Loan__c> updatedloanMap) {
    	System.debug('CPA Entering WMPLoanTriggerHandler.populateCheckingAccountStatus');

    	//local vars
    	Map<Id, Id> loanToBorrowerMap = new Map<Id, Id> ();
    	Map<Id, Set<String>> borrowerToDepositMap = new Map<Id, Set<String>> ();
    	List<LLC_BI__Loan__c> loansToUpdate = new List<LLC_BI__Loan__c> ();

    	//Loop through the incoming loans and save the Primary Borrowers for the ones where the Checking Account has changed
    	for (Id loanId : oldLoanMap.keySet()) {
    		if (String.isBlank(updatedLoanMap.get(loanId).Checking_Account__c))
    			updatedLoanMap.get(loanId).Checking_Account_Status__c = null;
    		else if (String.isBlank(oldLoanMap.get(loanId).Checking_Account__c) && !String.isBlank(updatedLoanMap.get(loanId).Checking_Account__c)) {
    			System.debug('CPA Checking Account Changed for Borrower: ' + updatedLoanMap.get(loanId).LLC_BI__Account__c + ' Account: ' + updatedLoanMap.get(loanId).Checking_Account__c);
    			loanToBorrowerMap.put(loanId, updatedLoanMap.get(loanId).LLC_BI__Account__c);
    			loansToUpdate.add(updatedloanMap.get(loanId));
    		} else if (!oldLoanMap.get(loanId).Checking_Account__c.equals(updatedLoanMap.get(loanId).Checking_Account__c)) {
    			System.debug('CPA Checking Account Changed for Borrower: ' + updatedLoanMap.get(loanId).LLC_BI__Account__c + ' Account: ' + updatedLoanMap.get(loanId).Checking_Account__c);
    			loanToBorrowerMap.put(loanId, updatedLoanMap.get(loanId).LLC_BI__Account__c);
    			loansToUpdate.add(updatedloanMap.get(loanId));
    		}
    	}
    	System.debug('CPA Loans where Checking Number has changed are: ' + loanToBorrowerMap.keySet());

    	//For these Borrowers, find all checking account numbers where they are the Primary Owner
    	for (LLC_BI__Legal_Entities__c ei : [Select LLC_BI__Account__c, LLC_BI__Deposit__r.LLC_BI__Account_Number__c From LLC_BI__Legal_Entities__c
    			Where LLC_BI__Account__c in :loanToBorrowerMap.values()
				and LLC_BI__Deposit__c <> null
				and LLC_BI__Relationship_Type__c = :PRIMARY_OWNER
				and LLC_BI__Deposit__r.LLC_BI__Product_Reference__r.LLC_BI__Product_Type__r.Name = :CHECKING]) {
			if (borrowerToDepositMap.get(ei.LLC_BI__Account__c) == null)
				borrowerToDepositMap.put(ei.LLC_BI__Account__c, new Set<String>());
			borrowerToDepositMap.get(ei.LLC_BI__Account__c).add(ei.LLC_BI__Deposit__r.LLC_BI__Account_Number__c.trim());
		}
		System.debug('CPA Checking Account Numbers found are: ' + borrowerToDepositMap);

    	//Set the loan Check Account Status field is the Checking Account is valid
    	for (LLC_BI__Loan__c loan : loansToUpdate) {
    		if (borrowerToDepositMap.get(loan.LLC_BI__Account__c) != null && (borrowerToDepositMap.get(loan.LLC_BI__Account__c)).contains(loan.Checking_Account__c.trim()))
    			loan.Checking_Account_Status__c = VALID_STATUS;
    		else
    			loan.Checking_Account_Status__c = INVALID_STATUS;
    		System.debug('CPA Set the Checking Account Status for loan Name ' + loan.Name + ' to: ' + loan.Checking_Account_Status__c);
    	}
    	System.debug('CPA Exiting WMPLoanTriggerHandler.populateCheckingAccountStatus');
   	} //populateCheckingAccountStatus



	/* If Loan moves from Decisioning to Doc Prep/Due Diligence and the loan has pledged collateral
	 * ensure that there is at least one pledged collateral is marked as Primary
   	 */
   	private void setPrimaryPledgedCollateral(List<LLC_BI__Loan__c> oldLoans, List<LLC_BI__Loan__c> updatedLoans, Map<ID, LLC_BI__Loan__c> oldLoanMap,  Map<ID, LLC_BI__Loan__c> newLoanMap) {
   		System.debug('CPA Entering WMPLoanTriggerHandler.setPrimaryPledgedCollateral');

    	Set<Id> loanIdSet = new Set<Id> ();
    	List<LLC_BI__Loan_Collateral2__c> collateralToUpdate = new List<LLC_BI__Loan_Collateral2__c> ();
    	Map<Id, List<LLC_BI__Loan_Collateral2__c>> collateralMap = new Map<Id, List<LLC_BI__Loan_Collateral2__c>> ();

    	//Loop through the incoming loans and save the ones which are entering Doc Prep stage
    	for (Id loanId : oldLoanMap.keySet()) {
    		if (oldLoanMap.get(loanId).LLC_BI__Stage__c.equals(FROM_STAGE) && newLoanMap.get(loanId).LLC_BI__Stage__c.equals(TO_STAGE)) {
    			loanIdSet.add(loanId);
    		}
    	}
    	System.debug('CPA Loans where stage changed to doc prep are: ' + loanIdSet);

    	//Save the pledged collateral records for these loans in a Map with the loan Id as the key and a list of pledged collaterals as values
    	for (LLC_BI__Loan_Collateral2__c collateral : [Select Id, LLC_BI__Is_Primary__c, LLC_BI__Loan__c, LLC_BI__Amount_Pledged__c, Account__c From LLC_BI__Loan_Collateral2__c Where LLC_BI__Loan__c in :loanIdSet]) {
    		System.debug('CPA Adding existing collateral to Map: ' + collateral);
    		Id loanId = collateral.LLC_BI__Loan__c;
    		if (!collateralMap.containsKey(loanId))
    			collateralMap.put(loanId, new List<LLC_BI__Loan_Collateral2__c> ());
    		collateralMap.get(loanId).add(collateral);
    	}

    	//Ensure that there is at least one Primary Collateral Pledged per loan
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
    	if (!collateralToUpdate.isEmpty())
    		update collateralToUpdate;

    	System.debug('CPA Exiting WMPLoanTriggerHandler.setPrimaryPledgedCollateral');
   	} //setPrimaryPledgedCollateral



	/* Create an adverse action for a loan if the loan is flagged for auto creating an adverse action
	 * and the loan does not already have a related adverse action
	 */
   	private void createAdverseAction(Map<ID, LLC_BI__Loan__c> newLoanMap) {
		System.debug('CPA Entering WMPLoanTriggerHandler.createAdverseAction');

		//local vars
		Set<Id> loanIdSet = new Set<Id> ();
		Map<Id, LLC_BI__Legal_Entities__c> eiMap = new Map<Id, LLC_BI__Legal_Entities__c> ();
		List<LLC_BI__Adverse_Action__c> adverseActionsToAdd = new List<LLC_BI__Adverse_Action__c> ();

		//Loop through the incoming loans and save the ones that request an adverse action
		for (Id loanId : newLoanMap.keySet()) {
			if(newLoanMap.get(loanId).Auto_Create_Adverse_Action__c == true) {
				loanIdSet.add(loanId);
				System.debug('Loan is requesting an Adverse Action: ' + loanId);
			}
		}

		//Save the Legal Entities that are Borrowers for these loans into a map
		for (LLC_BI__Legal_Entities__c ei : [Select Id, LLC_BI__Loan__c, LLC_BI__Account__c From LLC_BI__Legal_Entities__c Where LLC_BI__Borrower_Type__c = 'Borrower' and LLC_BI__Loan__c in :loanIdSet Limit 1]) {
			System.debug('CPA Adding existing ei to Map: ' + ei);
    		Id loanId = ei.LLC_BI__Loan__c;
    		if (!eiMap.containsKey(loanId))
    			eiMap.put(loanId, ei);
		}

		//Create adverse action related to loan if loan does not already have related adverse actions
		for (LLC_BI__Loan__c loan : [Select Id, LLC_BI__Account__r.Business_Email__c, LLC_BI__Account__r.Type From LLC_BI__Loan__c
				Where Id in :loanIdSet and Id not in (Select LLC_BI__Loan__c From LLC_BI__Adverse_Action__c)]) {

			LLC_BI__Adverse_Action__c aa = new LLC_BI__Adverse_Action__c (
				LLC_BI__Loan__c = loan.Id,
				Decline_Withdraw_Date__c = System.today(),
				AA_Email__c = loan.LLC_BI__Account__r.Business_Email__c,
				Communicated_To__c = loan.LLC_BI__Account__r.Business_Email__c,
				Communicated_By__c = 'Auto Email Notice',
				Method_of_Adverse_Action__c = 'Email',
				AA_Auto_Created__c = true,
				LLC_BI__Decline_Reason_1__c = 'Outside risk tolerance',
				AA_Status__c = 'Loan Declined'
			);

			//Set credit considered to related borrowing structure with a Guarantor Borrower
			if (loan.LLC_BI__Account__r.Type == 'Sole Proprietorship') {
				aa.Individual_Credit_Considered__c = eiMap.get(loan.Id) != null ? eiMap.get(loan.Id).LLC_BI__Account__c : null;
			}
			adverseActionsToAdd.add(aa);
		}

		if (!adverseActionsToAdd.isEmpty())
			insert adverseActionsToAdd;

		System.debug('CPA Exiting WMPLoanTriggerHandler.createAdverseAction');
	} //createAdverseAction




   	/* Private method to Populate the Primary Savings Account on a TSYS Loan */
 	@TestVisible
 	private void populatePrimarySavingsAccount(List<LLC_BI__Loan__c> newLoans) {
 		System.debug('CPA Entering WMPLoanTriggerHandler.populatePrimarySavingsAccount');

 		//local vars
    	List<Id> borrowerList = new List<Id> ();
    	Map<Id, List<SavingsAccount>> borrowerToDepositMap = new Map<Id, List<SavingsAccount>> ();
    	List<LLC_BI__Loan__c> loansToUpdate = new List<LLC_BI__Loan__c> ();

    	//Loop through the incoming loans and save the Primary Borrowers for the ones where the Product Type is Credit Card
    	for (LLC_BI__Loan__c loan : newLoans) {
    		if ((loan.LLC_BI__Application__c == null || (loan.LLC_BI__Application__c != null && loan.Application_Complete_Date__c != null))
    				&& loan.LLC_BI__Account__c != null && loan.LLC_BI__Product_Type__c == CREDITCARD
    				&& !(loan.LLC_BI__Stage__c.equals(LOAN_BOOKED) || loan.LLC_BI__Stage__c.equals(LOAN_COMPLETE))) {
    			borrowerList.add(loan.LLC_BI__Account__c);
      			loansToUpdate.add(loan);
      			System.debug('CPA Borrower: ' + loan.LLC_BI__Account__c + ' has Product Type Credit Card');
    		}
    	}

    	//For these Borrowers, find all savings account numbers where they are the Primary Owner
    	for (LLC_BI__Legal_Entities__c ei : [Select LLC_BI__Account__c, LLC_BI__Deposit__r.LLC_BI__Account_Number__c, LLC_BI__Deposit__r.LLC_BI__Amount__c From LLC_BI__Legal_Entities__c
    			Where LLC_BI__Account__c in :borrowerList
				and LLC_BI__Deposit__c <> null
				and LLC_BI__Relationship_Type__c = :PRIMARY_OWNER
				and LLC_BI__Deposit__r.LLC_BI__Product_Reference__r.LLC_BI__Product_Type__r.Name = :SAVINGS]) {
			if (borrowerToDepositMap.get(ei.LLC_BI__Account__c) == null)
				borrowerToDepositMap.put(ei.LLC_BI__Account__c, new List<SavingsAccount>());
			borrowerToDepositMap.get(ei.LLC_BI__Account__c).add(new SavingsAccount(ei.LLC_BI__Deposit__r.LLC_BI__Account_Number__c.trim(), ei.LLC_BI__Deposit__r.LLC_BI__Amount__c));
		}
		System.debug('CPA Borrower to Saving Account Map is: ' + borrowerToDepositMap);

    	//Set the Primary Savings Account
    	for (LLC_BI__Loan__c loan : loansToUpdate) {
    		if (borrowerToDepositMap.get(loan.LLC_BI__Account__c) != null) {
    			List<SavingsAccount> accountList = borrowerToDepositMap.get(loan.LLC_BI__Account__c);
    			//Sort the savings accounts to have the one with the largest balance at the top
    			accountList.sort();
    			loan.Primary_Savings_Account__c = accountlist[0].accountNumber;
    			System.debug('CPA Set the Primary Savings Account for loan Name ' + loan.Name + ' to: ' + loan.Primary_Savings_Account__c);
    		}
    	}
 		System.debug('CPA Exiting WMPLoanTriggerHandler.populatePrimarySavingsAccount');
 	} //populatePrimarySavingsAccount



 	/* Private method to Populate the Primary Savings Account on a TSYS Loan */
 	@TestVisible
 	private void populatePrimarySavingsAccount(List<LLC_BI__Loan__c> oldLoans, List<LLC_BI__Loan__c> updatedLoans, Map<ID, LLC_BI__Loan__c> oldLoanMap, Map<ID, LLC_BI__Loan__c> updatedloanMap) {
 		System.debug('CPA Entering WMPLoanTriggerHandler.populatePrimarySavingsAccount');

 		//local vars
    	List<Id> borrowerList = new List<Id> ();
    	Map<Id, List<SavingsAccount>> borrowerToDepositMap = new Map<Id, List<SavingsAccount>> ();
    	List<LLC_BI__Loan__c> loansToUpdate = new List<LLC_BI__Loan__c> ();

    	//Loop through the incoming loans and save the Primary Borrowers for the ones where the Product Type is Credit Card and Primary Savings Account is not populated
    	for (LLC_BI__Loan__c loan : updatedLoans) {
    		if ((loan.LLC_BI__Application__c == null || (loan.LLC_BI__Application__c != null && loan.Application_Complete_Date__c != null))
    				&& loan.LLC_BI__Account__c != null && loan.LLC_BI__Product_Type__c == CREDITCARD && String.isBlank(loan.Primary_Savings_Account__c)
    				&& !(loan.LLC_BI__Stage__c.equals(LOAN_BOOKED) || loan.LLC_BI__Stage__c.equals(LOAN_COMPLETE))) {
    			borrowerList.add(loan.LLC_BI__Account__c);
      			loansToUpdate.add(loan);
      			System.debug('CPA Borrower: ' + loan.LLC_BI__Account__c + ' has Product Type Credit Card');
    		}
    	}

    	//For these Borrowers, find all savings account numbers where they are the Primary Owner
    	for (LLC_BI__Legal_Entities__c ei : [Select LLC_BI__Account__c, LLC_BI__Deposit__r.LLC_BI__Account_Number__c, LLC_BI__Deposit__r.LLC_BI__Amount__c From LLC_BI__Legal_Entities__c
    			Where LLC_BI__Account__c in :borrowerList
				and LLC_BI__Deposit__c <> null
				and LLC_BI__Relationship_Type__c = :PRIMARY_OWNER
				and LLC_BI__Deposit__r.LLC_BI__Product_Reference__r.LLC_BI__Product_Type__r.Name = :SAVINGS]) {
			if (borrowerToDepositMap.get(ei.LLC_BI__Account__c) == null)
				borrowerToDepositMap.put(ei.LLC_BI__Account__c, new List<SavingsAccount>());
			borrowerToDepositMap.get(ei.LLC_BI__Account__c).add(new SavingsAccount(ei.LLC_BI__Deposit__r.LLC_BI__Account_Number__c.trim(), ei.LLC_BI__Deposit__r.LLC_BI__Amount__c));
		}
		System.debug('CPA Borrower to Saving Account Map is: ' + borrowerToDepositMap);

    	//Set the Primary Savings Account
    	for (LLC_BI__Loan__c loan : loansToUpdate) {
    		if (borrowerToDepositMap.get(loan.LLC_BI__Account__c) != null) {
    			List<SavingsAccount> accountList = borrowerToDepositMap.get(loan.LLC_BI__Account__c);
    			//Sort the savings accounts to have the one with the largest balance at the top
    			accountList.sort();
    			loan.Primary_Savings_Account__c = accountlist[0].accountNumber;
    			System.debug('CPA Set the Primary Savings Account for loan Name ' + loan.Name + ' to: ' + loan.Primary_Savings_Account__c);
    		}
    	}
 		System.debug('CPA Exiting WMPLoanTriggerHandler.populatePrimarySavingsAccount');
 	} //populatePrimarySavingsAccount



 	/* Populate the Household lookup on loans with the Primary Household tied to the Primary Borrower */
    private void populateHousehold(List<LLC_BI__Loan__c> newloans) {
    	System.debug('CPA Entering WMPLoanTriggerHandler.populateHousehold');

    	//local vars
    	Map<Id, Id> accountHouseholdMap = new Map<Id, Id> ();
    	List<LLC_BI__Loan__c> loansToUpdate = new List<LLC_BI__Loan__c> ();

    	//Loop through the incoming loans
    	for (LLC_BI__Loan__c loan : newLoans) {
    		if (loan.LLC_BI__Account__c != null && !(loan.LLC_BI__Stage__c.equals('Booked') || loan.LLC_BI__Stage__c.equals('Complete') || String.isBlank(loan.LLC_BI__Stage__c))) {
				//Save the Accounts tied to these loans
				accountHouseholdMap.put(loan.LLC_BI__Account__c, null);
				loansToUpdate.add(loan);
    		}
    	}
    	//Get the Primary Household for these accounts
    	for (Account account : [Select Id, Primary_Household__c From Account Where Id in :accountHouseholdMap.keySet()]) {
    		accountHouseholdMap.put(account.Id, account.Primary_Household__c);
    	}
    	//Update Loans with the Primary Household
    	for (LLC_BI__Loan__c loan : loansToUpdate) {
			loan.Household__c = accountHouseholdMap.get(loan.LLC_BI__Account__c);
			System.debug('CPA loan Account is: ' + loan.LLC_BI__Account__c);
      		System.debug('CPA Setting household for loan name: ' + loan.Name + ' to: ' + loan.Household__c);
    	}
    	System.debug('CPA Exiting WMPLoanTriggerHandler.populateHousehold');
    } //populateHousehold



    /* Populate the Household lookup on loans with the Primary Household tied to the Primary Borrower */
    private void populateHousehold(List<LLC_BI__Loan__c> oldLoans, List<LLC_BI__Loan__c> updatedLoans, Map<ID, LLC_BI__Loan__c> oldLoanMap, Map<ID, LLC_BI__Loan__c> updatedloanMap) {
    	System.debug('CPA Entering WMPLoanTriggerHandler.populateHousehold');

    	//local vars
    	Map<Id, Id> accountHouseholdMap = new Map<Id, Id> ();
    	List<LLC_BI__Loan__c> loansToUpdate = new List<LLC_BI__Loan__c> ();

    	//Loop through the incoming loans
    	for (LLC_BI__Loan__c loan : updatedLoans) {
    		if (loan.LLC_BI__Account__c != null && !(loan.LLC_BI__Stage__c.equals('Booked') || loan.LLC_BI__Stage__c.equals('Complete') || String.isBlank(loan.LLC_BI__Stage__c))) {
				//Save the Accounts tied to these loans
				accountHouseholdMap.put(loan.LLC_BI__Account__c, null);
				loansToUpdate.add(loan);
    		}
    	}
    	//Get the Primary Household for these accounts
    	for (Account account : [Select Id, Primary_Household__c From Account Where Id in :accountHouseholdMap.keySet()]) {
    		accountHouseholdMap.put(account.Id, account.Primary_Household__c);
    	}
    	//Update Loans with the Primary Household
    	for (LLC_BI__Loan__c loan : loansToUpdate) {
			loan.Household__c = accountHouseholdMap.get(loan.LLC_BI__Account__c);
			System.debug('CPA loan Account is: ' + loan.LLC_BI__Account__c);
      		System.debug('CPA Setting household for loan name: ' + loan.Name + ' to: ' + loan.Household__c);
    	}
    	System.debug('CPA Exiting WMPLoanTriggerHandler.populateHousehold');
   	} //populateHousehold
   	
   	
   	
   	/* If a savings account is populated on the loan, signifying a TSYS or SFBL Loan, set the Savings Account Status
	 * field based on if the savings account is tied to the same relationship as the loan
     */
    private void populateSavingsAccountStatus(List<LLC_BI__Loan__c> newloans) {
    	System.debug('CPA Entering WMPLoanTriggerHandler.populateSavingsAccountStatus');

    	//local vars
    	List<Id> borrowerList = new List<Id> ();
    	Map<Id, Set<String>> borrowerToDepositMap = new Map<Id, Set<String>> ();
    	List<LLC_BI__Loan__c> loansToUpdate = new List<LLC_BI__Loan__c> ();

    	//Loop through the incoming loans and save the Primary Borrowers for the ones where the Savings Account is populated
    	for (LLC_BI__Loan__c loan : newLoans) {
    		if (loan.LLC_BI__Account__c != null && !String.isBlank(loan.Primary_Savings_Account__c) && !String.isBlank(loan.Navy_Core_Code__c) && (loan.Navy_Core_Code__c.equalsIgnoreCase('SFBL') || loan.Navy_Core_Code__c.equalsIgnoreCase('TSYS'))) {
    			borrowerList.add(loan.LLC_BI__Account__c);
      			loansToUpdate.add(loan);
      			System.debug('CPA Borrower: ' + loan.LLC_BI__Account__c + ' with Navy Core Code: ' + loan.Navy_Core_Code__c + ' has Savings Account: ' + loan.Primary_Savings_Account__c);
    		}
    	}

    	//For these Borrowers, find all savings account numbers tied to them
    	for (LLC_BI__Deposit__c deposit : [Select LLC_BI__Account__c, LLC_BI__Account_Number__c, LLC_BI__Product_Type__c From LLC_BI__Deposit__c
    			Where LLC_BI__Account__c in :borrowerList
				And LLC_BI__Product_Type__c = :SAVINGS]) {
			if (borrowerToDepositMap.get(deposit.LLC_BI__Account__c) == null)
				borrowerToDepositMap.put(deposit.LLC_BI__Account__c, new Set<String>());
			borrowerToDepositMap.get(deposit.LLC_BI__Account__c).add(deposit.LLC_BI__Account_Number__c.trim());
		}
		System.debug('CPA Borrower to Savings Account Map is: ' + borrowerToDepositMap);

    	//Set the loan Savings Account Status field is the Savings Account is valid
    	for (LLC_BI__Loan__c loan : loansToUpdate) {
    		if (borrowerToDepositMap.get(loan.LLC_BI__Account__c) != null && borrowerToDepositMap.get(loan.LLC_BI__Account__c).contains(loan.Primary_Savings_Account__c.trim()))
    			loan.Primary_Savings_Account_Status__c = VALID_STATUS;
    		else
    			loan.Primary_Savings_Account_Status__c = INVALID_STATUS;
    		System.debug('CPA Set the Savings Account Status for loan Name ' + loan.Name + ' to: ' + loan.Primary_Savings_Account_Status__c);
    	}

    	System.debug('CPA Exiting WMPLoanTriggerHandler.populateSavingsAccountStatus');
    } //populateSavingsAccountStatus
    
    
    
    /* If a savings account is populated on the loan, signifying a TSYS or SFBL Loan, set the Savings Account Status
	 * field based on if the savings account is tied to the same relationship as the loan
     */
    private void populateSavingsAccountStatus(List<LLC_BI__Loan__c> oldLoans, List<LLC_BI__Loan__c> updatedLoans, Map<ID, LLC_BI__Loan__c> oldLoanMap, Map<ID, LLC_BI__Loan__c> updatedloanMap) {
    	System.debug('CPA Entering WMPLoanTriggerHandler.populateSavingsAccountStatus');

    	//local vars
    	List<Id> borrowerList = new List<Id> ();
    	Map<Id, Set<String>> borrowerToDepositMap = new Map<Id, Set<String>> ();
    	Map<Id, Id> loanToBorrowerMap = new Map<Id, Id> ();
    	List<LLC_BI__Loan__c> loansToUpdate = new List<LLC_BI__Loan__c> ();
    	
    	//Loop through the incoming loans and save the Primary Borrowers for the ones where the Checking Account has changed
    	for (Id loanId : oldLoanMap.keySet()) {
    		if (String.isBlank(updatedLoanMap.get(loanId).Primary_Savings_Account__c))
    			updatedLoanMap.get(loanId).Primary_Savings_Account_Status__c = null;
    		else if (String.isBlank(oldLoanMap.get(loanId).Primary_Savings_Account__c) && !String.isBlank(updatedLoanMap.get(loanId).Primary_Savings_Account__c)) {
    			System.debug('CPA Savings Account Changed for Borrower: ' + updatedLoanMap.get(loanId).LLC_BI__Account__c + ' Loan: ' + updatedLoanMap.get(loanId).Name + ' Account: ' + ' Account: ' + updatedLoanMap.get(loanId).Primary_Savings_Account__c);
    			loanToBorrowerMap.put(loanId, updatedLoanMap.get(loanId).LLC_BI__Account__c);
    			loansToUpdate.add(updatedloanMap.get(loanId));
    		} else if (!oldLoanMap.get(loanId).Primary_Savings_Account__c.equals(updatedLoanMap.get(loanId).Primary_Savings_Account__c)) {
    			System.debug('CPA Savings Account Changed for Borrower: ' + updatedLoanMap.get(loanId).LLC_BI__Account__c + ' Loan: ' + updatedLoanMap.get(loanId).Name + ' Account: ' + updatedLoanMap.get(loanId).Primary_Savings_Account__c);
    			loanToBorrowerMap.put(loanId, updatedLoanMap.get(loanId).LLC_BI__Account__c);
    			loansToUpdate.add(updatedloanMap.get(loanId));
    		}
    	}
    	System.debug('CPA Loans where Savings Account Number has changed are: ' + loanToBorrowerMap.keySet());

    	//For these Borrowers, find all savings account numbers tied to them
    	for (LLC_BI__Deposit__c deposit : [Select LLC_BI__Account__c, LLC_BI__Account_Number__c, LLC_BI__Product_Type__c From LLC_BI__Deposit__c
    			Where LLC_BI__Account__c in :loanToBorrowerMap.values()
				And LLC_BI__Product_Type__c = :SAVINGS]) {
			if (borrowerToDepositMap.get(deposit.LLC_BI__Account__c) == null)
				borrowerToDepositMap.put(deposit.LLC_BI__Account__c, new Set<String>());
			borrowerToDepositMap.get(deposit.LLC_BI__Account__c).add(deposit.LLC_BI__Account_Number__c.trim());
		}
		System.debug('CPA Borrower to Savings Account Map is: ' + borrowerToDepositMap);

    	//Set the loan Savings Account Status field is the Savings Account is valid
    	for (LLC_BI__Loan__c loan : loansToUpdate) {
    		if (borrowerToDepositMap.get(loan.LLC_BI__Account__c) != null && borrowerToDepositMap.get(loan.LLC_BI__Account__c).contains(loan.Primary_Savings_Account__c.trim()))
    			loan.Primary_Savings_Account_Status__c = VALID_STATUS;
    		else
    			loan.Primary_Savings_Account_Status__c = INVALID_STATUS;
    		System.debug('CPA Set the Savings Account Status for loan Name ' + loan.Name + ' to: ' + loan.Primary_Savings_Account_Status__c);
    	}

    	System.debug('CPA Exiting WMPLoanTriggerHandler.populateSavingsAccountStatus');
    } //populateSavingsAccountStatus
    
    
    
    /* Populate the Member Access Number on Accounts since it is a Platform encrypted field. This is to allow 
     * manual creation of an extract file with this data
     * Chintan Adhyapak, West Monroe Partners. June 26, 2018
     */
	private void populateMemberAccessNumber(List<LLC_BI__Loan__c> oldLoans, List<LLC_BI__Loan__c> updatedLoans, Map<ID, LLC_BI__Loan__c> oldLoanMap, Map<ID, LLC_BI__Loan__c> updatedloanMap) {
		System.debug('CPA Entering WMPLoanTriggerHandler.populateMemberAccessNumber');
		
		//local vars
		Set<Id> loanIds = new Set<Id> ();
		Set<Id> accountIds = new Set<Id> ();
		List<Account> accountsToUpdate = new List<Account> ();
		
		//Loop through the incoming loans and save the loan IDs for the ones where Credit Approval Date is not null and Core Code is TSYS
    	for (Id loanId : updatedloanMap.keySet()) {
    		LLC_BI__Loan__c loan = updatedLoanMap.get(loanId);
    		System.debug('CPA loan ID is: ' + loan.Id);
    		System.debug('CPA loan Name is: ' + loan.Name);
    		System.debug('CPA loan Credit Approval Date is: ' + loan.LLC_BI__Credit_Approval_Date__c);
    		System.debug('CPA loan Navy Core Code is: ' + loan.Navy_Core_Code__c);
    		if (loan.LLC_BI__Credit_Approval_Date__c != null && !String.isBlank(loan.Navy_Core_Code__c) && loan.Navy_Core_Code__c.equalsIgnoreCase('TSYS'))
    			loanIds.add(loan.Id);
    	}
    	System.debug('CPA qualifying Loan Ids are: ' + loanIds);
    	
    	//Get Account IDs tied to these loans
    	for (LLC_BI__Legal_Entities__c ei : [Select LLC_BI__Account__c FROM LLC_BI__Legal_Entities__c WHERE LLC_BI__Loan__c in :loanIds])
    		accountIds.add(ei.LLC_BI__Account__c);
    	System.debug('CPA Account Ids collected for update are: ' + accountIds);
    	
    	//Update the Accounts
    	for (Account account : [Select Id, Member_Access_Number__c, TSYS_File_MAN__c From Account Where Id in :accountIds]) {
    		account.TSYS_File_MAN__c = String.isBlank(account.Member_Access_Number__c) ? null : account.Member_Access_Number__c.leftPad(14, '0');
    		If (!String.isBlank(account.Member_Access_Number__c)) {
    			accountsToUpdate.add(account);
    			System.debug('CPA Updating Account: ' + account);
    		}
    	}
    	if (!accountsToUpdate.isEmpty())
    		update accountsToUpdate;
		
		System.debug('CPA Exiting WMPLoanTriggerHandler.populateMemberAccessNumber');
	} //populateMemberAccessNumber
	
	
	
	/* Modify the Borrower Type of existing Entity Involvement records from 'Guarantor' to 'Related Entity' 
     * if Credit Approval Date is changed/set and Main Borrower is Sole Proprietor and Loan Stage is not Booked
     * or Complete
     * Chintan Adhyapak, West Monroe Partners. September 11, 2018
     */
	private void modifyBorrowerType(List<LLC_BI__Loan__c> oldLoans, List<LLC_BI__Loan__c> updatedLoans, Map<ID, LLC_BI__Loan__c> oldLoanMap, Map<ID, LLC_BI__Loan__c> updatedloanMap) {
		System.debug('CPA Entering WMPLoanTriggerHandler.modifyBorrowerType');
		
		//local vars
		Set<Id> loanIds = new Set<Id> ();
		List<LLC_BI__Legal_Entities__c> eisToUpdate = new List<LLC_BI__Legal_Entities__c> ();
		
		//Loop through the incoming loans and save the loan IDs for the ones where Credit Approval Date is set and primary borrower is Sole Prop
    	for (Id loanId : updatedloanMap.keySet()) {
    		LLC_BI__Loan__c updatedloan = updatedLoanMap.get(loanId);
    		LLC_BI__Loan__c oldLoan = oldLoanMap.get(loanId);
            //System.debug('CPA Loan Id is: ' + updatedloan.Id);
    		System.debug('CPA Loan Name is: ' + updatedloan.Name);
    		System.debug('CPA Loan Credit Approval Date is: ' + updatedloan.LLC_BI__Credit_Approval_Date__c);
    		System.debug('CPA Loan Account Type is: ' + updatedloan.Main_Borrower_Type__c);
    		System.debug('CPA Loan NavyCoreCode is: ' + (String.isBlank(updatedLoan.Navy_Core_Code__c) ? null : updatedLoan.Navy_Core_Code__c));
    		System.debug('CPA Loan Stage is: ' + (String.isBlank(updatedLoan.LLC_BI__Stage__c) ? null : updatedLoan.LLC_BI__Stage__c));
    		
    		if (oldLoan.LLC_BI__Credit_Approval_Date__c == null && updatedLoan.LLC_BI__Credit_Approval_Date__c != null && 
    				!String.isBlank(updatedLoan.Main_Borrower_Type__c) && updatedLoan.Main_Borrower_Type__c.equalsIgnoreCase('Sole Proprietorship') &&
    				!String.isBlank(updatedLoan.LLC_BI__Stage__c) && !(updatedLoan.LLC_BI__Stage__c.equalsIgnoreCase('Booked') || updatedLoan.LLC_BI__Stage__c.equalsIgnoreCase('Complete')) &&
    				(String.isBlank(updatedLoan.Navy_Core_Code__c) || !updatedLoan.Navy_Core_Code__c.equalsIgnoreCase('TSYS'))) {
    			loanIds.add(updatedloan.Id);
    		}
    	}
    	System.debug('CPA qualifying Loan Ids are: ' + loanIds);
    	
    	//Find related Entity Involvement records of type 'Guarantor' and update type to 'Related Entity'
        if (!loanIds.isEmpty()) {
    		for (LLC_BI__Legal_Entities__c ei : [Select Id, LLC_BI__Borrower_Type__c From LLC_BI__Legal_Entities__c
    				Where LLC_BI__Loan__c in :loanIds And LLC_BI__Borrower_Type__c = 'Guarantor']) {
    			ei.LLC_BI__Borrower_Type__c = 'Related Entity';
    			eisToUpdate.add(ei);
    		}
			System.debug('CPA eisToUpdate is: ' + eisToUpdate);
		
			if (!eisToUpdate.isEmpty()) {
				update eisToUpdate;
			}
        }
		System.debug('CPA Exiting WMPLoanTriggerHandler.modifyBorrowerType');
	} //modifyBorrowerType
}