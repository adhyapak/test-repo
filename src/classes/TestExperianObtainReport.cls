@IsTest
public class TestExperianObtainReport {

    public static String setuploanId;
    public static String setuprelationshipId;
    public static String setuprelationshipIdBusiness;
    public static String setupcontactId;
    public static String setupExternalId;
    
    @isTest
    static void setupData(){
        
        nFORCE__System_Properties__c mw1 = new nFORCE__System_Properties__c(Name='middleware.username',nFORCE__Category_Name__c='Middleware Configuration',nFORCE__Is_Active__c=true);
        mw1.nFORCE__Key__c = 'middleware.username';
        mw1.nFORCE__Value__c = 'user1';
        insert mw1;
        
        nFORCE__System_Properties__c mw2 = new nFORCE__System_Properties__c(Name='middleware.endpoint',nFORCE__Category_Name__c='Middleware Configuration',nFORCE__Is_Active__c=true);
        mw2.nFORCE__Key__c = 'middleware.endpoint';
        mw2.nFORCE__Value__c = 'http://www.google.com';
        insert mw2;
        
        nFORCE__System_Properties__c mw3 = new nFORCE__System_Properties__c(Name='middleware.password',nFORCE__Category_Name__c='Middleware Configuration',nFORCE__Is_Active__c=true);
        mw3.nFORCE__Key__c = 'middleware.password';
        mw3.nFORCE__Value__c = 'pwd';
        insert mw3;
        
        
        //system properties should already exist
        nFORCE__System_Properties__c property1 = new nFORCE__System_Properties__c(Name='aaaa',nFORCE__Category_Name__c='FairIsaac_CreditConfiguration',nFORCE__Is_Active__c=true);
        property1.nFORCE__Key__c = 'Consumer Days Valid';
        property1.nFORCE__Value__c = '30';
        insert property1;
        
        nFORCE__System_Properties__c property2 = new nFORCE__System_Properties__c(Name='bbbb',nFORCE__Category_Name__c='FairIsaac_CreditConfiguration',nFORCE__Is_Active__c=true);
        property2.nFORCE__Key__c = 'Business Days Valid';
        property2.nFORCE__Value__c = '30';
        insert property2;
        
        nFORCE__System_Properties__c property3 = new nFORCE__System_Properties__c(Name='cccc',nFORCE__Category_Name__c='FairIsaac_CreditConfiguration',nFORCE__Is_Active__c=true);
        property3.nFORCE__Key__c = 'FICO.Individual_Types';
        property3.nFORCE__Value__c = 'Individual';
        insert property3;
        
        // nFORCE__System_Properties__c property3 = new nFORCE__System_Properties__c(Name='cccc',nFORCE__Category_Name__c='FairIsaac_CreditConfiguration',nFORCE__Is_Active__c=true);
        // property3.nFORCE__Key__c = 'Business Credit Bureau Is Canadian (use true or false only)';
        // property3.nFORCE__Value__c = 'false';
        // insert property3;
        
        // nFORCE__System_Properties__c property4 = new nFORCE__System_Properties__c(Name='dddd',nFORCE__Category_Name__c='FairIsaac_CreditConfiguration',nFORCE__Is_Active__c=true);
        // property4.nFORCE__Key__c = 'Primary Consumer Credit Is Canadian (use true or false only)';
        // property4.nFORCE__Value__c = 'false';
        // insert property4;
        
        // nFORCE__System_Properties__c property5 = new nFORCE__System_Properties__c(Name='eeee',nFORCE__Category_Name__c='FairIsaac_CreditConfiguration',nFORCE__Is_Active__c=true);
        // property5.nFORCE__Key__c = 'Secondary Consumer Credit Is Canadian (use true or false only)';
        // property5.nFORCE__Value__c = 'false';
        // insert property5;
        
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
        log.nFUSE__App_Plugin__c = 'Experian_Credit';
        log.nFUSE__Primary_Object_Id__c = setuprelationshipIdBusiness;
        log.nFUSE__Requested_By_User_Id__c = 'user';
        log.nFUSE__Transaction_Status__c = 'new';
        log.nFUSE__External_Id__c = 'test';
        insert log;
        setupExternalId = log.nFUSE__External_Id__c;
        
        
    }
    
    @IsTest
    private static void test_obtainreport(){
        
        setupData();
        
        new ExperianCreditActivator().onActivate();
        
        List<ExperianCalloutBase.ExperianCalloutInputParams> inputParams = new List<ExperianCalloutBase.ExperianCalloutInputParams>();
        ExperianCalloutBase.ExperianCalloutInputParams param = new ExperianCalloutBase.ExperianCalloutInputParams();
        
        param.relationshipId = setuprelationshipIdBusiness;
        param.userSessionId = 'asdfasdfadsfasdf';
        param.requestedByUserId = 'user';
        param.externalReferenceId = setupExternalId;
        
        inputParams.add(param);
        
        try {
            Test.startTest();
            ExperianObtainReport.obtainReport(inputParams);
            Test.stopTest();
            system.assertEquals(true,true);
        } catch(Exception ex) {
            system.assertEquals(true,false);
        }
        
    }
    
    @IsTest
    private static void test_obtainreportFailsWithinTry(){
        
        setupData();
        
        new ExperianCreditActivator().onActivate();
        
        List<ExperianCalloutBase.ExperianCalloutInputParams> inputParams = new List<ExperianCalloutBase.ExperianCalloutInputParams>();
        ExperianCalloutBase.ExperianCalloutInputParams param = new ExperianCalloutBase.ExperianCalloutInputParams();
        
        param.relationshipId = 'anything';
        param.userSessionId = 'asdfasdfadsfasdf';
        param.requestedByUserId = 'user';
        param.externalReferenceId = setupExternalId;
        
        inputParams.add(param);
        
        Test.startTest();
        ExperianPerformObtainReport.forceException = true;
        ExperianObtainReport.obtainReport(inputParams);
        Test.stopTest();
        
        nFUSE__Transaction_Log__c[] errorLogs = [select Id, Name, nFUSE__Transaction_Status__c from nFUSE__Transaction_Log__c];
        
        system.assertEquals(true,errorLogs.size()==2); //includes the error one and the one from setup method
        
    }
    
    
}