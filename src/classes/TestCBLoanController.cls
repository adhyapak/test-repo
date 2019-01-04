@isTest
public with sharing class TestCBLoanController {
    
    static Account createAccount() {
		Account testAccount = new Account(Name = 'My test account', AccountNumber = '1234');
		insert testAccount;
		return testAccount;
	}
	
    public static LLC_BI__Loan__c createLoan() {
		return createLoan(null, null, null, null, null);
	}

	public static LLC_BI__Loan__c createLoan(LLC_BI__Application__c application) {
		return createLoan(application, null, null, null, null);
	}

	public static LLC_BI__Loan__c createLoan(
		LLC_BI__Application__c application,
		LLC_BI__Branch__c branch,
		LLC_BI__Product__c sProduct,
		User sProcessor,
		User sOfficer) {

		LLC_BI__Loan__c loan = new LLC_BI__Loan__c(
			Name = 'Test Loan',
			LLC_BI__Amount__c = 10000
		);

		if(branch != null) loan.LLC_BI__Branch__c = branch.Id;
		if(application != null) loan.LLC_BI__Application__c = application.Id;
		if(sProduct != null) loan.LLC_BI__Product__c = sProduct.Name;
		if(sProcessor != null) loan.LLC_BI__Processor_Name__c = sProcessor.Id;
		if(sOfficer != null) loan.LLC_BI__Loan_Officer__c = sOfficer.Id;

		insert loan;
		return loan;
	}

	public static LLC_BI__Loan__c createLoan(LLC_BI__Branch__c branch) {
		return createLoan(null, branch, null, null, null);
	}

	public static LLC_BI__Legal_Entities__c createLegalEntity(
		LLC_BI__Loan__c loan,
		Account acct) {
		LLC_BI__Legal_Entities__c entity = new LLC_BI__Legal_Entities__c(
			LLC_BI__Loan__c = loan.Id,
			LLC_BI__Account__c = acct.Id
		);
		insert entity;
		return entity;
	}

	public static LLC_BI__Collateral__c createCollateral(LLC_BI__Collateral_Type__c ct) {
		return createCollateral('TestCollateralFactory', ct, null);
	}

	public static LLC_BI__Collateral__c createCollateral(String collateralName, LLC_BI__Collateral_Type__c ct, LLC_BI__Collateral__c parentCollateral) {
		LLC_BI__Collateral__c coll = new LLC_BI__Collateral__c(
			LLC_BI__Collateral_Name__c = collateralName,
			LLC_BI__Description__c = 'TestCollateralFactory testing',
			LLC_BI__Collateral_Type__c = ct.id,
			LLC_BI__CUSIP_Number__c = '1234567'
		);

		if(parentCollateral != null) {
			coll.LLC_BI__Highest__c = parentCollateral.LLC_BI__Highest__c == null ? parentCollateral.Id : parentCollateral.LLC_BI__Highest__c;
			coll.LLC_BI__Parent_Collateral__c = parentCollateral.Id;
		}

		insert coll;
		return coll;
	}

	public static LLC_BI__Loan_Collateral__c createCollateralLoan(LLC_BI__Loan__c loan, String name) {
		LLC_BI__Loan_Collateral__c colloan = new LLC_BI__Loan_Collateral__c(
			LLC_BI__Vessel_Name__c = name,
			LLC_BI__Number_of_Shares__c = 100,
			LLC_BI__Loan__c = loan.Id
		);
		insert colloan;
		return colloan;
	}

	public static LLC_BI__Loan_Collateral2__c createCollateral2Loan(LLC_BI__Collateral__c coll, LLC_BI__Loan__c loan, LLC_BI__Loan_Collateral_Aggregate__c collaggreate) {
		LLC_BI__Loan_Collateral2__c colloan = new LLC_BI__Loan_Collateral2__c(
			LLC_BI__Collateral__c = coll.Id,
			LLC_BI__Loan__c = loan.Id,
			LLC_BI__Loan_Collateral_Aggregate__c = collaggreate.Id
		);
		insert colloan;
		return colloan;
	}

	public static LLC_BI__Account_Collateral__c createCollateralAccount(LLC_BI__Collateral__c coll, Account account) {
		LLC_BI__Account_Collateral__c colloan = new LLC_BI__Account_Collateral__c(
			LLC_BI__Collateral__c = coll.Id,
			LLC_BI__Account__c = account.Id
			//LLC_BI__Loan_Collateral_Aggregate__c = collaggreate.Id
		);
		insert colloan;
		return colloan;
	}

	public static LLC_BI__Collateral_Type__c createCollateralType() {
		return createCollateralType(20);
	}

	public static LLC_BI__Collateral_Type__c createCollateralType(Decimal advanceRate) {
		return createCollateralType(advanceRate, null);
	}

	public static LLC_BI__Collateral_Type__c createCollateralType(Decimal advanceRate, LLC_BI__Collateral_Type__c parentType) {
		LLC_BI__Collateral_Type__c ct = new LLC_BI__Collateral_Type__c(
			Name = 'test',
			LLC_BI__Subtype__c = 'test subtype',
			LLC_BI__Advance_Rate__c = advanceRate
		);

		if(parentType != null) {
			ct.LLC_BI__Highest_Type__c = parentType.LLC_BI__Highest_Type__c == null ? parentType.Id : parentType.LLC_BI__Highest_Type__c;
			ct.LLC_BI__Parent_Type__c = parentType.Id;
		}

		insert ct;
		return ct;
	}

	public static LLC_BI__Loan_Collateral_Aggregate__c createCollateralaggregate() {
		LLC_BI__Loan_Collateral_Aggregate__c colloan = new LLC_BI__Loan_Collateral_Aggregate__c(
			Name = '111'
		);
		insert colloan;
		return colloan;
	}

	public static LLC_BI__Lien__c createLien(LLC_BI__Collateral__c coll, LLC_BI__Loan__c loan) {
		LLC_BI__Lien__c lien = new LLC_BI__Lien__c(
			LLC_BI__Collateral__c = coll.Id,
			LLC_BI__Loan__c = loan.Id
		);
		insert lien;
		return lien;
	}
	
	private static String loanId;

    @isTest
    static void setupData() {
    	
    	loanId = createLoan().Id;
        
        
        nFUSE.PackageServiceRequest servRequest = new nFUSE.PackageServiceRequest(
			CBConfiguration.PLUGIN_NAME, CBConfiguration.PLUGIN_VERSION, null);
		nFUSE.ServiceLocator locator = new nFUSE.ServiceLocator();
		locator.register(servRequest, nFUSE.SendService.class, nFUSE.TestServices.SendServiceMock.class, CBConfiguration.LOANSENDSERVICENAME);
        
        
        
    }
    
    @isTest
    private static void testWithStandardController(){
    	LLC_BI__Loan__c loan = new LLC_BI__Loan__c();
    	insert loan;
        CBLoanController c = new CBLoanController(new ApexPages.StandardController(loan));
        system.assertEquals(true,true);
    }

    @isTest
    private static void testBookLoan(){
        new nFUSE.DataInstaller().onInstall(null);
    	
        setupData();
        test.startTest();
        CBLoanController.forceTestingException = false;
        CBEntities.CoreBookingResponse response = CBLoanController.bookLoan(loanId);
        system.assertEquals(true,response.IsSuccessful);
        test.stopTest();
    }
    
    @isTest
    private static void testBookLoanFails(){
        setupData();
        test.startTest();
        CBLoanController.forceTestingException = true;
        CBEntities.CoreBookingResponse response = CBLoanController.bookLoan(loanId);
        system.assertEquals(false,response.IsSuccessful);
        test.stopTest();
    }
    
    
    @isTest
    private static void testBookLoanNotComplete(){
        
        String accountId = createAccount().Id;
        
        nFUSE__Transaction_Log__c log = new nFUSE__Transaction_Log__c(Name='TestLog',nFUSE__External_Id__c='123123123'); //possible namespace issue
        log.nFUSE__Action__c = 'new';
        log.nFUSE__Api_Version__c = '1';
        log.nFUSE__App_Plugin__c = 'CoreBooking';
        log.nFUSE__Primary_Object_Id__c = accountId;
        log.nFUSE__Requested_By_User_Id__c = 'user';
        log.nFUSE__Transaction_Status__c = 'notcomplete';
        log.nFUSE__External_Id__c = 'test';
        insert log;
        
        String externalId = log.nFUSE__External_Id__c;
        
        test.startTest();
        CBEntities.TransactionLogResponse response = CBLoanController.getTransactionStatus(externalId);
        system.assertEquals(false,response.IsComplete);
        test.stopTest();
    }
    
    @isTest
    private static void testBookLoanComplete(){
        
        String accountId = createAccount().Id;
        
        nFUSE__Transaction_Log__c log = new nFUSE__Transaction_Log__c(Name='TestLog',nFUSE__External_Id__c='123123123'); //possible namespace issue
        log.nFUSE__Action__c = 'new';
        log.nFUSE__Api_Version__c = '1';
        log.nFUSE__App_Plugin__c = 'CoreBooking';
        log.nFUSE__Primary_Object_Id__c = accountId;
        log.nFUSE__Requested_By_User_Id__c = 'user';
        log.nFUSE__Transaction_Status__c = 'eRRor';
        log.nFUSE__External_Id__c = 'test';
        insert log;
        
        String externalId = log.nFUSE__External_Id__c;
        
        test.startTest();
        CBEntities.TransactionLogResponse response = CBLoanController.getTransactionStatus(externalId);
        system.assertEquals(true,response.IsComplete);
        test.stopTest();
    }
    
}