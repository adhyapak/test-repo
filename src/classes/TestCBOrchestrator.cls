@isTest
private class TestCBOrchestrator{
    
    public static String setuploanId;
    public static String setuprelationshipId;
    public static String setuprelationshipIdBusiness;
    public static String setupcontactId;
    public static String setupExternalId;
    
    static LLC_BI__Branch__c createBranch(){
        LLC_BI__Branch__c sBranch = new LLC_BI__Branch__c(
			LLC_BI__City__c = 'LLC_BI__City__c',
			Name = 'Test Branch'
		);
		insert sBranch;
		return sBranch;
    }
    
    static LLC_BI__Deposit__c createDeposit(){
        LLC_BI__Deposit__c sDeposit = new LLC_BI__Deposit__c(
			Name = 'Test Deposit',
			LLC_BI__Size_of_Box__c = 'Size1'
		);
		insert sDeposit;
		return sDeposit;
    }
    
    static LLC_BI__Ownership_Structure_Type__c createOwnershipStructureType(){
        LLC_BI__Ownership_Structure_Type__c sObj = new LLC_BI__Ownership_Structure_Type__c(Name = 'Test OwnershipStructureType');

		insert sObj;
		return sObj;
    }
    
    static LLC_BI__Funding_Method_Type__c createFundingMethodType(){
        LLC_BI__Funding_Method_Type__c sFunMethType = new LLC_BI__Funding_Method_Type__c(
			Name = 'Test Fun Meth Type'
		);
		insert sFunMethType;
		return sFunMethType;
    }
    
    static LLC_BI__Funding_Method__c createFundingMethod() {
		LLC_BI__Funding_Method__c sObj = new LLC_BI__Funding_Method__c(Name = 'Test FundingMethod');

		insert sObj;
		return sObj;
	}

	static LLC_BI__Funding_Method__c createFundingMethod(LLC_BI__Funding_Method_Type__c fundingMethodType) {
		LLC_BI__Funding_Method__c sObj = new LLC_BI__Funding_Method__c(Name = 'Test FundingMethod', LLC_BI__Funding_Method_Type__c = fundingMethodType.Id);

		insert sObj;
		return sObj;
	}
	
	static LLC_BI__Product_Line__c createProductLine() {
		return createProductLine('Test ProductLine');
	}

	static LLC_BI__Product_Line__c createProductLine(String productName) {
		LLC_BI__Product_Line__c sObj = new LLC_BI__Product_Line__c(Name = productName);

		insert sObj;
		return sObj;
	}
    
    static LLC_BI__Product_Type__c createProductType(LLC_BI__Product_Line__c sProductLine) {
		LLC_BI__Product_Type__c sProductType = new LLC_BI__Product_Type__c(
			Name = 'Test Product Type',
			LLC_BI__Category__c = 'Cat5',
			LLC_BI__Product_Line__c = sProductLine.Id
		);
		insert sProductType;
		return sProductType;
	}
	
	static LLC_BI__Product_Feature__c createProductFeature() {
		LLC_BI__Product_Feature__c sProductFeature = new LLC_BI__Product_Feature__c(
			LLC_BI__Is_Binding__c = true
		);
		insert sProductFeature;
		return sProductFeature;
	}
	
	static LLC_BI__Product__c createProduct() {
		return createProduct(createDefaultProductType(), null);
	}

	static LLC_BI__Product__c createProduct(LLC_BI__Product_Type__c sProductType, LLC_BI__Product_Feature__c sProductFeature) {
		Id productTypeId = null;

		if(sProductType != null && sProductType.Id != null) productTypeId = sProductType.Id;
		else productTypeId = createDefaultProductType().Id;

		LLC_BI__Product__c sProduct = new LLC_BI__Product__c(
			Name = 'Test Product',
			LLC_BI__Product_Type__c = productTypeId,
			LLC_BI__RealEstate_Type__c = 'LLC_BI__RealEstate_Type__c'
		);

		if(sProductFeature != null) sProduct.LLC_BI__Product_Feature__c = sProductFeature.Id;

		insert sProduct;
		return sProduct;
	}

	static LLC_BI__Product_Type__c createDefaultProductType() {
		LLC_BI__Product_Line__c sProductLine = new LLC_BI__Product_Line__c();
		insert sProductLine;

		LLC_BI__Product_Type__c sProductType = new LLC_BI__Product_Type__c(
			LLC_BI__Product_Line__c = sProductLine.Id
		);
		insert sProductType;
		return sProductType;
	}
	
	static Account createAccount() {
		Account testAccount = new Account(Name = 'My test account', AccountNumber = '1234', LLC_BI__Tax_Identification_Number_PE__c ='123456789');

		insert testAccount;
		return testAccount;
	}

	static Account createAccount(string accountType) {
		Account testAccount = new Account(Name = 'My test account', AccountNumber = '2345', Type = accountType, LLC_BI__Tax_Identification_Number_PE__c = '123456789');

		insert testAccount;
		return testAccount;
	}

	static Account createNotPersistedAccount() {
		return new Account(Name = 'notPersistedAccount', AccountNumber = '123456789');
	}
	
	private class XContactFactoryException extends Exception {	}
	
	static Contact createPrimaryContact(Account sAcct) {
		if(sAcct == null) throw new XContactFactoryException('Account can NOT be null for primary Contact');

		Contact dbContact = new Contact(
			AccountId = sAcct.Id,
			FirstName = 'Hank',
			LastName = 'Hill',
			LLC_BI__Drivers_License__c = '4213421323',
			LLC_BI__Home_Address__c = 'LLC_BI__Home_Address__c'
		);
		dbContact.put(LLC_BI.LifeCycleContact.getSSNFieldDescribe().getName(), '345534324');

		insert dbContact;
		return dbContact;
	}

	static Contact createContact() {
		Contact sContact = new Contact(
			FirstName = 'Hank',
			LastName = 'Hill'
		);
		insert sContact;
		return sContact;
	}
	
	static LLC_BI__Treasury_Service__c createTreasuryService() {
		LLC_BI__Treasury_Service__c sTreasSvc = new LLC_BI__Treasury_Service__c(
			Name = 'Test Fun Meth Type'
		);
		insert sTreasSvc;
		return sTreasSvc;
	}
	
	static LLC_BI__Analyzed_Account__c createAnalyzedAccount() {
		LLC_BI__Analyzed_Account__c sObj = new LLC_BI__Analyzed_Account__c(Name = 'Test AnalyzedAccount');

		insert sObj;
		return sObj;
	}
	
	static LLC_BI__Legal_Entities__c createLegalEntity(LLC_BI__Loan__c loan, Account acct, String borrowerType) {
		LLC_BI__Legal_Entities__c entity = new LLC_BI__Legal_Entities__c(
			LLC_BI__Loan__c = loan.Id,
			LLC_BI__Account__c = acct.Id,
			Name = 'Test Entity Involvement',
			LLC_BI__Borrower_Type__c = borrowerType,
			LLC_BI__Address__c = 'LLC_BI__Address__c'
		);
		insert entity;
		return entity;
	}

	static LLC_BI__Legal_Entities__c createLegalEntity(LLC_BI__Deposit__c deposit, Account acct) {
		LLC_BI__Legal_Entities__c entity = new LLC_BI__Legal_Entities__c(
			LLC_BI__Deposit__c = deposit.Id,
			LLC_BI__Account__c = acct.Id,
			Name = 'Test Entity Involvement',
			LLC_BI__Borrower_Type__c = 'LLC_BI__Borrower_Type__c',
			LLC_BI__Address__c = 'LLC_BI__Address__c'
		);
		insert entity;
		return entity;
	}

	static LLC_BI__Legal_Entities__c createLegalEntity(LLC_BI__Treasury_Service__c treasuryService, Account acct) {
		LLC_BI__Legal_Entities__c entity = new LLC_BI__Legal_Entities__c(
			LLC_BI__Treasury_Service__c = treasuryService.Id,
			LLC_BI__Account__c = acct.Id,
			Name = 'Test Entity Involvement',
			LLC_BI__Borrower_Type__c = 'LLC_BI__Borrower_Type__c',
			LLC_BI__Address__c = 'LLC_BI__Address__c'
		);
		insert entity;
		return entity;
	}
	
	static LLC_BI__Loan__c createLoan(){
	    Account account = new Account(Name='Cycle Smith LLC');
        account.Type = 'Business';
        account.ShippingCountry = 'US';
        account.ShippingStreet = '250 S 1300 E';
        account.ShippingCity = 'SALT LAKE CITY';
        account.ShippingState = 'UT';
        account.ShippingPostalCode = '84102-2609';
        account.BillingCountry = 'US';
        account.BillingStreet = '250 S 1300 E';
        account.BillingCity = 'SALT LAKE CITY';
        account.BillingState = 'UT';
        account.BillingPostalCode = '84102-2609';
        account.LLC_BI__Duns_Number__c = '123456';
        account.Sic = '14732';
        account.Phone = '8185551212';
        account.LLC_BI__Phone_Number_Type__c = 'Work';
        account.LLC_BI__Tax_Identification_Number__c = '555555555';
        account.LLC_BI__Tax_Identification_Number_PE__c = '555555555';
        //Added to satisfy a validation rule on EI. Chintan Adhyapak, West Monroe Partners, August 07, 2018
        account.LLC_BI__Status__c = 'Participation Relationship';
        
        
        insert account;
        Account account2 = new Account(Name='Mildred Candytuft');
        account2.Type = 'Individual';
        account2.ShippingCountry = 'US';
        account2.ShippingStreet = '556 Saxophone Wy';
        account2.ShippingCity = 'Macon';
        account2.ShippingState = 'GA';
        account2.ShippingPostalCode = '31204';
        account2.BillingCountry = 'US';
        account2.BillingStreet = '556 Saxophone Wy';
        account2.BillingCity = 'Macon';
        account2.BillingState = 'GA';
        account2.BillingPostalCode = '31204';
        account2.Phone = '8185551212';
        account2.LLC_BI__Phone_Number_Type__c = 'Work';
        account2.LLC_BI__Tax_Identification_Number__c = '666346873';
        account2.LLC_BI__Tax_Identification_Number_PE__c = '666346873';
        //Added to satisfy a validation rule on EI. Chintan Adhyapak, West Monroe Partners, August 07, 2018
        account2.LLC_BI__Status__c = 'Participation Relationship';
        
        insert account2;
        
        // Contact contact1 = new Contact();
        // contact1.AccountId = account.Id;
        // contact1.LastName = 'aaavvva';
        // contact1.FirstName = 'bbbvvvb';
        // insert contact1;
        
        Contact contact = new Contact();
        contact.AccountId = account2.Id;
        contact.LLC_BI__SS__c = '666346873';
        contact.LLC_BI__SS_PE__c = '666346873';
        contact.LastName = 'Candytuft';
        contact.FirstName = 'Mildred';
        contact.LLC_BI__Gender__c = 'Female';
        contact.Birthdate = date.ValueOf('1963-06-15');
        contact.MailingCountry = 'US';
        contact.MailingStreet = '556 Saxophone Wy';
        contact.MailingCity = 'Macon';
        contact.MailingState = 'GA';
        contact.MailingPostalCode = '31204';
        insert contact;
        
        LLC_BI__Loan__c loan = new LLC_BI__Loan__c(Name='Junk Loan For Test');
        loan.LLC_BI__Account__c = account.Id;
        
        LLC_BI__Product_Line__c newPL = new LLC_BI__Product_Line__c(
            Name = 'Test Line');
        insert newPL;
        
        LLC_BI__Product_Type__c newPT = new LLC_BI__Product_Type__c(
            LLC_BI__Product_Line__c = newPL.Id,
            Name = 'Test Type');
        insert newPT;
        
        LLC_BI__Product__c newP = new LLC_BI__Product__c(
            LLC_BI__Product_Type__c = newPT.Id,
            Name = 'Test Product');
        insert newP;
        
        loan.LLC_BI__Product_Reference__c = newP.Id;
        
        
        loan.put('LLC_BI__Amount__c',800000);
        
        insert loan;
        
        LLC_BI__Legal_Entities__c entities = new LLC_BI__Legal_Entities__c();
        entities.LLC_BI__Account__c = account.Id;
        entities.LLC_BI__Loan__c = loan.Id;
        entities.LLC_BI__Borrower_Type__c = 'Borrower';
        insert entities;
        
        LLC_BI__Legal_Entities__c entities2 = new LLC_BI__Legal_Entities__c();
        entities2.LLC_BI__Account__c = account2.Id;
        entities2.LLC_BI__Loan__c = loan.Id;
        entities2.LLC_BI__Borrower_Type__c = 'Borrower';
        insert entities2;
        
        LLC_BI__Connection_Role__c role = new LLC_BI__Connection_Role__c(Name='Owner');
        role.LLC_BI__Role_Type__c = 'Business';
        role.LLC_BI__Sort_Order__c = 1;
        insert role;
        
        LLC_BI__Connection__c conn = new LLC_BI__Connection__c();
        conn.LLC_BI__Connected_To__c = account2.Id;
        conn.LLC_BI__Ownership_Percent__c = 80;
        conn.LLC_BI__Connected_From__c = account2.Id;
        conn.LLC_BI__Connection_Role__c = role.Id;
        insert conn;
        
        return loan;
	}
	
    
    @isTest
    static void setupData(){
        
        new nFUSE.DataInstaller().onInstall(null);
        
        //set up for deposit 
        
        LLC_BI__Branch__c testBranch = createBranch();

		LLC_BI__Deposit__c testDeposit = createDeposit();
		testDeposit.LLC_BI__CD_Term__c = '15 years';
		testDeposit.LLC_BI__Originating_Branch__c = testBranch.Id;

		LLC_BI__Ownership_Structure_Type__c testOST = createOwnershipStructureType();
		testDeposit.LLC_BI__Ownership_Structure_Type__c = testOST.Id;

		LLC_BI__Funding_Method_Type__c sFunMethType = createFundingMethodType();
		LLC_BI__Funding_Method__c sFunMeth = createFundingMethod(sFunMethType);
		testDeposit.LLC_BI__Funding_Method__c = sFunMeth.Id;

		LLC_BI__Product_Line__c testProductLine = createProductLine();
		LLC_BI__Product_Type__c testProductType = createProductType(testProductLine);
		LLC_BI__Product_Feature__c testProductFeature = createProductFeature();
		LLC_BI__Product__c testProduct = createProduct(testProductType, testProductFeature);
		testDeposit.LLC_BI__Product_Reference__c = testProduct.Id;

		Account sIndividualAcct = createAccount('Individual');
		Contact sIndividualContact = createPrimaryContact(sIndividualAcct);
		sIndividualContact.LLC_BI__Drivers_License__c = '2017';

		Account sBusinessAcct = createAccount('Business');
		Contact sBizContact = createPrimaryContact(sBusinessAcct);
		sBizContact.Department = 'Test Department';

		LLC_BI__Treasury_Service__c treasuryService = createTreasuryService();

		LLC_BI__Product_Line__c treasuryProductLine = createProductLine('Treasury Product Line');
		LLC_BI__Product_Type__c treasuryProductType = createProductType(treasuryProductLine);
		LLC_BI__Product_Feature__c treasuryProductFeature = createProductFeature();
		LLC_BI__Product__c treasuryProduct = createProduct(treasuryProductType, treasuryProductFeature);
		treasuryService.LLC_BI__Product_Reference__c = treasuryProduct.Id;

		Account treasuryAcct = createAccount('Individual');
		Contact treasuryContact = createPrimaryContact(treasuryAcct);
		treasuryContact.LLC_BI__Drivers_License__c = '2018';

		LLC_BI__Analyzed_Account__c analyzedAccount = createAnalyzedAccount();
		analyzedAccount.LLC_BI__Deposit_Reference__c = testDeposit.Id;
		analyzedAccount.LLC_BI__Treasury_Service_Reference__c = treasuryService.Id;

		update new List<SObject> {testDeposit, sIndividualContact, sBizContact, treasuryService, treasuryContact, analyzedAccount};

		LLC_BI__Legal_Entities__c sInvolve1 = createLegalEntity(testDeposit, sIndividualAcct);
		LLC_BI__Legal_Entities__c sInvolve2 = createLegalEntity(testDeposit, sBusinessAcct);
		LLC_BI__Legal_Entities__c sInvolve3 = createLegalEntity(treasuryService, treasuryAcct);
		
		//set up for loan and customer
		
        Account account = new Account(Name='Cycle Smith LLC');
        account.Type = 'Business';
        account.ShippingCountry = 'US';
        account.ShippingStreet = '250 S 1300 E';
        account.ShippingCity = 'SALT LAKE CITY';
        account.ShippingState = 'UT';
        account.ShippingPostalCode = '84102-2609';
        account.BillingCountry = 'US';
        account.BillingStreet = '250 S 1300 E';
        account.BillingCity = 'SALT LAKE CITY';
        account.BillingState = 'UT';
        account.BillingPostalCode = '84102-2609';
        account.LLC_BI__Duns_Number__c = '123456';
        account.Sic = '14732';
        account.Phone = '8185551212';
        account.LLC_BI__Phone_Number_Type__c = 'Work';
        account.LLC_BI__Tax_Identification_Number__c = '555555555';
        account.LLC_BI__Tax_Identification_Number_PE__c = '555555555';
        //Added to satisfy a validation rule on EI. Chintan Adhyapak, West Monroe Partners, August 07, 2018
        account.LLC_BI__Status__c = 'Participation Relationship';
        
        insert account;
        setuprelationshipIdBusiness = account.Id;
        Account account2 = new Account(Name='Mildred Candytuft');
        account2.Type = 'Individual';
        account2.ShippingCountry = 'US';
        account2.ShippingStreet = '556 Saxophone Wy';
        account2.ShippingCity = 'Macon';
        account2.ShippingState = 'GA';
        account2.ShippingPostalCode = '31204';
        account2.BillingCountry = 'US';
        account2.BillingStreet = '556 Saxophone Wy';
        account2.BillingCity = 'Macon';
        account2.BillingState = 'GA';
        account2.BillingPostalCode = '31204';
        account2.Phone = '8185551212';
        account2.LLC_BI__Phone_Number_Type__c = 'Work';
        account2.LLC_BI__Tax_Identification_Number__c = '666346873';
        account2.LLC_BI__Tax_Identification_Number_PE__c = '666346873';
        //Added to satisfy a validation rule on EI. Chintan Adhyapak, West Monroe Partners, August 07, 2018
        account2.LLC_BI__Status__c = 'Participation Relationship';
        
        insert account2;
        setuprelationshipId = account2.Id;
        
        // Contact contact1 = new Contact();
        // contact1.AccountId = account.Id;
        // contact1.LastName = 'aaavvva';
        // contact1.FirstName = 'bbbvvvb';
        // insert contact1;
        
        Contact contact = new Contact();
        contact.AccountId = account2.Id;
        contact.LLC_BI__SS__c = '666346873';
        contact.LLC_BI__SS_PE__c = '666346873';
        contact.LastName = 'Candytuft';
        contact.FirstName = 'Mildred';
        contact.LLC_BI__Gender__c = 'Female';
        contact.Birthdate = date.ValueOf('1963-06-15');
        contact.MailingCountry = 'US';
        contact.MailingStreet = '556 Saxophone Wy';
        contact.MailingCity = 'Macon';
        contact.MailingState = 'GA';
        contact.MailingPostalCode = '31204';
        insert contact;
        setupcontactId = contact.Id;
        
        LLC_BI__Loan__c loan = new LLC_BI__Loan__c(Name='Junk Loan For Test');
        loan.LLC_BI__Account__c = setuprelationshipIdBusiness;
        
        LLC_BI__Product_Line__c newPL = new LLC_BI__Product_Line__c(
            Name = 'Test Line');
        insert newPL;
        
        LLC_BI__Product_Type__c newPT = new LLC_BI__Product_Type__c(
            LLC_BI__Product_Line__c = newPL.Id,
            Name = 'Test Type');
        insert newPT;
        
        LLC_BI__Product__c newP = new LLC_BI__Product__c(
            LLC_BI__Product_Type__c = newPT.Id,
            Name = 'Test Product');
        insert newP;
        
        loan.LLC_BI__Product_Reference__c = newP.Id;
        
        
        loan.put('LLC_BI__Amount__c',800000);
        
        insert loan;
        setuploanId = loan.Id;
        
        LLC_BI__Legal_Entities__c entities = new LLC_BI__Legal_Entities__c();
        entities.LLC_BI__Account__c = account.Id;
        entities.LLC_BI__Loan__c = loan.Id;
        entities.LLC_BI__Borrower_Type__c = 'Borrower';
        insert entities;
        
        LLC_BI__Legal_Entities__c entities2 = new LLC_BI__Legal_Entities__c();
        entities2.LLC_BI__Account__c = account2.Id;
        entities2.LLC_BI__Loan__c = loan.Id;
        entities2.LLC_BI__Borrower_Type__c = 'Borrower';
        insert entities2;
        
        LLC_BI__Connection_Role__c role = new LLC_BI__Connection_Role__c(Name='Owner');
        role.LLC_BI__Role_Type__c = 'Business';
        role.LLC_BI__Sort_Order__c = 1;
        insert role;
        
        LLC_BI__Connection__c conn = new LLC_BI__Connection__c();
        conn.LLC_BI__Connected_To__c = account2.Id;
        conn.LLC_BI__Ownership_Percent__c = 80;
        conn.LLC_BI__Connected_From__c = setuprelationshipId;
        conn.LLC_BI__Connection_Role__c = role.Id;
        insert conn;
        
        
        nFUSE__Transaction_Log__c log = new nFUSE__Transaction_Log__c(Name='TestLog',nFUSE__External_Id__c='123123123'); //possible namespace issue
        log.nFUSE__Action__c = 'new';
        log.nFUSE__Api_Version__c = '1';
        log.nFUSE__App_Plugin__c = 'CoreBooking';
        log.nFUSE__Primary_Object_Id__c = setuprelationshipIdBusiness;
        log.nFUSE__Requested_By_User_Id__c = 'user';
        log.nFUSE__Transaction_Status__c = 'new';
        log.nFUSE__External_Id__c = 'test';
        insert log;
        setupExternalId = log.nFUSE__External_Id__c;
		
		
        
    }
    
    
    
    @isTest
    private static void testOrchestratorServiceLocator(){
        
        try{
            nFUSE.PackageServiceRequest request = new nFUSE.PackageServiceRequest(CBConfiguration.PLUGIN_NAME, CBConfiguration.PLUGIN_VERSION, null);
        
            test.startTest();
            nFUSE.SendService service = CBOrchestrator.serviceFinder(request,'cheese');
            test.stopTest();
            system.assertEquals(true,false);
        }catch(Exception e){
            system.assertEquals(true,e.getMessage().toLowerCase().contains('there was an error locating the service "cheese"'));
        }
        
    }
    
    @isTest
    private static void testOrchestratorServiceLocatorSucceeds(){
        new CBActivator().onActivate();
        nFUSE.PackageServiceRequest request = new nFUSE.PackageServiceRequest(CBConfiguration.PLUGIN_NAME, CBConfiguration.PLUGIN_VERSION, null);
        try{
            nFUSE.SendService service = CBOrchestrator.serviceFinder(request,'LoanSendService');
            system.assertEquals(true,service != null);
        }catch(Exception e){
            system.assertEquals(true,false);
        }
        
    }
    
    @isTest
    private static void testOrchestratorServiceLocatorFailsOtherError(){
        //new CBActivator().onActivate();
        nFUSE.PackageServiceRequest request = new nFUSE.PackageServiceRequest(CBConfiguration.PLUGIN_NAME, CBConfiguration.PLUGIN_VERSION, null);
        try{
            CBOrchestrator.forceTestingException = true;
            nFUSE.SendService service = CBOrchestrator.serviceFinder(request,'LoanSendService');
            system.assertEquals(true,false);
        }catch(Exception e){
            system.assertEquals(true,e.getMessage().toLowerCase().contains('there was an error obtaining'));
        }
        
    }
    
    //book loan
    
    @isTest
    private static void testBookLoan(){
        
        setupData();
        
        nFUSE.PackageServiceRequest servRequest = new nFUSE.PackageServiceRequest(
			CBConfiguration.PLUGIN_NAME, CBConfiguration.PLUGIN_VERSION, null);
		nFUSE.ServiceLocator locator = new nFUSE.ServiceLocator();
		locator.register(servRequest, nFUSE.SendService.class, nFUSE.TestServices.SendServiceMock.class, CBConfiguration.LOANSENDSERVICENAME);
        
        CBOrchestrator orch = new CBOrchestrator();
        
        test.startTest();
        CBEntities.CoreBookingResponse response = orch.BookLoan(setuploanId,null,null,null);
        test.stopTest();
        
        system.assertEquals(true,response.IsSuccessful);
        
    }
    
    @isTest
    private static void testBookLoanWithValidTransactionLogPassedIn(){
        
        setupData();
        
        nFUSE.PackageServiceRequest servRequest = new nFUSE.PackageServiceRequest(
			CBConfiguration.PLUGIN_NAME, CBConfiguration.PLUGIN_VERSION, null);
		nFUSE.ServiceLocator locator = new nFUSE.ServiceLocator();
		locator.register(servRequest, nFUSE.SendService.class, nFUSE.TestServices.SendServiceMock.class, CBConfiguration.LOANSENDSERVICENAME);
        
        CBOrchestrator orch = new CBOrchestrator();
        
        test.startTest();
        CBEntities.CoreBookingResponse response = orch.BookLoan(setuploanId,null,null,setupExternalId);
        //test the status of the transaction
        nFUSE__Transaction_Log__c transactionLog = [
			SELECT
				Id,
				CreatedDate,
				nFUSE__Transaction_Status__c
			FROM
				nFUSE__Transaction_Log__c
			WHERE
				nFUSE__External_Id__c = :setupExternalId
		][0];
		
        test.stopTest();
        
        system.assertEquals(true,response.IsSuccessful);
        system.assertEquals(CBConfiguration.MIDDLEWARE_ACK_STATUS,transactionLog.nFUSE__Transaction_Status__c);
    }
    
    @isTest
    private static void testOrchPrepareLoanBookingMessage(){
        setupData();
        nFUSE.PackageServiceRequest request = null;
        try{
            nFUSE.MiddlewareMessage msg = CBOrchestrator.prepareLoanBookingMessage('action', request, setuploanId, null, null);
            system.assertEquals(true,false);
        }catch(Exception e){
            system.assertEquals(true,e.getMessage().toLowerCase().contains('request was not expected to be null'));
        }
        
    }
    
    @isTest
    private static void testOrchPrepareLoanBookingMessageWithOtherFieldsNotBlank(){
        
        setupData();
        
        nFUSE.PackageServiceRequest request = new nFUSE.PackageServiceRequest(CBConfiguration.PLUGIN_NAME, CBConfiguration.PLUGIN_VERSION, null);
        request.primaryObjectId = setuploanId;
        
        try{
            nFUSE.MiddlewareMessage msg = CBOrchestrator.prepareLoanBookingMessage('action', request, setuploanId, 'notblank', 'notblank');
            system.assertEquals(true,true);
        }catch(Exception e){
            system.assertEquals('test',e.getMessage());
        }
        
    }
    
    
    //book customer
    
    @isTest
    private static void testBookCustomer(){
        
        setupData();
        
        nFUSE.PackageServiceRequest servRequest = new nFUSE.PackageServiceRequest(
			CBConfiguration.PLUGIN_NAME, CBConfiguration.PLUGIN_VERSION, null);
		nFUSE.ServiceLocator locator = new nFUSE.ServiceLocator();
		locator.register(servRequest, nFUSE.SendService.class, nFUSE.TestServices.SendServiceMock.class, CBConfiguration.CUSTOMERSENDSERVICENAME);
        
        CBOrchestrator orch = new CBOrchestrator();
        
        test.startTest();
        CBEntities.CoreBookingResponse response = orch.BookCustomer(setuprelationshipId,null,null,null);
        test.stopTest();
        
        system.assertEquals(true,response.IsSuccessful);
        
    }
    
    @isTest
    private static void testBookCustomerWithValidTransactionLogPassedIn(){
        
        setupData();
        
        nFUSE.PackageServiceRequest servRequest = new nFUSE.PackageServiceRequest(
			CBConfiguration.PLUGIN_NAME, CBConfiguration.PLUGIN_VERSION, null);
		nFUSE.ServiceLocator locator = new nFUSE.ServiceLocator();
		locator.register(servRequest, nFUSE.SendService.class, nFUSE.TestServices.SendServiceMock.class, CBConfiguration.CUSTOMERSENDSERVICENAME);
        
        CBOrchestrator orch = new CBOrchestrator();
        
        test.startTest();
        CBEntities.CoreBookingResponse response = orch.BookCustomer(setuprelationshipId,null,null,setupExternalId);
        //test the status of the transaction
        nFUSE__Transaction_Log__c transactionLog = [
			SELECT
				Id,
				CreatedDate,
				nFUSE__Transaction_Status__c
			FROM
				nFUSE__Transaction_Log__c
			WHERE
				nFUSE__External_Id__c = :setupExternalId
		][0];
		
        test.stopTest();
        
        system.assertEquals(true,response.IsSuccessful);
        system.assertEquals(CBConfiguration.IN_PROGRESS_STATUS,transactionLog.nFUSE__Transaction_Status__c);
    }
    
    @isTest
    private static void testOrchPrepareCustomerBookingMessage(){
        setupData();
        nFUSE.PackageServiceRequest request = null;
        try{
            nFUSE.MiddlewareMessage msg = CBOrchestrator.prepareCustomerBookingMessage('action', request, setuprelationshipId, null, null);
            system.assertEquals(true,false);
        }catch(Exception e){
            system.assertEquals(true,e.getMessage().toLowerCase().contains('request was not expected to be null'));
        }
        
    }
    
    @isTest
    private static void testOrchPrepareCustomerBookingMessageWithOtherFieldsNotBlank(){
        
        setupData();
        
        nFUSE.PackageServiceRequest request = new nFUSE.PackageServiceRequest(CBConfiguration.PLUGIN_NAME, CBConfiguration.PLUGIN_VERSION, null);
        request.primaryObjectId = setuprelationshipId;
        
        try{
            nFUSE.MiddlewareMessage msg = CBOrchestrator.prepareCustomerBookingMessage('action', request, setuprelationshipId, 'notblank', 'notblank');
            system.assertEquals(true,true);
        }catch(Exception e){
            system.assertEquals('test',e.getMessage());
        }
        
    }
    
    //book deposit
    
    @isTest
    private static void testBookDeposit(){
        
        setupData();
        
        List<LLC_BI__Deposit__c> dpsts = [SELECT Id from LLC_BI__Deposit__c];
        
        nFUSE.PackageServiceRequest servRequest = new nFUSE.PackageServiceRequest(
			CBConfiguration.PLUGIN_NAME, CBConfiguration.PLUGIN_VERSION, null);
		nFUSE.ServiceLocator locator = new nFUSE.ServiceLocator();
		locator.register(servRequest, nFUSE.SendService.class, nFUSE.TestServices.SendServiceMock.class, CBConfiguration.DEPOSITSENDSERVICENAME);
        
        CBOrchestrator orch = new CBOrchestrator();
        
        test.startTest();
        CBEntities.CoreBookingResponse response = orch.BookDeposit(dpsts[0].Id,null,null,null);
        test.stopTest();
        
        system.assertEquals(true,response.IsSuccessful);
        
    }
    
    @isTest
    private static void testBookDepositWithValidTransactionLogPassedIn(){
        
        setupData();
        
        List<LLC_BI__Deposit__c> dpsts = [SELECT Id from LLC_BI__Deposit__c];
        
        nFUSE.PackageServiceRequest servRequest = new nFUSE.PackageServiceRequest(
			CBConfiguration.PLUGIN_NAME, CBConfiguration.PLUGIN_VERSION, null);
		nFUSE.ServiceLocator locator = new nFUSE.ServiceLocator();
		locator.register(servRequest, nFUSE.SendService.class, nFUSE.TestServices.SendServiceMock.class, CBConfiguration.DEPOSITSENDSERVICENAME);
        
        CBOrchestrator orch = new CBOrchestrator();
        
        test.startTest();
        CBEntities.CoreBookingResponse response = orch.BookDeposit(dpsts[0].Id,null,null,setupExternalId);
        //test the status of the transaction
        nFUSE__Transaction_Log__c transactionLog = [
			SELECT
				Id,
				CreatedDate,
				nFUSE__Transaction_Status__c
			FROM
				nFUSE__Transaction_Log__c
			WHERE
				nFUSE__External_Id__c = :setupExternalId
		][0];
		
        test.stopTest();
        
        system.assertEquals(true,response.IsSuccessful);
        system.assertEquals(CBConfiguration.IN_PROGRESS_STATUS,transactionLog.nFUSE__Transaction_Status__c);
    }
    
    @isTest
    private static void testOrchPrepareDepositBookingMessage(){
        setupData();
        
        List<LLC_BI__Deposit__c> dpsts = [SELECT Id from LLC_BI__Deposit__c];
        
        nFUSE.PackageServiceRequest request = null;
        try{
            nFUSE.MiddlewareMessage msg = CBOrchestrator.prepareDepositBookingMessage('action', request, dpsts[0].Id, null, null);
            system.assertEquals(true,false);
        }catch(Exception e){
            system.assertEquals(true,e.getMessage().toLowerCase().contains('request was not expected to be null'));
        }
        
    }
    
    @isTest
    private static void testOrchPrepareDepositBookingMessageWithOtherFieldsNotBlank(){
        
        setupData();
        
        List<LLC_BI__Deposit__c> dpsts = [SELECT Id from LLC_BI__Deposit__c];
        
        nFUSE.PackageServiceRequest request = new nFUSE.PackageServiceRequest(CBConfiguration.PLUGIN_NAME, CBConfiguration.PLUGIN_VERSION, null);
        request.primaryObjectId = dpsts[0].Id;
        
        try{
            nFUSE.MiddlewareMessage msg = CBOrchestrator.prepareDepositBookingMessage('action', request, dpsts[0].Id, 'notblank', 'notblank');
            system.assertEquals(true,true);
        }catch(Exception e){
            system.assertEquals('test',e.getMessage());
        }
        
    }
    
    
    @isTest
    private static void testTransactionLogPolling(){
        
        String accountId = createAccount().Id;
        
        system.assertEquals(true,!String.isBlank(accountId));
        
        nFUSE__Transaction_Log__c log = new nFUSE__Transaction_Log__c(Name='TestLog',nFUSE__External_Id__c='123123123'); //possible namespace issue
        log.nFUSE__Action__c = 'new';
        log.nFUSE__Api_Version__c = '1';
        log.nFUSE__App_Plugin__c = 'CoreBooking';
        log.nFUSE__Primary_Object_Id__c = accountId;
        log.nFUSE__Requested_By_User_Id__c = 'user';
        log.nFUSE__Transaction_Status__c = 'new';
        log.nFUSE__External_Id__c = 'test';
        insert log;
        
        String externalId = log.nFUSE__External_Id__c;
        
        CBOrchestrator orchestrator = new CBOrchestrator();
        
        test.startTest();
        CBEntities.TransactionLogResponse response = orchestrator.GetTransactionLogDetails(externalId);
        test.stopTest();
        
        system.assertEquals('new',response.Status);
        
    }
    
    @isTest
    private static void testTransactionLogPollingIsComplete(){
        
        String accountId = createAccount().Id;
        
        system.assertEquals(true,!String.isBlank(accountId));
        
        nFUSE__Transaction_Log__c log = new nFUSE__Transaction_Log__c(Name='TestLog',nFUSE__External_Id__c='123123123'); //possible namespace issue
        log.nFUSE__Action__c = 'new';
        log.nFUSE__Api_Version__c = '1';
        log.nFUSE__App_Plugin__c = 'CoreBooking';
        log.nFUSE__Primary_Object_Id__c = accountId;
        log.nFUSE__Requested_By_User_Id__c = 'user';
        log.nFUSE__Transaction_Status__c = 'erRor';
        log.nFUSE__External_Id__c = 'test';
        insert log;
        
        String externalId = log.nFUSE__External_Id__c;
        
        CBOrchestrator orchestrator = new CBOrchestrator();
        
        test.startTest();
        CBEntities.TransactionLogResponse response = orchestrator.GetTransactionLogDetails(externalId);
        test.stopTest();
        
        system.assertEquals(true,response.IsComplete);
        
    }
    
    @isTest
    private static void testTransactionLogPollingIsCompleteFalse(){
        
        String accountId = createAccount().Id;
        
        system.assertEquals(true,!String.isBlank(accountId));
        
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
        
        CBOrchestrator orchestrator = new CBOrchestrator();
        
        test.startTest();
        CBEntities.TransactionLogResponse response = orchestrator.GetTransactionLogDetails(externalId);
        test.stopTest();
        
        system.assertEquals(false,response.IsComplete);
        
    }
    
    @isTest
    private static void testTransactionLogPollingIsSuccessfulFalse(){
        
        String accountId = createAccount().Id;
        
        system.assertEquals(true,!String.isBlank(accountId));
        
        nFUSE__Transaction_Log__c log = new nFUSE__Transaction_Log__c(Name='TestLog',nFUSE__External_Id__c='123123123'); //possible namespace issue
        log.nFUSE__Action__c = 'new';
        log.nFUSE__Api_Version__c = '1';
        log.nFUSE__App_Plugin__c = 'CoreBooking';
        log.nFUSE__Primary_Object_Id__c = accountId;
        log.nFUSE__Requested_By_User_Id__c = 'user';
        log.nFUSE__Transaction_Status__c = 'error';
        log.nFUSE__External_Id__c = 'test';
        insert log;
        
        String externalId = log.nFUSE__External_Id__c;
        
        CBOrchestrator orchestrator = new CBOrchestrator();
        
        test.startTest();
        CBEntities.TransactionLogResponse response = orchestrator.GetTransactionLogDetails(externalId);
        test.stopTest();
        
        system.assertEquals(false,response.IsSuccessful);
        
    }
    
    
    
    @isTest
    private static void testShouldBookCustomer(){
        
        String accountId = createAccount().Id;
        
        test.startTest();
        Boolean should = CBOrchestrator.ShouldBookCustomer(accountId);
        test.stopTest();
        
        system.assertEquals(true,should);
        
    }
    
    @isTest
    private static void testShouldBookCustomerFalse(){
        
        Account account = createAccount();
        account.LLC_BI__lookupKey__c = 'something';
        update account;
        
        test.startTest();
        Boolean should = CBOrchestrator.ShouldBookCustomer(account.Id);
        test.stopTest();
        
        system.assertEquals(true,!should);
        
    }
    
    
    
    
    @isTest
    private static void testShouldBookDeposit(){
        
        String depositId = createDeposit().Id;
        
        test.startTest();
        Boolean should = CBOrchestrator.ShouldBookDeposit(depositId);
        test.stopTest();
        
        system.assertEquals(true,should);
        
    }
    
    @isTest
    private static void testShouldBookDepositFalse(){
        
        LLC_BI__Deposit__c deposit = createDeposit();
        deposit.LLC_BI__lookupKey__c = 'something';
        update deposit;
        
        test.startTest();
        Boolean should = CBOrchestrator.ShouldBookDeposit(deposit.Id);
        test.stopTest();
        
        system.assertEquals(true,!should);
        
    }
    
    
    
    
    
    @isTest
    private static void testShouldBookLoan(){
        
        String loanId = createLoan().Id;
        
        test.startTest();
        Boolean should = CBOrchestrator.ShouldBookLoan(loanId);
        test.stopTest();
        
        system.assertEquals(true,should);
        
    }
    
    @isTest
    private static void testShouldBookLoanFalse(){
        
        LLC_BI__Loan__c loan = createLoan();
        loan.LLC_BI__lookupKey__c = 'something';
        update loan;
        
        test.startTest();
        Boolean should = CBOrchestrator.ShouldBookLoan(loan.Id);
        test.stopTest();
        
        system.assertEquals(true,!should);
        
    }
    
    
    
    
    
    @isTest
    private static void testBookLoanFailsWhenAlreadyBooked(){
        
        LLC_BI__Loan__c loan = createLoan();
        loan.LLC_BI__lookupKey__c = 'something';
        update loan;
        
        nFUSE.PackageServiceRequest servRequest = new nFUSE.PackageServiceRequest(
			CBConfiguration.PLUGIN_NAME, CBConfiguration.PLUGIN_VERSION, null);
		nFUSE.ServiceLocator locator = new nFUSE.ServiceLocator();
		locator.register(servRequest, nFUSE.SendService.class, nFUSE.TestServices.SendServiceMock.class, CBConfiguration.LOANSENDSERVICENAME);
        
        CBOrchestrator orch = new CBOrchestrator();
        
        test.startTest();
        CBEntities.CoreBookingResponse response = orch.BookLoan(loan.Id,null,null,null);
        test.stopTest();
        
        system.assertEquals(false,response.IsSuccessful);
        
    }
    
    @isTest
    private static void testBookCustomerFailsWhenAlreadyBooked(){
        
        Account account = createAccount();
        account.LLC_BI__lookupKey__c = 'something';
        update account;
        
        nFUSE.PackageServiceRequest servRequest = new nFUSE.PackageServiceRequest(
			CBConfiguration.PLUGIN_NAME, CBConfiguration.PLUGIN_VERSION, null);
		nFUSE.ServiceLocator locator = new nFUSE.ServiceLocator();
		locator.register(servRequest, nFUSE.SendService.class, nFUSE.TestServices.SendServiceMock.class, CBConfiguration.CUSTOMERSENDSERVICENAME);
        
        CBOrchestrator orch = new CBOrchestrator();
        
        test.startTest();
        CBEntities.CoreBookingResponse response = orch.BookCustomer(account.Id,null,null,null);
        test.stopTest();
        
        system.assertEquals(false,response.IsSuccessful);
        
    }
    
    @isTest
    private static void testBookDepositFailsWhenAlreadyBooked(){
        
        LLC_BI__Deposit__c deposit = createDeposit();
        deposit.LLC_BI__lookupKey__c = 'something';
        update deposit;
        
        nFUSE.PackageServiceRequest servRequest = new nFUSE.PackageServiceRequest(
			CBConfiguration.PLUGIN_NAME, CBConfiguration.PLUGIN_VERSION, null);
		nFUSE.ServiceLocator locator = new nFUSE.ServiceLocator();
		locator.register(servRequest, nFUSE.SendService.class, nFUSE.TestServices.SendServiceMock.class, CBConfiguration.DEPOSITSENDSERVICENAME);
        
        CBOrchestrator orch = new CBOrchestrator();
        
        test.startTest();
        CBEntities.CoreBookingResponse response = orch.BookDeposit(deposit.Id,null,null,null);
        test.stopTest();
        
        system.assertEquals(false,response.IsSuccessful);
        
    }
    
}