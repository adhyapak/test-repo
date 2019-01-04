/**
 * This class tests the trigger on the Loan (LLC_BI__Loan__c) object
 * Chintan Adhyapak, West Monroe Partners. January 26, 2018 (created as LoanTrigger_Test)
 * Adam Smith, West Monroe Partners. March 30, 2018 (refactored as WMPLoanTrigger_Test)
 */
@isTest
private class WMPLoanTrigger_Test {
	//class variables
	private static final String CHECKING_CATEGORY = 'Checking';
	private static final String SAVINGS_CATEGORY = 'Savings';
	private static final Decimal SAVINGS_AMOUNT1 = 1000.00;
	private static final Decimal SAVINGS_AMOUNT2 = 2000.00;
	private static final Decimal SAVINGS_AMOUNT3 = 3000.00;
	private static final Decimal SAVINGS_AMOUNT4 = 4000.00;
	private static final String SAVINGS_ACCOUNT_NUMBER1 = 'Account 1';
	private static final String SAVINGS_ACCOUNT_NUMBER2 = 'Account 2';
	private static final String SAVINGS_ACCOUNT_NUMBER3 = 'Account 3';
	private static final String SAVINGS_ACCOUNT_NUMBER4 = 'Account 4';
	private static final String PRIMARY_OWNER = 'Primary Owner';
	private static final String FROM_STAGE = 'Decisioning';
	private static final Map<String, Id> recordTypeMap = new Map<String, Id>();
	private static final Decimal NUM_LOANS = 11;
	private static final Decimal NUM_DEPOSITS = 6;
	private static final Decimal NUM_ACCOUNTS = 3;
	private static final Decimal NUM_COLLATERALS = 4;
	private static final Decimal NUM_PLEDGEDCOLLATERALS = 4;

	//Create test data for the class
	@testSetup static void setupData() {
		System.debug('CPA Entering WMPLoanTrigger_Test.setupData');

		//Read Account/Relationship record types
		for (RecordType recType : [SELECT Id,Name FROM RecordType WHERE SobjectType = 'Account' AND IsActive = true AND NamespacePrefix = 'LLC_BI']) {
			recordTypeMap.put(recType.Name, recType.Id);
		}
		System.assertEquals(false, recordTypeMap.isEmpty());

		//Create Relationships
		Account relationshipA = new Account();
		relationshipA.Name = 'Apex Relationship A';
		relationshipA.LLC_BI__Tax_Identification_Number_PE__c = '123456789';
		relationshipA.Member_Access_Number__c = '123456789';
		relationshipA.ShippingState = 'IL';
		relationshipA.BillingState = 'IL';
		relationshipA.recordTypeId = recordTypeMap.get('Business');
		relationshipA.Type = 'Sole Proprietorship';

		Account relationshipB = new Account();
		relationshipB.Name = 'Apex Relationship B';
		relationshipB.LLC_BI__Tax_Identification_Number_PE__c = '123456789';
		relationshipB.Member_Access_Number__c = '9876543210';
		relationshipB.ShippingState = 'IL';
		relationshipB.BillingState = 'IL';
		relationshipB.recordTypeId = recordTypeMap.get('Business');

		Account relationshipC = new Account();
		relationshipC.Name = 'Apex Relationship C';
		relationshipC.LLC_BI__Tax_Identification_Number_PE__c = '123456789';
		relationshipC.ShippingState = 'IL';
		relationshipC.BillingState = 'IL';
		relationshipC.recordTypeId = recordTypeMap.get('Household');

		List<Account> accountList = new List<Account> ();
		accountList.add(relationshipA);
		accountList.add(relationshipB);
		accountList.add(relationshipC);
		insert accountList;

		//Assert
		System.assertNotEquals(null, relationshipA.Id);
		System.assertNotEquals(null, relationshipB.Id);
		System.assertNotEquals(null, relationshipC.Id);

		//Set the household for relationshipA
		relationshipA = [Select Id, Primary_Household__c From Account Where Id = :relationshipA.Id];
		relationshipA.Primary_Household__c = relationshipC.Id;
		update relationshipA;
		relationshipA = [Select Id, Primary_Household__c From Account Where Id = :relationshipA.Id];
		System.assertEquals(relationshipC.Id, relationshipA.Primary_Household__c);

		//Create a Product Line
		LLC_BI__Product_Line__c productLineA = new LLC_BI__Product_Line__c();
		productLineA.Name = 'Apex Product Line';
		productLineA.LLC_BI__Category__c = 'Consumer';
		productLineA.LLC_BI__Product_Object__c = 'Loan__c';
		insert productLineA;

		//Assert
		System.assertNotEquals(null, productLineA.Id);

		//Create 2 Product Types
		LLC_BI__Product_Type__c productTypeA = new LLC_BI__Product_Type__c();
		productTypeA.Name = 'Apex Product Type 1';
		productTypeA.LLC_BI__Product_Line__c = productLineA.Id;
		productTypeA.LLC_BI__Category__c = CHECKING_CATEGORY;
		productTypeA.Name = CHECKING_CATEGORY;

		LLC_BI__Product_Type__c productTypeB = new LLC_BI__Product_Type__c();
		productTypeB.Name = 'Apex Product Type 2';
		productTypeB.LLC_BI__Product_Line__c = productLineA.Id;
		productTypeB.LLC_BI__Category__c = SAVINGS_CATEGORY;
		productTypeB.Name = SAVINGS_CATEGORY;

		List<LLC_BI__Product_Type__c> productTypeList = new List<LLC_BI__Product_Type__c> ();
		productTypeList.add(productTypeA);
		productTypeList.add(productTypeB);
		insert productTypeList;

		//Assert
		System.assertNotEquals(null, productTypeA.Id);
		System.assertNotEquals(null, productTypeB.Id);

		//Create two products
		LLC_BI__Product__c productA = new LLC_BI__Product__c();
		productA.Name = 'Product A';
		productA.LLC_BI__Product_Type__c = productTypeA.Id;

		LLC_BI__Product__c productB = new LLC_BI__Product__c();
		productB.Name = 'Product B';
		productB.Core__c = 'TSYS';
		productB.LLC_BI__Product_Type__c = productTypeB.Id;

		List<LLC_BI__Product__c> productList = new List<LLC_BI__Product__c> ();
		productList.add(productA);
		productList.add(productB);
		insert productList;

		//Assert
		System.assertNotEquals(null, productA.Id);
		System.assertNotEquals(null, productB.Id);

		//Create product packages
		LLC_BI__Product_Package__c productPackageA = new LLC_BI__Product_Package__c ();
		productPackageA.Name = 'Product Package A';

		LLC_BI__Product_Package__c productPackageB = new LLC_BI__Product_Package__c ();
		productPackageA.Name = 'Product Package B';

		LLC_BI__Product_Package__c productPackageC = new LLC_BI__Product_Package__c ();
		productPackageA.Name = 'Product Package C';

		LLC_BI__Product_Package__c productPackageD = new LLC_BI__Product_Package__c ();
		productPackageA.Name = 'Product Package D';

		List<LLC_BI__Product_Package__c> productPackageList = new List<LLC_BI__Product_Package__c> ();
		productPackageList.add(productPackageA);
		productPackageList.add(productPackageB);
		productPackageList.add(productPackageC);
		productPackageList.add(productPackageD);
		insert productPackageList;

		//Assert
		System.assertNotEquals(null, productPackageA.Id);
		System.assertNotEquals(null, productPackageB.Id);
		System.assertNotEquals(null, productPackageC.Id);
		System.assertNotEquals(null, productPackageD.Id);

		//Create Deposit Checking and Savings Accounts
    	LLC_BI__Deposit__c depositA = new LLC_BI__Deposit__c ();
    	depositA.Name = '12345';
    	depositA.LLC_BI__Account_Number__c = '12345';
    	depositA.LLC_BI__Product_Reference__c = productA.Id;

    	LLC_BI__Deposit__c depositB = new LLC_BI__Deposit__c ();
    	depositB.Name = '67890';
    	depositB.LLC_BI__Account_Number__c = '67890';
    	depositB.LLC_BI__Product_Reference__c = productA.Id;

    	//Savings
    	LLC_BI__Deposit__c depositC = new LLC_BI__Deposit__c ();
    	depositC.Name = SAVINGS_ACCOUNT_NUMBER1;
    	depositC.LLC_BI__Account_Number__c = SAVINGS_ACCOUNT_NUMBER1;
    	depositC.LLC_BI__Amount__c = SAVINGS_AMOUNT1;
    	depositC.LLC_BI__Product_Reference__c = productB.Id;

    	LLC_BI__Deposit__c depositD = new LLC_BI__Deposit__c ();
    	depositD.Name = SAVINGS_ACCOUNT_NUMBER2;
    	depositD.LLC_BI__Account_Number__c = SAVINGS_ACCOUNT_NUMBER2;
    	depositD.LLC_BI__Amount__c = SAVINGS_AMOUNT2;
    	depositD.LLC_BI__Product_Reference__c = productB.Id;

    	LLC_BI__Deposit__c depositE = new LLC_BI__Deposit__c ();
    	depositE.Name = SAVINGS_ACCOUNT_NUMBER3;
    	depositE.LLC_BI__Account_Number__c = SAVINGS_ACCOUNT_NUMBER3;
    	depositE.LLC_BI__Amount__c = SAVINGS_AMOUNT3;
    	depositE.LLC_BI__Product_Reference__c = productB.Id;
    	
    	LLC_BI__Deposit__c depositF = new LLC_BI__Deposit__c ();
    	depositF.Name = SAVINGS_ACCOUNT_NUMBER4;
    	depositF.LLC_BI__Account_Number__c = SAVINGS_ACCOUNT_NUMBER4;
    	depositF.LLC_BI__Amount__c = SAVINGS_AMOUNT4;
    	depositF.LLC_BI__Product_Reference__c = productB.Id;
    	depositF.LLC_BI__Account__c = relationshipA.Id;
    	depositF.LLC_BI__Product_Type__c = SAVINGS_CATEGORY;

    	//Insert them
    	List<LLC_BI__Deposit__c> depositList = new List<LLC_BI__Deposit__c> ();
    	depositList.add(depositA);
    	depositList.add(depositB);
    	depositList.add(depositC);
    	depositList.add(depositD);
    	depositList.add(depositE);
    	depositList.add(depositF);
    	insert depositList;

    	//Assert
    	for (LLC_BI__Deposit__c deposit : depositList)
    		System.assertNotEquals(null, deposit.Id);

    	//Create Entity Involvement records for these Deposits
    	LLC_BI__Legal_Entities__c eiA = new LLC_BI__Legal_Entities__c ();
    	eiA.LLC_BI__Account__c = relationshipA.Id;
    	eiA.LLC_BI__Deposit__c = depositA.Id;
    	eiA.LLC_BI__Relationship_Type__c = PRIMARY_OWNER;

    	LLC_BI__Legal_Entities__c eiB = new LLC_BI__Legal_Entities__c ();
    	eiB.LLC_BI__Account__c = relationshipA.Id;
    	eiB.LLC_BI__Deposit__c = depositB.Id;
    	eiB.LLC_BI__Relationship_Type__c = PRIMARY_OWNER;

    	LLC_BI__Legal_Entities__c eiC = new LLC_BI__Legal_Entities__c ();
    	eiC.LLC_BI__Account__c = relationshipA.Id;
    	eiC.LLC_BI__Deposit__c = depositC.Id;
    	eiC.LLC_BI__Relationship_Type__c = PRIMARY_OWNER;

    	LLC_BI__Legal_Entities__c eiD = new LLC_BI__Legal_Entities__c ();
    	eiD.LLC_BI__Account__c = relationshipA.Id;
    	eiD.LLC_BI__Deposit__c = depositD.Id;
    	eiD.LLC_BI__Relationship_Type__c = PRIMARY_OWNER;

    	//Insert
    	List<LLC_BI__Legal_Entities__c> eiList = new List<LLC_BI__Legal_Entities__c> ();
    	eiList.add(eiA);
    	eiList.add(eiB);
    	eiList.add(eiC);
    	eiList.add(eiD);
    	insert eiList;

    	//Assert
    	for (LLC_BI__Legal_Entities__c ei : eiList)
    		System.assertNotEquals(null, ei.Id);

		//Create loans
		LLC_BI__Loan__c loanA = new LLC_BI__Loan__c();
		loanA.LLC_BI__Product_Reference__c = productA.Id;
		loanA.LLC_BI__Principal_Balance__c = 100000.0;
		loanA.LLC_BI__Stage__c = FROM_STAGE;
		loanA.Name = 'Loan A';
		loanA.LLC_BI__Account__c = relationshipA.Id;
		loanA.Checking_Account__c = '12345';
		loanA.Critical_Policy_Exceptions_Exist__c = true;
		loanA.LLC_BI__TDR__c = true;
		loanA.LLC_BI__Product_Package__c = productPackageA.Id;
		loanA.LLC_BI__Product__c = 'Product A';
		loanA.LLC_BI__Amount__c = 100000;

		LLC_BI__Loan__c loanB = new LLC_BI__Loan__c();
		loanB.LLC_BI__Product_Reference__c = productA.Id;
		loanB.LLC_BI__Principal_Balance__c = 200000.0;
		loanB.LLC_BI__Stage__c = FROM_STAGE;
		loanB.Name = 'Loan B';
		loanB.LLC_BI__Account__c = relationshipA.Id;
		loanB.Policy_Exceptions_Exist__c = true;
		loanB.LLC_BI__Product_Package__c = productPackageB.Id;
		loanB.LLC_BI__Product__c = 'Product A';
		loanB.LLC_BI__Amount__c = 200000;

		LLC_BI__Loan__c loanC = new LLC_BI__Loan__c();
		loanC.LLC_BI__Product_Reference__c = productB.Id;
		loanC.LLC_BI__Principal_Balance__c = 200000.0;
		loanC.LLC_BI__Product_Type__c = 'Credit Card';
		loanC.Name = 'Loan C';
		loanC.LLC_BI__Account__c = relationshipA.Id;
		loanC.LLC_BI__Product_Package__c = productPackageC.Id;
		loanC.LLC_BI__Product__c = 'Product B';
		loanC.LLC_BI__Amount__c = 200000;

		LLC_BI__Loan__c loanD = new LLC_BI__Loan__c();
		loanD.LLC_BI__Product_Reference__c = productB.Id;
		loanD.LLC_BI__Principal_Balance__c = 300000.0;
		loanD.LLC_BI__Product_Type__c = 'Credit Card';
		loanD.Name = 'Loan D';
		loanD.LLC_BI__Account__c = relationshipB.Id; //Different account with no EI records
		loanD.LLC_BI__Product_Package__c = productPackageD.Id;
		loanD.LLC_BI__Product__c = 'Product B';
		loanD.LLC_BI__Amount__c = 300000;
		
		//Valid Savings Account Number
		LLC_BI__Loan__c loanE = new LLC_BI__Loan__c();
		loanE.LLC_BI__Product_Reference__c = productB.Id;
		loanE.LLC_BI__Principal_Balance__c = 177000.0;
		loanE.Primary_Savings_Account__c = SAVINGS_ACCOUNT_NUMBER4;
		loanE.Name = 'Loan E';
		loanE.LLC_BI__Account__c = relationshipA.Id;
		loanE.LLC_BI__Product_Package__c = productPackageC.Id;
		loanE.LLC_BI__Product__c = 'Product B';
		loanE.LLC_BI__Amount__c = 177000;
		
		//Invalid Savings Account Number
		LLC_BI__Loan__c loanF = new LLC_BI__Loan__c();
		loanF.LLC_BI__Product_Reference__c = productB.Id;
		loanF.LLC_BI__Principal_Balance__c = 233000.0;
		loanF.Primary_Savings_Account__c = '938166';
		loanF.Name = 'Loan F';
		loanF.LLC_BI__Account__c = relationshipA.Id;
		loanF.LLC_BI__Product_Package__c = productPackageC.Id;
		loanF.LLC_BI__Product__c = 'Product B';
		loanF.LLC_BI__Amount__c = 233000;
		
		//Loan to test Member Access Number logic
		LLC_BI__Loan__c loanG = new LLC_BI__Loan__c();
		loanG.LLC_BI__Product_Reference__c = productB.Id;
		loanG.LLC_BI__Principal_Balance__c = 344000.0;
		loanG.Name = 'Loan G';
		loanG.LLC_BI__Account__c = relationshipA.Id;
		loanG.LLC_BI__Product_Package__c = productPackageC.Id;
		loanG.LLC_BI__Product__c = 'Product B';
		loanG.LLC_BI__Amount__c = 344000;
		
		//Loan to test Member Access Number logic
		LLC_BI__Loan__c loanH = new LLC_BI__Loan__c();
		loanH.LLC_BI__Product_Reference__c = productB.Id;
		loanH.LLC_BI__Principal_Balance__c = 466000.0;
		loanH.Name = 'Loan H';
		loanH.LLC_BI__Account__c = relationshipB.Id;
		loanH.LLC_BI__Product_Package__c = productPackageC.Id;
		loanH.LLC_BI__Product__c = 'Product B';
		loanH.LLC_BI__Amount__c = 466000;
		
		//Loan to test Modify Borrower Type logic
		LLC_BI__Loan__c loanI = new LLC_BI__Loan__c();
		loanI.LLC_BI__Product_Reference__c = productA.Id;
		loanI.LLC_BI__Principal_Balance__c = 123000.0;
		loanI.Name = 'Loan I';
		loanI.LLC_BI__Account__c = relationshipC.Id;
		loanI.LLC_BI__Product_Package__c = productPackageC.Id;
		loanI.LLC_BI__Product__c = 'Product A';
		loanI.LLC_BI__Amount__c = 123000;
		
		//Loan to test Modify Borrower Type logic
		LLC_BI__Loan__c loanJ = new LLC_BI__Loan__c();
		loanJ.LLC_BI__Product_Reference__c = productA.Id;
		loanJ.LLC_BI__Principal_Balance__c = 456000.0;
		loanJ.Name = 'Loan J';
		loanJ.LLC_BI__Account__c = relationshipA.Id;
		loanJ.LLC_BI__Product_Package__c = productPackageC.Id;
		loanJ.LLC_BI__Product__c = 'Product A';
		loanJ.LLC_BI__Amount__c = 456000;
		
		//Loan to test Modify Borrower Type logic
		LLC_BI__Loan__c loanK = new LLC_BI__Loan__c();
		loanK.LLC_BI__Product_Reference__c = productB.Id;
		loanK.LLC_BI__Principal_Balance__c = 567000.0;
		loanK.Name = 'Loan K';
		loanK.LLC_BI__Account__c = relationshipA.Id;
		loanK.LLC_BI__Product_Package__c = productPackageC.Id;
		loanK.LLC_BI__Product__c = 'Product B';
		loanK.LLC_BI__Amount__c = 567000;

		//Add to a list
		List<LLC_BI__Loan__c> loanList = new List<LLC_BI__Loan__c>();
		loanList.add(loanA);
		loanList.add(loanB);
		loanList.add(loanC);
		loanList.add(loanD);
		loanList.add(loanE);
		loanList.add(loanF);
		loanList.add(loanG);
		loanList.add(loanH);
		loanList.add(loanI);
		loanList.add(loanJ);
		loanList.add(loanK);

		//insert the loans
		insert loanList;

		//Assert
		for (LLC_BI__Loan__c loan : loanList)
			System.assertNotEquals(null, loan.Id);
			
		//Create EI for Loan
		LLC_BI__Legal_Entities__c eiE = new LLC_BI__Legal_Entities__c ();
    	eiE.LLC_BI__Account__c = relationshipA.Id;
    	eiE.LLC_BI__Loan__c = loanG.Id;
    	eiE.LLC_BI__Relationship_Type__c = PRIMARY_OWNER;
    	
    	LLC_BI__Legal_Entities__c eiF = new LLC_BI__Legal_Entities__c ();
    	eiF.LLC_BI__Account__c = relationshipB.Id;
    	eiF.LLC_BI__Loan__c = loanG.Id;
    	eiF.LLC_BI__Relationship_Type__c = 'Co-Borrower';
    	
    	LLC_BI__Legal_Entities__c eiI = new LLC_BI__Legal_Entities__c ();
    	eiI.LLC_BI__Account__c = relationshipB.Id;
    	eiI.LLC_BI__Loan__c = loanI.Id;
    	eiI.LLC_BI__Borrower_Type__c = 'Guarantor';
    	
    	LLC_BI__Legal_Entities__c eiJ = new LLC_BI__Legal_Entities__c ();
    	eiJ.LLC_BI__Account__c = relationshipA.Id;
    	eiJ.LLC_BI__Loan__c = loanJ.Id;
    	eiJ.LLC_BI__Borrower_Type__c = 'Guarantor';
    	
    	LLC_BI__Legal_Entities__c eiK = new LLC_BI__Legal_Entities__c ();
    	eiK.LLC_BI__Account__c = relationshipA.Id;
    	eiK.LLC_BI__Loan__c = loanK.Id;
    	eiK.LLC_BI__Borrower_Type__c = 'Guarantor';

    	//Insert
    	eiList = new List<LLC_BI__Legal_Entities__c> ();
    	eiList.add(eiE);
    	eiList.add(eiF);
    	eiList.add(eiI);
    	eiList.add(eiJ);
    	eiList.add(eiK);
    	insert eiList;

    	//Assert
    	for (LLC_BI__Legal_Entities__c ei : eiList)
    		System.assertNotEquals(null, ei.Id);

		//Create a Collateral Type
		LLC_BI__Collateral_Type__c collateralTypeA = new LLC_BI__Collateral_Type__c();
		collateralTypeA.LLC_BI__Advance_Rate__c = 100.0;
		insert collateralTypeA;

		//Assert
		System.assertNotEquals(null, collateralTypeA.Id);

		//Create four collaterals
		LLC_BI__Collateral__c collateralA = new LLC_BI__Collateral__c();
		collateralA.LLC_BI__Collateral_Type__c = collateralTypeA.Id;

		LLC_BI__Collateral__c collateralB = new LLC_BI__Collateral__c();
		collateralB.LLC_BI__Collateral_Type__c = collateralTypeA.Id;

		LLC_BI__Collateral__c collateralC = new LLC_BI__Collateral__c();
		collateralC.LLC_BI__Collateral_Type__c = collateralTypeA.Id;

		LLC_BI__Collateral__c collateralD = new LLC_BI__Collateral__c();
		collateralD.LLC_BI__Collateral_Type__c = collateralTypeA.Id;

		//Add to a list
		List<LLC_BI__Collateral__c> collateralList = new List<LLC_BI__Collateral__c>();
		collateralList.add(collateralA);
		collateralList.add(collateralB);
		collateralList.add(collateralC);
		collateralList.add(collateralD);

		//insert the collaterals
		insert collateralList;

		//Assert
		System.assertNotEquals(null, collateralA.Id);
		System.assertNotEquals(null, collateralB.Id);
		System.assertNotEquals(null, collateralC.Id);
		System.assertNotEquals(null, collateralD.Id);

		//Create a Collateral Aggregate
		LLC_BI__Loan_Collateral_Aggregate__c aggregate = new LLC_BI__Loan_Collateral_Aggregate__c();
		insert aggregate;

		//Assert
		System.assertNotEquals(null, aggregate.Id);

		//Create 2 Pledged Collaterals per loan
    	LLC_BI__Loan_Collateral2__c pledgedCollateralA = new LLC_BI__Loan_Collateral2__c ();
    	pledgedCollateralA.LLC_BI__Collateral__c = collateralList[0].Id;
    	pledgedCollateralA.LLC_BI__Loan__c = loanList[0].Id;
    	pledgedCollateralA.LLC_BI__Loan_Collateral_Aggregate__c = aggregate.Id;
    	pledgedCollateralA.LLC_BI__Amount_Pledged__c = 200;
    	pledgedCollateralA.Account__c = 'PC_A';
    	pledgedCollateralA.LLC_BI__Is_Primary__c = false;

    	LLC_BI__Loan_Collateral2__c pledgedCollateralB = new LLC_BI__Loan_Collateral2__c ();
    	pledgedCollateralB.LLC_BI__Collateral__c = collateralList[1].Id;
    	pledgedCollateralB.LLC_BI__Loan__c = loanList[0].Id;
    	pledgedCollateralB.LLC_BI__Loan_Collateral_Aggregate__c = aggregate.Id;
    	pledgedCollateralB.LLC_BI__Amount_Pledged__c = 100;
    	pledgedCollateralB.Account__c = 'PC_B';
    	pledgedCollateralB.LLC_BI__Is_Primary__c = false;

    	LLC_BI__Loan_Collateral2__c pledgedCollateralC = new LLC_BI__Loan_Collateral2__c ();
    	pledgedCollateralC.LLC_BI__Collateral__c = collateralList[2].Id;
    	pledgedCollateralC.LLC_BI__Loan__c = loanList[1].Id;
    	pledgedCollateralC.LLC_BI__Loan_Collateral_Aggregate__c = aggregate.Id;
    	pledgedCollateralC.LLC_BI__Amount_Pledged__c = 400;
    	pledgedCollateralC.Account__c = 'PC_C';
    	pledgedCollateralC.LLC_BI__Is_Primary__c = false;

    	LLC_BI__Loan_Collateral2__c pledgedCollateralD = new LLC_BI__Loan_Collateral2__c ();
    	pledgedCollateralD.LLC_BI__Collateral__c = collateralList[3].Id;
    	pledgedCollateralD.LLC_BI__Loan__c = loanList[1].Id;
    	pledgedCollateralD.LLC_BI__Loan_Collateral_Aggregate__c = aggregate.Id;
    	pledgedCollateralD.LLC_BI__Amount_Pledged__c = 300;
    	pledgedCollateralD.Account__c = 'PC_D';
    	pledgedCollateralD.LLC_BI__Is_Primary__c = false;

    	List<LLC_BI__Loan_Collateral2__c> pledgedCollateralList = new List<LLC_BI__Loan_Collateral2__c> ();
    	pledgedCollateralList.add(pledgedCollateralA);
    	pledgedCollateralList.add(pledgedCollateralB);
    	pledgedCollateralList.add(pledgedCollateralC);
    	pledgedCollateralList.add(pledgedCollateralD);
    	insert pledgedCollateralList;
    	pledgedCollateralList = [Select Id, LLC_BI__Is_Primary__c, Account__c From LLC_BI__Loan_Collateral2__c];
    	System.debug('CPA Created Pledged Collaterals: '+ pledgedCollateralList);

    	//Assert
    	System.assertNotEquals(null, pledgedCollateralA.Id);
    	System.assertNotEquals(null, pledgedCollateralB.Id);
    	System.assertNotEquals(null, pledgedCollateralC.Id);
    	System.assertNotEquals(null, pledgedCollateralD.Id);

    	System.debug('CPA Exiting WMPLoanTrigger_Test.setupData');
    } //setupData



    /* Test the before insert and update triggers */
    @isTest static void testBeforeInsertUpdate() {
    	System.debug('CPA Entering WMPLoanTrigger_Test.testBeforeInsertUpdate');
    	//Retrieve test data
    	List<LLC_BI__Loan__c> loanList = [Select Id, Name, Checking_Account__c, Checking_Account_Status__c, Primary_Savings_Account__c, Household__c From LLC_BI__Loan__c];
    	List<LLC_BI__Deposit__c> depositList = [Select Id, Name From LLC_BI__Deposit__c];
    	List<Account> accountList = [Select Id, Name From Account];
    	System.debug('CPA loans retrieved are: ' + loanList);
    	//Retrieve Account
    	Account relationshipB = null;
    	Account relationshipC = null;
    	for (Account account : accountList) {
    		if (account.Name == 'Apex Relationship B')
    			relationshipB = account;
    		else if (account.Name == 'Apex Relationship C')
    			relationshipC = account;
    	}
    	System.assertNotEquals(null, relationshipB.Id);
    	System.assertNotEquals(null, relationshipC.Id);

    	//Assert
    	System.assertEquals(NUM_LOANS, loanList.size());
    	System.assertEquals(NUM_DEPOSITS, depositList.size());
    	System.assertEquals(NUM_ACCOUNTS, accountList.size());
    	for (LLC_BI__Loan__c loan : loanList) {
    		if (loan.Name.equals('Loan A')) {
    			//Validate that Checking Account Status is set for CLOC
    			System.assertEquals('VALID', loan.Checking_Account_Status__c);
    			System.assertEquals(relationshipC.Id, loan.Household__c);
    		} else if (loan.Name.equals('Loan C')) {
    			//Validate that Primary Savings Account Number is set
    			System.assertEquals(loan.Primary_Savings_Account__c, SAVINGS_ACCOUNT_NUMBER2);
    			System.assertEquals(relationshipC.Id, loan.Household__c);
    		} else if (loan.Name.equals('Loan D')) {
    			//Validate Primary Savings Account
    			System.assert(String.isBlank(loan.Primary_Savings_Account__c));
    			System.assertEquals(null, loan.Household__c);
    		}
    	}

    	//Update CLOC loans with a valid and an invalid checking account number and TSYS Loan with anything
    	for (LLC_BI__Loan__c loan : loanList) {
    		if (loan.Name.equals('Loan A'))
    			loan.Checking_Account__c = '4299705';
    		else if (loan.Name.equals('Loan B'))
    			loan.Checking_Account__c = '67890';
    		//Update something so we can trigger the before update trigger
    		else if (loan.Name.equals('Loan D'))
    			loan.Checking_Account__c='0';
    	}

    	//Retrieve Deposit
    	LLC_BI__Deposit__c depositE = null;
    	for (LLC_BI__Deposit__c deposit : depositList) {
    		if (deposit.Name == SAVINGS_ACCOUNT_NUMBER3)
    			depositE = deposit;
    	}
    	System.assertNotEquals(null, depositE.Id);

    	//Create a EI record for Relationship B
    	LLC_BI__Legal_Entities__c eiE = new LLC_BI__Legal_Entities__c ();
    	eiE.LLC_BI__Account__c = relationshipB.Id;
    	eiE.LLC_BI__Deposit__c = depositE.Id;
    	eiE.LLC_BI__Relationship_Type__c = PRIMARY_OWNER;
    	insert eiE;
    	System.assertNotEquals(null, eiE.Id);

    	//Set the household for relationshipB to check before insert logic
    	relationshipB = [Select Id, Primary_Household__c From Account Where Id = :relationshipB.Id];
    	relationshipB.Primary_Household__c = relationshipC.Id;
    	update relationshipB;

    	//Update CLOC and TSYS Loans to trigger the before update trigger
    	update loanList;

    	//Retrieve
    	loanList = [Select Id, Name, Checking_Account__c, Checking_Account_Status__c, Primary_Savings_Account__c, Household__c From LLC_BI__Loan__c];

    	//Assert
    	for (LLC_BI__Loan__c loan : loanList) {
    		if (loan.Name.equals('Loan A'))
    			System.assertEquals('INVALID', loan.Checking_Account_Status__c);
    		else if (loan.Name.equals('Loan B'))
    			System.assertEquals('VALID', loan.Checking_Account_Status__c);
    		else if (loan.Name.equals('Loan D')) {
    			System.assertEquals(loan.Primary_Savings_Account__c, SAVINGS_ACCOUNT_NUMBER3);
    			System.assertEquals(relationshipC.Id, loan.Household__c);
    		}
    	}
    	System.debug('CPA Exiting WMPLoanTrigger_Test.testBeforeInsertUpdate');
    } //testBeforeInsertUpdate



	/* Test the after update triggers */
/*	
    @isTest static void testAfterUpdate() {
    	System.debug('CPA Entering WMPLoanTrigger_Test.testAfterUpdate');
    	//Retrieve test data
    	List<LLC_BI__Collateral__c> collateralList = [Select Id From LLC_BI__Collateral__c];
    	List<LLC_BI__Loan__c> loanList = [Select Id, LLC_BI__Stage__c From LLC_BI__Loan__c];
    	LLC_BI__Loan_Collateral_Aggregate__c aggregate = [Select Id From LLC_BI__Loan_Collateral_Aggregate__c Limit 1][0];
    	List<LLC_BI__Loan_Collateral2__c> pledgedCollateralList = [Select Id, LLC_BI__Is_Primary__c, Account__c, LLC_BI__Amount_Pledged__c From LLC_BI__Loan_Collateral2__c];

    	//Assert
    	System.assertEquals(NUM_COLLATERALS, collateralList.size());
    	System.assertEquals(NUM_LOANS, loanList.size());
    	System.assertNotEquals(null, aggregate.Id);
    	System.assertEquals(NUM_PLEDGEDCOLLATERALS, pledgedCollateralList.size());

    	test.startTest();
    		//Unset the Primary flag
    		for (LLC_BI__Loan_Collateral2__c collateral : pledgedCollateralList) {
    			if (collateral.Account__c.equals('PC_B'))
    				collateral.LLC_BI__Amount_Pledged__c = 250;
    			else if (collateral.Account__c.equals('PC_D'))
    				collateral.LLC_BI__Amount_Pledged__c = 450;
    			collateral.LLC_BI__Is_Primary__c = false;
    		}
    		update pledgedCollateralList;

    		pledgedCollateralList = [Select Id, LLC_BI__Is_Primary__c, Account__c, LLC_BI__Amount_Pledged__c From LLC_BI__Loan_Collateral2__c];
    		System.debug('CPA pledged coll after unset is: ' + pledgedCollateralList);

    		//Create an approval request for the loans
        	Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
        	req1.setComments('Submitting request for approval.');
        	req1.setObjectId(loanList[0].id);

        	Approval.ProcessSubmitRequest req2 = new Approval.ProcessSubmitRequest();
        	req2.setComments('Submitting request for approval.');
        	req2.setObjectId(loanList[1].id);

        	//Submit the record to specific process and skip the criteria evaluation
        	req1.setProcessDefinitionNameOrId('LAP130_Employee_Credits_Not_AutoDec');
        	req1.setSkipEntryCriteria(true);

        	req2.setProcessDefinitionNameOrId('LAP130_Employee_Credits_Not_AutoDec');
        	req2.setSkipEntryCriteria(true);

        	pledgedCollateralList = [Select Id, LLC_BI__Is_Primary__c, Account__c From LLC_BI__Loan_Collateral2__c];
    		System.debug('CPA pledged coll before loan approval is: ' + pledgedCollateralList);

        	//Submit the approval request for the loan
        	Approval.ProcessResult result1 = Approval.process(req1);
        	Approval.ProcessResult result2 = Approval.process(req2);

        	pledgedCollateralList = [Select Id, LLC_BI__Is_Primary__c, Account__c From LLC_BI__Loan_Collateral2__c];
    		System.debug('CPA pledged coll after approval submit is: ' + pledgedCollateralList);

        	//Verify the result
        	System.assert(result1.isSuccess());
        	System.assert(result2.isSuccess());
        	System.assertEquals('Pending', result1.getInstanceStatus(), 'Instance Status'+result1.getInstanceStatus());
        	System.assertEquals('Pending', result2.getInstanceStatus(), 'Instance Status'+result2.getInstanceStatus());

        	//Approve the submitted request
        	//First, get the ID of the newly created item
        	List<Id> newWorkItemIds1 = result1.getNewWorkitemIds();
        	List<Id> newWorkItemIds2 = result2.getNewWorkitemIds();

        	//Instantiate the new ProcessWorkitemRequest object and populate it
        	Approval.ProcessWorkitemRequest req3 = new Approval.ProcessWorkitemRequest();
        	req3.setComments('Approving request.');
        	req3.setAction('Approve');
        	req3.setNextApproverIds(new Id[] {UserInfo.getUserId()});

        	Approval.ProcessWorkitemRequest req4 = new Approval.ProcessWorkitemRequest();
        	req4.setComments('Approving request.');
        	req4.setAction('Approve');
        	req4.setNextApproverIds(new Id[] {UserInfo.getUserId()});

        	//Use the ID from the newly created item to specify the item to be worked
        	req3.setWorkitemId(newWorkItemIds1.get(0));
        	req4.setWorkitemId(newWorkItemIds2.get(0));

        	//Submit the request for approval
        	Approval.ProcessResult result3 =  Approval.process(req3);
        	Approval.ProcessResult result4 =  Approval.process(req4);

        	//Verify the results
        	System.assert(result3.isSuccess(), 'Result Status:' + result3.isSuccess());
        	System.assertEquals('Approved', result3.getInstanceStatus(), 'Instance Status' + result3.getInstanceStatus());

        	System.assert(result4.isSuccess(), 'Result Status:' + result4.isSuccess());
        	System.assertEquals('Approved', result4.getInstanceStatus(), 'Instance Status' + result4.getInstanceStatus());

        	pledgedCollateralList = [Select Id, LLC_BI__Is_Primary__c, Account__c From LLC_BI__Loan_Collateral2__c];
    		System.debug('CPA pledged coll after approval is: ' + pledgedCollateralList);
		test.stopTest();

		//Retrieve
		loanList = [Select Id, LLC_BI__Stage__c From LLC_BI__Loan__c];
		System.debug('CPA Loans after stopTest are: ' + loanList);
		Map<String, LLC_BI__Loan_Collateral2__c> pledgedCollateralMap = new Map<String, LLC_BI__Loan_Collateral2__c> ();
		for (LLC_BI__Loan_Collateral2__c collateral : [Select Id, LLC_BI__Is_Primary__c, Account__c From LLC_BI__Loan_Collateral2__c])
			pledgedCollateralMap.put(collateral.Account__c, collateral);
		System.debug('CPA Retrieved pledged collaterals are: ' + pledgedCollateralMap.values());

    	//Assert that A and D are marked primary and B and C are not
    	System.assertEquals(false, pledgedCollateralMap.get('PC_A').LLC_BI__Is_Primary__c);
    	System.assertEquals(true, pledgedCollateralMap.get('PC_B').LLC_BI__Is_Primary__c);
    	System.assertEquals(false, pledgedCollateralMap.get('PC_C').LLC_BI__Is_Primary__c);
    	System.assertEquals(true, pledgedCollateralMap.get('PC_D').LLC_BI__Is_Primary__c);

    	System.debug('CPA Exiting WMPLoanTrigger_Test.testAfterUpdate');
    } //testAfterUpdate
*/



	/* Test the afterUpdate > createAdverseAction trigger */
	@isTest static void testCreateAdverseAction() {
		System.debug('CPA Entering WMPLoanTrigger_Test.testCreateAdverseAction');

		Set<Id> loanIdSet = new Set<Id> ();
		List<LLC_BI__Loan__c> loanListToUpdate = new List<LLC_BI__Loan__c> ();

		test.startTest();
			//Set loan to auto create adverse action and save Id of loan
			for (LLC_BI__Loan__c loan : [Select Id, LLC_BI__Account__r.Name From LLC_BI__Loan__c]) {
				if (loan.LLC_BI__Account__r.Name == 'Apex Relationship A') {
					loan.Auto_Create_Adverse_Action__c = true;
					loanIdSet.add(loan.Id);
					loanListToUpdate.add(loan);
				}
			}
			update loanListToUpdate;
		test.stopTest();

		//Retrieve
		Map<Id, LLC_BI__Adverse_Action__c> adverseActionMap = new Map<Id, LLC_BI__Adverse_Action__c> ();

		for (LLC_BI__Adverse_Action__c aa : [Select Id, LLC_BI__Loan__r.Auto_Create_Adverse_Action__c, AA_Auto_Created__c, LLC_BI__Loan__c From LLC_BI__Adverse_Action__c
				Where LLC_BI__Loan__c in :loanIdSet]) {
			if (aa.LLC_BI__Loan__r.Auto_Create_Adverse_Action__c == true) {
				System.debug('Adverse Action Test Assertions');
				System.assertEquals(aa.LLC_BI__Loan__r.Id, aa.LLC_BI__Loan__c);
				System.assertEquals(true, aa.AA_Auto_Created__c);
			}
		}
		System.debug('CPA Exiting WMPLoanTrigger_Test.testCreateAdverseAction');
	} //testCreateAdverseAction
	
	

	/* Test the afterUpdate > updateProductPackage trigger */
/* No longer needed, per Brandon, 05/25/2018
	@isTest static void testUpdateProductPackage() {
		System.debug('CPA Entering WMPLoanTrigger_Test.testUpdateProductPackage');

		Set<Id> loanIdSet = new Set<Id> ();
		List<LLC_BI__Loan__c> loanListToUpdate = new List<LLC_BI__Loan__c> ();

		test.startTest();
			//Set loan to ready for review and save Id of loan
			for (LLC_BI__Loan__c loan : [Select Id From LLC_BI__Loan__c]) {
				loan.LLC_BI__Is_Review_Ready__c = true;
				loanIdSet.add(loan.Id);
				if (!loanListToUpdate.contains(loan))
					loanListToUpdate.add(loan);
			}
			update loanListToUpdate;
		test.stopTest();

		//Retrieve
		List<LLC_BI__Product_Package__c> productPackageList = [Select Id, Name, Approval_Process__c From LLC_BI__Product_Package__c];

		for (LLC_BI__Product_Package__c productPackage : productPackageList) {
			if (productPackage.Name == 'Product Package A') {
				System.assertEquals('LAP150 - Credits w Critical Excp or TDR', productPackage.Approval_Process__c);
			} else if (productPackage.Name == 'Product Package B') {
				System.assertEquals('LAP160 - Credits w/ Non-Critical Excptns', productPackage.Approval_Process__c);
			} else if (productPackage.Name == 'Product Package C') {
				System.assertEquals('LAP170 - Credits with Override Used', productPackage.Approval_Process__c);
			} else if (productPackage.Name == 'Product Package D') {
				System.assertEquals('LAP200 - Credits with No Exceptions', productPackage.Approval_Process__c);
			}

		}
		System.debug('CPA Exiting WMPLoanTrigger_Test.testUpdateProductPackage');
	}
*/
	
	
	
	/** Test the setting of the Savings Account Status
	  * Chintan Adhyapak, West Monroe Partners. June 04, 2018
	  */
	@isTest static void testPopulateSavingsAccountStatus () {
		System.debug('CPA Entering WMPLoanTrigger_Test.testPopulateSavingsAccountStatus');
		//local vars
		LLC_BI__Loan__c loanE, loanF;
		//List<LLC_BI__Loan__c> loansToUpdate = new List<LLC_BI__Loan__c>();
		
		//Retrieve test data
    	List<LLC_BI__Loan__c> loanList = [Select Id, Name, Checking_Account__c, Checking_Account_Status__c, 
    			Primary_Savings_Account__c, Household__c, Primary_Savings_Account_Status__c 
    			From LLC_BI__Loan__c];
    	System.debug('CPA loans retrieved before update are: ' + loanList);

    	//Assert before insert trigger
    	System.assertEquals(NUM_LOANS, loanList.size());
    	for (LLC_BI__Loan__c loan : loanList) {
    		if (loan.Name.equals('Apex Relationship A-Product B-177000')) {
    			loanE = loan;
    			//Validate that Savings Account Status is set
    			System.assertEquals('VALID', loan.Primary_Savings_Account_Status__c);
    		} else if (loan.Name.equals('Apex Relationship A-Product B-233000')) {
    			loanF = loan;
    			//Validate that Savings Account Status is set
    			System.assertEquals('INVALID', loan.Primary_Savings_Account_Status__c);
    		}
    	}
    	
    	//Update loans to fire before update trigger
    	loanE.Primary_Savings_Account__c = null;
    	loanF.Primary_Savings_Account__c = SAVINGS_ACCOUNT_NUMBER4;
    	update loanList;
    	
    	//Retrieve loans
    	loanList = [Select Id, Name, Checking_Account__c, Checking_Account_Status__c, 
    			Primary_Savings_Account__c, Household__c, Primary_Savings_Account_Status__c 
    			From LLC_BI__Loan__c];
    	System.debug('CPA loans retrieved after update are: ' + loanList);

    	//Assert before update trigger
    	for (LLC_BI__Loan__c loan : loanList) {
    		if (loan.Name.equals('Loan E')) {
    			loanE = loan;
    			//Validate that Savings Account Status is set
    			System.assertEquals(null, loan.Primary_Savings_Account_Status__c, 'Status should have been null due to condition check in the logic');
    		} else if (loan.Name.equals('Loan F')) {
    			loanF = loan;
    			//Validate that Savings Account Status is set
    			System.assertEquals('VALID', loan.Primary_Savings_Account_Status__c, 'Status should be valid due to valid Savings account Number on the Loan');
    		}
    	}
    	
    	//Update loans to fire before update trigger
    	loanE.Primary_Savings_Account__c = SAVINGS_ACCOUNT_NUMBER4;
    	loanF.Primary_Savings_Account__c = '198644';
    	update loanList;
    	
    	//Retrieve loans
    	loanList = [Select Id, Name, Checking_Account__c, Checking_Account_Status__c, 
    			Primary_Savings_Account__c, Household__c, Primary_Savings_Account_Status__c 
    			From LLC_BI__Loan__c];
    	System.debug('CPA loans retrieved are: ' + loanList);

    	//Assert before update trigger
    	for (LLC_BI__Loan__c loan : loanList) {
    		if (loan.Name.equals('Loan E')) {
    			//Validate that Savings Account Status is set
    			System.assertEquals('VALID', loan.Primary_Savings_Account_Status__c, 'Status should be valid due to valid Savings account Number on the Loan');
    		} else if (loan.Name.equals('Loan F')) {
    			//Validate that Savings Account Status is set
    			System.assertEquals('INVALID', loan.Primary_Savings_Account_Status__c, 'Status should be Invalid due to Invalid Savings account Number on the Loan');
    		}
    	}
		System.debug('CPA Exiting WMPLoanTrigger_Test.testPopulateSavingsAccountStatus');
	} //testPopulateSavingsAccountStatus
	
	
	
	/* Test the populateMemberAccessNumber after update method
	 * Chintan Adhyapak, West Monroe Partners. June 26, 2018
	 */
	@isTest static void testPopulateMemberAccessNumber () {
		System.debug('CPA Entering WMPLoanTrigger_Test.testPopulateMemberAccessNumber');

		Set<Id> loanIdSet = new Set<Id> ();
		List<LLC_BI__Loan__c> loanListToUpdate = new List<LLC_BI__Loan__c> ();

		test.startTest();
			//Set loan to auto create adverse action and save Id of loan
			for (LLC_BI__Loan__c loan : [Select Id, Name, LLC_BI__Credit_Approval_Date__c From LLC_BI__Loan__c]) {
				if (loan.Name.equalsIgnoreCase('Apex Relationship A-Product B-344000') || loan.Name.equalsIgnoreCase('Apex Relationship B-Product B-466000')) {
					loan.LLC_BI__Credit_Approval_Date__c = System.today();
					loanIdSet.add(loan.Id);
					loanListToUpdate.add(loan);
				}
			}
			update loanListToUpdate;
		test.stopTest();

		//Retrieve
		for (Account account : [Select Id, Member_Access_Number__c, TSYS_File_MAN__c, Name From Account]) {
			if (account.Name.equalsIgnoreCase('Apex Relationship A')) {
				System.assertEquals(account.TSYS_File_MAN__c, '00000123456789');
			} else if (account.Name.equalsIgnoreCase('Apex Relationship B')) {
				System.assertEquals(account.TSYS_File_MAN__c, '00009876543210');
			}
		}
		System.debug('CPA Exiting WMPLoanTrigger_Test.testPopulateMemberAccessNumber');
	} //testPopulateMemberAccessNumber
	
	
	
	/* Test the modifyBorrowerType after update method
	 * Chintan Adhyapak, West Monroe Partners. September 12, 2018
	 */
	@isTest static void testModifyBorrowerType() {
		System.debug('CPA Entering WMPLoanTrigger_Test.testModifyBorrowerType');

		//local vars
        Set<Id> loanIdSet = new Set<Id> ();
		List<LLC_BI__Loan__c> loanListToUpdate = new List<LLC_BI__Loan__c> ();
        LLC_BI__Loan__c loanI, loanJ, loanK;
        LLC_BI__Legal_Entities__c eiI, eiJ, eiK;

		test.startTest();
			//Set loan to modify Guarantor EI records and save
			for (LLC_BI__Loan__c loan : [Select Id, Name, LLC_BI__Credit_Approval_Date__c From LLC_BI__Loan__c]) {
				System.debug('CPA Retrieved Loan Name is: ' + loan.Name);
				if (loan.Name.equalsIgnoreCase('Apex Relationship C-Product A-123000') || loan.Name.equalsIgnoreCase('Apex Relationship A-Product A-456000') ||
						loan.Name.equalsIgnoreCase('Apex Relationship A-Product B-567000')) {
					loan.LLC_BI__Credit_Approval_Date__c = System.today();
					loanIdSet.add(loan.Id);
					loanListToUpdate.add(loan);
					//Non Sole Pro; Non TSYS
                    if (loan.Name.equalsIgnoreCase('Apex Relationship C-Product A-123000'))
                        loanI = loan;
                    //Sole Prop; Non TSYS
                    else if (loan.Name.equalsIgnoreCase('Apex Relationship A-Product A-456000'))
                        loanJ = loan;
                    //Sole Prop; TSYS
                    else if (loan.Name.equalsIgnoreCase('Apex Relationship A-Product B-567000'))
                    	loanK = loan;
				}
			}
        	System.assertNotEquals(null, loanI.Id, 'Loan I is null');
            System.assertNotEquals(null, loanJ.Id, 'Loan J is null');
            System.assertNotEquals(null, loanK.Id, 'Loan K is null');
        	System.debug('CPA loanListToUpdate is: ' + loanListToUpdate);
			update loanListToUpdate;
		test.stopTest();

		//Retrieve
		for (LLC_BI__Legal_Entities__c ei : [Select Id, Name, LLC_BI__Account__c, LLC_BI__Borrower_Type__c, LLC_BI__Loan__c 
                                             From LLC_BI__Legal_Entities__c Where LLC_BI__Loan__c in :loanIdSet]) {
			System.debug('CPA Retreieved EI record is: ' + ei);
			if (ei.LLC_BI__Loan__c == loanI.Id)
                eiI = ei;
			else if (ei.LLC_BI__Loan__c == loanJ.Id)
                eiJ = ei;
            else if (ei.LLC_BI__Loan__c == loanK.Id)
                eiK = ei;
		}
        
        //Assert
        System.assertNotEquals(null, eiI.Id, 'eiI is null');
		System.assertNotEquals(null, eiJ.Id, 'eiJ is null');
		System.assertNotEquals(null, eiK.Id, 'eiK is null');
        System.assertEquals(eiI.LLC_BI__Borrower_Type__c, 'Guarantor', 'eiI Borrower Type is not Guarantor');
        System.assertEquals(eiJ.LLC_BI__Borrower_Type__c, 'Related Entity', 'eiJ Borrower Type is not Related Entity');
        System.assertEquals(eiK.LLC_BI__Borrower_Type__c, 'Guarantor', 'eiK Borrower Type is not Guarantor');
        
		System.debug('CPA Exiting WMPLoanTrigger_Test.testModifyBorrowerType');
	} //testModifyBorrowerType
}