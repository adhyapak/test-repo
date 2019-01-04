@isTest
private class TestCBInvocable{
    
    public static String setuploanId;
    public static String setuprelationshipId;
    public static String setuprelationshipIdBusiness;
    public static String setupcontactId;
    public static String setupExternalId;
    public static String setupDepositId;
    
    @isTest
    static void setupData(){
    	
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
    
    @IsTest
    private static void test_performloaninvocable(){
        
        setupData();
        
        new CBActivator().onActivate();
        
        List<CBEntities.CBLoanCalloutInputParams> inputParams = new List<CBEntities.CBLoanCalloutInputParams>();
        CBEntities.CBLoanCalloutInputParams param = new CBEntities.CBLoanCalloutInputParams();
        
        param.loanId = setuploanId;
        param.userSessionId = 'asdfasdfadsfasdf';
        param.requestedByUserId = 'user';
        param.externalReferenceId = setupExternalId;
        
        inputParams.add(param);
        
        try {
            Test.startTest();
            CBLoanInvocable.bookLoan(inputParams);
            Test.stopTest();
            system.assertEquals(true,true);
        } catch(Exception ex) {
            system.assertEquals(true,false);
        }
        
    }
    
    @IsTest
    private static void test_performcustomerinvocable(){
        
        setupData();
        
        new CBActivator().onActivate();
        
        List<CBEntities.CBCustomerCalloutInputParams> inputParams = new List<CBEntities.CBCustomerCalloutInputParams>();
        CBEntities.CBCustomerCalloutInputParams param = new CBEntities.CBCustomerCalloutInputParams();
        
        param.relationshipId = setuprelationshipId;
        param.userSessionId = 'asdfasdfadsfasdf';
        param.requestedByUserId = 'user';
        param.externalReferenceId = setupExternalId;
        
        inputParams.add(param);
        
        try {
            Test.startTest();
            CBCustomerInvocable.bookCustomer(inputParams);
            Test.stopTest();
            system.assertEquals(true,true);
        } catch(Exception ex) {
            system.assertEquals(true,false);
        }
        
    }
    
    @IsTest
    private static void test_performdepositinvocable(){
        
        setupData();
        
        new CBActivator().onActivate();
        
        List<CBEntities.CBDepositCalloutInputParams> inputParams = new List<CBEntities.CBDepositCalloutInputParams>();
        CBEntities.CBDepositCalloutInputParams param = new CBEntities.CBDepositCalloutInputParams();
        
        param.depositId = setupDepositId;
        param.userSessionId = 'asdfasdfadsfasdf';
        param.requestedByUserId = 'user';
        param.externalReferenceId = setupExternalId;
        
        inputParams.add(param);
        
        try {
            Test.startTest();
            CBDepositInvocable.bookDeposit(inputParams);
            Test.stopTest();
            system.assertEquals(true,true);
        } catch(Exception ex) {
            system.assertEquals(true,false);
        }
        
    }
    
    
    
    
    @IsTest
    private static void test_performloaninvocablesilentlyfails(){
        
        setupData();
        
        new CBActivator().onActivate();
        
        List<CBEntities.CBLoanCalloutInputParams> inputParams = new List<CBEntities.CBLoanCalloutInputParams>();
        CBEntities.CBLoanCalloutInputParams param = new CBEntities.CBLoanCalloutInputParams();
        
        param.loanId = setuploanId;
        param.userSessionId = 'asdfasdfadsfasdf';
        param.requestedByUserId = 'user';
        param.externalReferenceId = setupExternalId;
        
        inputParams.add(param);
        
        try {
            Test.startTest();
            CBPerformLoanBatchable.forceTestingException = true;
            CBLoanInvocable.bookLoan(inputParams);
            Test.stopTest();
            system.assertEquals(true,true);
        } catch(Exception ex) {
            system.assertEquals(true,false);
        }
        
    }
    
    @IsTest
    private static void test_performcustomerinvocablesilentlyfails(){
        
        setupData();
        
        new CBActivator().onActivate();
        
        List<CBEntities.CBCustomerCalloutInputParams> inputParams = new List<CBEntities.CBCustomerCalloutInputParams>();
        CBEntities.CBCustomerCalloutInputParams param = new CBEntities.CBCustomerCalloutInputParams();
        
        param.relationshipId = setuprelationshipId;
        param.userSessionId = 'asdfasdfadsfasdf';
        param.requestedByUserId = 'user';
        param.externalReferenceId = setupExternalId;
        
        inputParams.add(param);
        
        try {
            Test.startTest();
            CBPerformCustomerBatchable.forceTestingException = true;
            CBCustomerInvocable.bookCustomer(inputParams);
            Test.stopTest();
            
            system.assertEquals(true,true);
        } catch(Exception ex) {
            system.assertEquals(true,false);
        }
        
    }
    
    @IsTest
    private static void test_performdepositinvocablesilentlyfails(){
        
        setupData();
        
        new CBActivator().onActivate();
        
        List<CBEntities.CBDepositCalloutInputParams> inputParams = new List<CBEntities.CBDepositCalloutInputParams>();
        CBEntities.CBDepositCalloutInputParams param = new CBEntities.CBDepositCalloutInputParams();
        
        param.depositId = setupDepositId;
        param.userSessionId = 'asdfasdfadsfasdf';
        param.requestedByUserId = 'user';
        param.externalReferenceId = setupExternalId;
        
        inputParams.add(param);
        
        try {
            Test.startTest();
            CBPerformDepositBatchable.forceTestingException = true;
            CBDepositInvocable.bookDeposit(inputParams);
            Test.stopTest();
            system.assertEquals(true,true);
        } catch(Exception ex) {
            system.assertEquals(true,false);
        }
        
    }
    
    
}