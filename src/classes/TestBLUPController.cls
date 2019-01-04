@isTest
public with sharing class TestBLUPController {
    public static Account account {get;set;}
    static void setupData() {

        account = new Account(Name='Cycle Smith LLC');
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
        account.BillingPostalCode = '84102';
        account.LLC_BI__Duns_Number__c = '123456';
        account.Sic = '1473';
        account.Phone = '8185551212';
        account.LLC_BI__Phone_Number_Type__c = 'Work';
        account.LLC_BI__Tax_Identification_Number__c = '555555555';
        account.LLC_BI__Tax_Identification_Number_PE__c = '555555555';
        if(TestBLUPTMDataGenerator.orgHasTerritoryManagement)
            account = (Account)TestBLUPTMDataGenerator.updateForTerritoryManagement(account);
        insert account;

    }

    private static testMethod void testControllerPermissions(){

        test.startTest();
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];

        User u = new User(Alias = 'standt', Email='blup@testorg.com',
                EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                LocaleSidKey='en_US', ProfileId = p.Id,
                TimeZoneSidKey='America/Los_Angeles',     UserName='blup@blup.com');
        insert u;

        String permName = PERMISSION_NAME;
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name =:PERMISSION_NAME];

        // Assign the above inserted user for the above Permission Set.
        PermissionSetAssignment psa = new PermissionSetAssignment();
        psa.AssigneeId = u.Id;
        psa.PermissionSetId = ps.Id;
        insert psa;
        system.runAs(u){
            setupData();
            BLUPController controller = new BLUPController();

            system.assertEquals(controller.hasPermission, true);
        }
        test.stopTest();
    }


    private static testMethod void testCheckRestrictionsError(){
        setupData();

        nFUSE__Transaction_Log__c log = new nFUSE__Transaction_Log__c(Name='TestLog',nFUSE__External_Id__c='test');
        log.nFUSE__Action__c = 'new';
        log.nFUSE__Api_Version__c = '1';
        log.nFUSE__App_Plugin__c = 'FairIsaac_Credit';
        log.nFUSE__Primary_Object_Id__c = account.id;
        log.nFUSE__Requested_By_User_Id__c = 'user';
        log.nFUSE__Transaction_Status__c = 'new';
        log.nFUSE__External_Id__c = 'test';
        insert log;

        Attachment att = new Attachment();
        att.name = 'test';
        att.Body = Blob.valueOf('{"listOfSimilars":[{"sequenceNumber":"00","product":"Intelliscore","bureauData":[{"value":"132","key":"NumberOfTradeLines"},{"value":"19780700","key":"FileEstablishDate"},{"value":"","key":"FileEstablishFlag"},{"value":" ","key":"FileEstablishFlag.code"},{"value":"N","key":"SAndPIndicator"},{"value":"Y","key":"KeyFactsIndicator"},{"value":"N","key":"InquiryIndicator"},{"value":"Y","key":"PublicRecordDataIndicator"},{"value":"Y","key":"BankDataIndicator"},{"value":"N","key":"GovernmentDataIndicator"},{"value":"Y","key":"CollectionIndicator"},{"value":"Y","key":"ExecutiveSummaryIndicator"},{"value":"N","key":"IndustryPremierIndicator"},{"value":"Y","key":"UCCIndicator"}],"bin":"700393131","companyInfo":{"zip":"080141000","address":"1 FLOODGATE RD","phone":"","city":"BRIDGEPORT","name":"GODWIN PUMPS OF AMERICA, INC","state":"NJ"},"transactionNumber":"","confidence":"09900","bureau":"XPB"},{"sequenceNumber":"00","product":"Intelliscore","bureauData":[{"value":"000","key":"NumberOfTradeLines"},{"value":"19780700","key":"FileEstablishDate"},{"value":"","key":"FileEstablishFlag"},{"value":" ","key":"FileEstablishFlag.code"},{"value":"N","key":"SAndPIndicator"},{"value":"Y","key":"KeyFactsIndicator"},{"value":"Y","key":"InquiryIndicator"},{"value":"Y","key":"PublicRecordDataIndicator"},{"value":"N","key":"BankDataIndicator"},{"value":"N","key":"GovernmentDataIndicator"},{"value":"Y","key":"CollectionIndicator"},{"value":"Y","key":"ExecutiveSummaryIndicator"},{"value":"N","key":"IndustryPremierIndicator"},{"value":"Y","key":"UCCIndicator"}],"bin":"000000000","companyInfo":{"zip":"08014","address":"84 BRIDGEPORT FLOODGATE RD","phone":"8564673636","city":"BRIDGEPORT","name":"XYLEM DEWATERING SOLUTIONS, INC","state":"NJ"},"transactionNumber":"","confidence":"09900","bureau":"XPB"}]}');
        att.ParentId = log.Id;
        insert att;
        account.BillingCity = 'testestestestestestestestestes';
        update account;

        test.startTest();
        BLUPController.BLUPResponse response = new BLUPController.BLUPResponse();
        response = BLUPController.getProductRows(account.Id);

        test.stopTest();
    }

    private static testMethod void testCheckRestrictionsPostalError(){
        setupData();

        nFUSE__Transaction_Log__c log = new nFUSE__Transaction_Log__c(Name='TestLog',nFUSE__External_Id__c='test');
        log.nFUSE__Action__c = 'new';
        log.nFUSE__Api_Version__c = '1';
        log.nFUSE__App_Plugin__c = 'FairIsaac_Credit';
        log.nFUSE__Primary_Object_Id__c = account.id;
        log.nFUSE__Requested_By_User_Id__c = 'user';
        log.nFUSE__Transaction_Status__c = 'new';
        log.nFUSE__External_Id__c = 'test';
        insert log;

        Attachment att = new Attachment();
        att.name = 'test';
        att.Body = Blob.valueOf('{"listOfSimilars":[{"sequenceNumber":"00","product":"Intelliscore","bureauData":[{"value":"132","key":"NumberOfTradeLines"},{"value":"19780700","key":"FileEstablishDate"},{"value":"","key":"FileEstablishFlag"},{"value":" ","key":"FileEstablishFlag.code"},{"value":"N","key":"SAndPIndicator"},{"value":"Y","key":"KeyFactsIndicator"},{"value":"N","key":"InquiryIndicator"},{"value":"Y","key":"PublicRecordDataIndicator"},{"value":"Y","key":"BankDataIndicator"},{"value":"N","key":"GovernmentDataIndicator"},{"value":"Y","key":"CollectionIndicator"},{"value":"Y","key":"ExecutiveSummaryIndicator"},{"value":"N","key":"IndustryPremierIndicator"},{"value":"Y","key":"UCCIndicator"}],"bin":"700393131","companyInfo":{"zip":"080141000","address":"1 FLOODGATE RD","phone":"","city":"BRIDGEPORT","name":"GODWIN PUMPS OF AMERICA, INC","state":"NJ"},"transactionNumber":"","confidence":"09900","bureau":"XPB"},{"sequenceNumber":"00","product":"Intelliscore","bureauData":[{"value":"000","key":"NumberOfTradeLines"},{"value":"19780700","key":"FileEstablishDate"},{"value":"","key":"FileEstablishFlag"},{"value":" ","key":"FileEstablishFlag.code"},{"value":"N","key":"SAndPIndicator"},{"value":"Y","key":"KeyFactsIndicator"},{"value":"Y","key":"InquiryIndicator"},{"value":"Y","key":"PublicRecordDataIndicator"},{"value":"N","key":"BankDataIndicator"},{"value":"N","key":"GovernmentDataIndicator"},{"value":"Y","key":"CollectionIndicator"},{"value":"Y","key":"ExecutiveSummaryIndicator"},{"value":"N","key":"IndustryPremierIndicator"},{"value":"Y","key":"UCCIndicator"}],"bin":"000000000","companyInfo":{"zip":"08014","address":"84 BRIDGEPORT FLOODGATE RD","phone":"8564673636","city":"BRIDGEPORT","name":"XYLEM DEWATERING SOLUTIONS, INC","state":"NJ"},"transactionNumber":"","confidence":"09900","bureau":"XPB"}]}');
        att.ParentId = log.Id;
        insert att;
        account.BillingPostalCode = '123';
        update account;

        test.startTest();
        BLUPController.BLUPResponse response = new BLUPController.BLUPResponse();
        response = BLUPController.getProductRows(account.Id);

        test.stopTest();
    }

    private static testMethod void testGetPropertyException(){

        test.startTest();

        nFORCE.SystemProperties configProperties = nFORCE.SystemProperties.getInstance();
        try{
            BLUPController.getProperty(configProperties, BUREAU_NAME, BLUPController.FICO_CREDIT+BLUPController.NFUSE_CONFIGURATION_KEYWORD);
        }
        catch(Exception e){
            system.assertEquals(true, true);
        }

        test.stopTest();
    }

    private static testMethod void testMissingRequiredFieldsError(){
        setupData();

        nFUSE__Transaction_Log__c log = new nFUSE__Transaction_Log__c(Name='TestLog',nFUSE__External_Id__c='test');
        log.nFUSE__Action__c = 'new';
        log.nFUSE__Api_Version__c = '1';
        log.nFUSE__App_Plugin__c = 'FairIsaac_Credit';
        log.nFUSE__Primary_Object_Id__c = account.id;
        log.nFUSE__Requested_By_User_Id__c = 'user';
        log.nFUSE__Transaction_Status__c = 'new';
        log.nFUSE__External_Id__c = 'test';
        insert log;

        Attachment att = new Attachment();
        att.name = 'test';
        att.Body = Blob.valueOf('{"listOfSimilars":[{"sequenceNumber":"00","product":"Intelliscore","bureauData":[{"value":"132","key":"NumberOfTradeLines"},{"value":"19780700","key":"FileEstablishDate"},{"value":"","key":"FileEstablishFlag"},{"value":" ","key":"FileEstablishFlag.code"},{"value":"N","key":"SAndPIndicator"},{"value":"Y","key":"KeyFactsIndicator"},{"value":"N","key":"InquiryIndicator"},{"value":"Y","key":"PublicRecordDataIndicator"},{"value":"Y","key":"BankDataIndicator"},{"value":"N","key":"GovernmentDataIndicator"},{"value":"Y","key":"CollectionIndicator"},{"value":"Y","key":"ExecutiveSummaryIndicator"},{"value":"N","key":"IndustryPremierIndicator"},{"value":"Y","key":"UCCIndicator"}],"bin":"700393131","companyInfo":{"zip":"080141000","address":"1 FLOODGATE RD","phone":"","city":"BRIDGEPORT","name":"GODWIN PUMPS OF AMERICA, INC","state":"NJ"},"transactionNumber":"","confidence":"09900","bureau":"XPB"},{"sequenceNumber":"00","product":"Intelliscore","bureauData":[{"value":"000","key":"NumberOfTradeLines"},{"value":"19780700","key":"FileEstablishDate"},{"value":"","key":"FileEstablishFlag"},{"value":" ","key":"FileEstablishFlag.code"},{"value":"N","key":"SAndPIndicator"},{"value":"Y","key":"KeyFactsIndicator"},{"value":"Y","key":"InquiryIndicator"},{"value":"Y","key":"PublicRecordDataIndicator"},{"value":"N","key":"BankDataIndicator"},{"value":"N","key":"GovernmentDataIndicator"},{"value":"Y","key":"CollectionIndicator"},{"value":"Y","key":"ExecutiveSummaryIndicator"},{"value":"N","key":"IndustryPremierIndicator"},{"value":"Y","key":"UCCIndicator"}],"bin":"000000000","companyInfo":{"zip":"08014","address":"84 BRIDGEPORT FLOODGATE RD","phone":"8564673636","city":"BRIDGEPORT","name":"XYLEM DEWATERING SOLUTIONS, INC","state":"NJ"},"transactionNumber":"","confidence":"09900","bureau":"XPB"}]}');
        att.ParentId = log.Id;
        insert att;
        account.BillingCity = '';
        update account;

        test.startTest();
        BLUPController.BLUPResponse response = new BLUPController.BLUPResponse();
        response = BLUPController.getProductRows(account.Id);
        response = BLUPController.executeBlupRequest(account.Id, FICODNB);

        test.stopTest();
    }
    private static testMethod void testNoRecordsInfaError(){
        setupData();

        nFUSE__Transaction_Log__c log = new nFUSE__Transaction_Log__c(Name='TestLog',nFUSE__External_Id__c='test');
        log.nFUSE__Action__c = 'new';
        log.nFUSE__Api_Version__c = '1';
        log.nFUSE__App_Plugin__c = 'FairIsaac_Credit';
        log.nFUSE__Primary_Object_Id__c = account.id;
        log.nFUSE__Requested_By_User_Id__c = 'user';
        log.nFUSE__Transaction_Status__c = 'new';
        log.nFUSE__External_Id__c = 'test';
        insert log;

        Attachment att = new Attachment();
        att.name = 'test';
        att.Body = Blob.valueOf('{"listOfSimilars":[{"listOfSimilarsError":"No records found"}]}');
        att.ParentId = log.Id;
        insert att;


        test.startTest();
        BLUPController.BLUPResponse response = new BLUPController.BLUPResponse();
        response = BLUPController.getProductRows(account.Id);
        response = BLUPController.executeBlupRequest(account.Id, FICODNB);
        BLUPController.BLUPViewModel viewModel = BLUPController.getBLUPViewModel(log.Id, account.id, FICODNB);


        test.stopTest();
    }
    private static testMethod void testOtherInfaError(){
        setupData();

        nFUSE__Transaction_Log__c log = new nFUSE__Transaction_Log__c(Name='TestLog',nFUSE__External_Id__c='test');
        log.nFUSE__Action__c = 'new';
        log.nFUSE__Api_Version__c = '1';
        log.nFUSE__App_Plugin__c = 'FairIsaac_Credit';
        log.nFUSE__Primary_Object_Id__c = account.id;
        log.nFUSE__Requested_By_User_Id__c = 'user';
        log.nFUSE__Transaction_Status__c = 'new';
        log.nFUSE__External_Id__c = 'test';
        insert log;

        Attachment att = new Attachment();
        att.name = 'test';
        att.Body = Blob.valueOf('{"listOfSimilars":[{"listOfSimilarsError":"someErrorOccurred"}]}');
        att.ParentId = log.Id;
        insert att;


        test.startTest();
        BLUPController.BLUPResponse response = new BLUPController.BLUPResponse();
        response = BLUPController.getProductRows(account.Id);
        response = BLUPController.executeBlupRequest(account.Id, FICODNB);
        BLUPController.BLUPViewModel viewModel = BLUPController.getBLUPViewModel(log.Id, account.id, FICODNB);


        test.stopTest();
    }
    private static testMethod void testNoServiceError(){
        nFORCE__System_Properties__c property2 = new nFORCE__System_Properties__c(Name='bbbbb',nFORCE__Category_Name__c='FairIsaac_CreditConfiguration',nFORCE__Is_Active__c=true);
        property2.nFORCE__Key__c = BUREAU_NAME;
        property2.nFORCE__Value__c = DNB_CONFIG;
        insert property2;
        setupData();

        nFUSE__Transaction_Log__c log = new nFUSE__Transaction_Log__c(Name='TestLog',nFUSE__External_Id__c='test');
        log.nFUSE__Action__c = 'new';
        log.nFUSE__Api_Version__c = '1';
        log.nFUSE__App_Plugin__c = 'FairIsaac_Credit';
        log.nFUSE__Primary_Object_Id__c = account.id;
        log.nFUSE__Requested_By_User_Id__c = 'user';
        log.nFUSE__Transaction_Status__c = 'new';
        log.nFUSE__External_Id__c = 'test';
        insert log;

        Attachment att = new Attachment();
        att.name = 'test';
        att.Body = Blob.valueOf('{"listOfSimilars":[{"sequenceNumber":"00","product":"Intelliscore","bureauData":[{"value":"132","key":"NumberOfTradeLines"},{"value":"19780700","key":"FileEstablishDate"},{"value":"","key":"FileEstablishFlag"},{"value":" ","key":"FileEstablishFlag.code"},{"value":"N","key":"SAndPIndicator"},{"value":"Y","key":"KeyFactsIndicator"},{"value":"N","key":"InquiryIndicator"},{"value":"Y","key":"PublicRecordDataIndicator"},{"value":"Y","key":"BankDataIndicator"},{"value":"N","key":"GovernmentDataIndicator"},{"value":"Y","key":"CollectionIndicator"},{"value":"Y","key":"ExecutiveSummaryIndicator"},{"value":"N","key":"IndustryPremierIndicator"},{"value":"Y","key":"UCCIndicator"}],"bin":"700393131","companyInfo":{"zip":"080141000","address":"1 FLOODGATE RD","phone":"","city":"BRIDGEPORT","name":"GODWIN PUMPS OF AMERICA, INC","state":"NJ"},"transactionNumber":"","confidence":"09900","bureau":"XPB"},{"sequenceNumber":"00","product":"Intelliscore","bureauData":[{"value":"000","key":"NumberOfTradeLines"},{"value":"19780700","key":"FileEstablishDate"},{"value":"","key":"FileEstablishFlag"},{"value":" ","key":"FileEstablishFlag.code"},{"value":"N","key":"SAndPIndicator"},{"value":"Y","key":"KeyFactsIndicator"},{"value":"Y","key":"InquiryIndicator"},{"value":"Y","key":"PublicRecordDataIndicator"},{"value":"N","key":"BankDataIndicator"},{"value":"N","key":"GovernmentDataIndicator"},{"value":"Y","key":"CollectionIndicator"},{"value":"Y","key":"ExecutiveSummaryIndicator"},{"value":"N","key":"IndustryPremierIndicator"},{"value":"Y","key":"UCCIndicator"}],"bin":"000000000","companyInfo":{"zip":"08014","address":"84 BRIDGEPORT FLOODGATE RD","phone":"8564673636","city":"BRIDGEPORT","name":"XYLEM DEWATERING SOLUTIONS, INC","state":"NJ"},"transactionNumber":"","confidence":"09900","bureau":"XPB"}]}');
        att.ParentId = log.Id;
        insert att;


        test.startTest();
        try{
            //try fico first then try experian after
            nFUSE.IPluginActivator dyanmicActivator = (nFUSE.IPluginActivator)Type.forName(SBSSNamespace + 'FairIsaacCreditActivator').newInstance();
            dyanmicActivator.onActivate();
        }
        catch(Exception e){
            try{
                nFUSE.IPluginActivator dyanmicActivator = (nFUSE.IPluginActivator)Type.forName('ExperianCreditActivator').newInstance();
                dyanmicActivator.onActivate();
            }
            catch(Exception ex){
                //this block should only happen if there are NO FICO OR EXPERIAN plugins present
            }

        }
        BLUPController.BLUPPluginInfo info = new BLUPController.BLUPPluginInfo();
        try{
            BLUPController.executeBlupRequest(account.Id, FICOEXPERIAN);
        }
        catch(Exception e){
            system.assertEquals(true, true);
        }
        test.stopTest();
    }
    private static testMethod void testEmptyAttachmentError(){
        setupData();

        nFUSE__Transaction_Log__c log = new nFUSE__Transaction_Log__c(Name='TestLog',nFUSE__External_Id__c='test');
        log.nFUSE__Action__c = 'new';
        log.nFUSE__Api_Version__c = '1';
        log.nFUSE__App_Plugin__c = 'FairIsaac_Credit';
        log.nFUSE__Primary_Object_Id__c = account.id;
        log.nFUSE__Requested_By_User_Id__c = 'user';
        log.nFUSE__Transaction_Status__c = 'new';
        log.nFUSE__External_Id__c = 'test';
        insert log;

        Attachment att = new Attachment();
        att.name = 'test';
        att.Body = Blob.valueOf('');
        att.ParentId = log.Id;
        insert att;


        test.startTest();
        BLUPController.BLUPResponse response = new BLUPController.BLUPResponse();
        response = BLUPController.getProductRows(account.Id);
        response = BLUPController.executeBlupRequest(account.Id, FICODNB);
        BLUPController.BLUPViewModel viewModel = BLUPController.getBLUPViewModel(log.Id, account.id, FICODNB);


        test.stopTest();
    }
    private static testMethod void testNoAttachmentFoundError(){
        setupData();

        nFUSE__Transaction_Log__c log = new nFUSE__Transaction_Log__c(Name='TestLog',nFUSE__External_Id__c='test');
        log.nFUSE__Action__c = 'new';
        log.nFUSE__Api_Version__c = '1';
        log.nFUSE__App_Plugin__c = 'FairIsaac_Credit';
        log.nFUSE__Primary_Object_Id__c = account.id;
        log.nFUSE__Requested_By_User_Id__c = 'user';
        log.nFUSE__Transaction_Status__c = 'new';
        log.nFUSE__External_Id__c = 'test';
        insert log;

        test.startTest();
        BLUPController.BLUPResponse response = new BLUPController.BLUPResponse();
        response = BLUPController.getProductRows(account.Id);
        response = BLUPController.executeBlupRequest(account.Id, FICODNB);
        BLUPController.BLUPViewModel viewModel = BLUPController.getBLUPViewModel(log.Id, account.id, FICODNB);


        test.stopTest();
    }
    private static testMethod void testGetAttachmentsNoLimit(){
        nFORCE__System_Properties__c property1 = new nFORCE__System_Properties__c(Name='AAAA',nFORCE__Category_Name__c='FairIsaac_CreditConfiguration',nFORCE__Is_Active__c=true);
        property1.nFORCE__Key__c = BUREAU_NAME;
        property1.nFORCE__Value__c = EXPERIAN_CONFIG;
        insert property1;
        setupData();

        nFUSE__Transaction_Log__c log = new nFUSE__Transaction_Log__c(Name='TestLog',nFUSE__External_Id__c='test');
        log.nFUSE__Action__c = 'new';
        log.nFUSE__Api_Version__c = '1';
        log.nFUSE__App_Plugin__c = 'FairIsaac_Credit';
        log.nFUSE__Primary_Object_Id__c = account.id;
        log.nFUSE__Requested_By_User_Id__c = 'user';
        log.nFUSE__Transaction_Status__c = 'new';
        log.nFUSE__External_Id__c = 'test';
        insert log;

        Attachment att = new Attachment();
        att.name = 'test';
        att.Body = Blob.valueOf('{"listOfSimilars":[{"sequenceNumber":"00","product":"Intelliscore","bureauData":[{"value":"132","key":"NumberOfTradeLines"},{"value":"19780700","key":"FileEstablishDate"},{"value":"","key":"FileEstablishFlag"},{"value":" ","key":"FileEstablishFlag.code"},{"value":"N","key":"SAndPIndicator"},{"value":"Y","key":"KeyFactsIndicator"},{"value":"N","key":"InquiryIndicator"},{"value":"Y","key":"PublicRecordDataIndicator"},{"value":"Y","key":"BankDataIndicator"},{"value":"N","key":"GovernmentDataIndicator"},{"value":"Y","key":"CollectionIndicator"},{"value":"Y","key":"ExecutiveSummaryIndicator"},{"value":"N","key":"IndustryPremierIndicator"},{"value":"Y","key":"UCCIndicator"}],"bin":"700393131","companyInfo":{"zip":"080141000","address":"1 FLOODGATE RD","phone":"","city":"BRIDGEPORT","name":"GODWIN PUMPS OF AMERICA, INC","state":"NJ"},"transactionNumber":"","confidence":"09900","bureau":"XPB"},{"sequenceNumber":"00","product":"Intelliscore","bureauData":[{"value":"000","key":"NumberOfTradeLines"},{"value":"19780700","key":"FileEstablishDate"},{"value":"","key":"FileEstablishFlag"},{"value":" ","key":"FileEstablishFlag.code"},{"value":"N","key":"SAndPIndicator"},{"value":"Y","key":"KeyFactsIndicator"},{"value":"Y","key":"InquiryIndicator"},{"value":"Y","key":"PublicRecordDataIndicator"},{"value":"N","key":"BankDataIndicator"},{"value":"N","key":"GovernmentDataIndicator"},{"value":"Y","key":"CollectionIndicator"},{"value":"Y","key":"ExecutiveSummaryIndicator"},{"value":"N","key":"IndustryPremierIndicator"},{"value":"Y","key":"UCCIndicator"}],"bin":"000000000","companyInfo":{"zip":"08014","address":"84 BRIDGEPORT FLOODGATE RD","phone":"8564673636","city":"BRIDGEPORT","name":"XYLEM DEWATERING SOLUTIONS, INC","state":"NJ"},"transactionNumber":"","confidence":"09900","bureau":"XPB"}]}');
        att.ParentId = log.Id;
        insert att;

        test.startTest();
        BLUPController.BLUPRepository repo =  new BLUPController.BLUPRepository();
        repo.getAttachments(log.id, '');

        test.stopTest();
    }
    private static testMethod void testEXPERIAN(){
        nFORCE__System_Properties__c property1 = new nFORCE__System_Properties__c(Name='AAAA',nFORCE__Category_Name__c='FairIsaac_CreditConfiguration',nFORCE__Is_Active__c=true);
        property1.nFORCE__Key__c = BUREAU_NAME;
        property1.nFORCE__Value__c = EXPERIAN_CONFIG;
        insert property1;
        setupData();

        nFUSE__Transaction_Log__c log = new nFUSE__Transaction_Log__c(Name='TestLog',nFUSE__External_Id__c='test');
        log.nFUSE__Action__c = 'new';
        log.nFUSE__Api_Version__c = '1';
        log.nFUSE__App_Plugin__c = 'FairIsaac_Credit';
        log.nFUSE__Primary_Object_Id__c = account.id;
        log.nFUSE__Requested_By_User_Id__c = 'user';
        log.nFUSE__Transaction_Status__c = 'new';
        log.nFUSE__External_Id__c = 'test';
        insert log;

        Attachment att = new Attachment();
        att.name = 'test';
        att.Body = Blob.valueOf('{"listOfSimilars":[{"sequenceNumber":"00","product":"Intelliscore","bureauData":[{"value":"132","key":"NumberOfTradeLines"},{"value":"19780700","key":"FileEstablishDate"},{"value":"","key":"FileEstablishFlag"},{"value":" ","key":"FileEstablishFlag.code"},{"value":"N","key":"SAndPIndicator"},{"value":"Y","key":"KeyFactsIndicator"},{"value":"N","key":"InquiryIndicator"},{"value":"Y","key":"PublicRecordDataIndicator"},{"value":"Y","key":"BankDataIndicator"},{"value":"N","key":"GovernmentDataIndicator"},{"value":"Y","key":"CollectionIndicator"},{"value":"Y","key":"ExecutiveSummaryIndicator"},{"value":"N","key":"IndustryPremierIndicator"},{"value":"Y","key":"UCCIndicator"}],"bin":"700393131","companyInfo":{"zip":"080141000","address":"1 FLOODGATE RD","phone":"","city":"BRIDGEPORT","name":"GODWIN PUMPS OF AMERICA, INC","state":"NJ"},"transactionNumber":"","confidence":"09900","bureau":"XPB"},{"sequenceNumber":"00","product":"Intelliscore","bureauData":[{"value":"000","key":"NumberOfTradeLines"},{"value":"19780700","key":"FileEstablishDate"},{"value":"","key":"FileEstablishFlag"},{"value":" ","key":"FileEstablishFlag.code"},{"value":"N","key":"SAndPIndicator"},{"value":"Y","key":"KeyFactsIndicator"},{"value":"Y","key":"InquiryIndicator"},{"value":"Y","key":"PublicRecordDataIndicator"},{"value":"N","key":"BankDataIndicator"},{"value":"N","key":"GovernmentDataIndicator"},{"value":"Y","key":"CollectionIndicator"},{"value":"Y","key":"ExecutiveSummaryIndicator"},{"value":"N","key":"IndustryPremierIndicator"},{"value":"Y","key":"UCCIndicator"}],"bin":"000000000","companyInfo":{"zip":"08014","address":"84 BRIDGEPORT FLOODGATE RD","phone":"8564673636","city":"BRIDGEPORT","name":"XYLEM DEWATERING SOLUTIONS, INC","state":"NJ"},"transactionNumber":"","confidence":"09900","bureau":"XPB"}]}');
        att.ParentId = log.Id;
        insert att;

        test.startTest();
        try{
            //try fico first then try experian after
            nFUSE.IPluginActivator dyanmicActivator = (nFUSE.IPluginActivator)Type.forName(SBSSNamespace + 'FairIsaacCreditActivator').newInstance();
            dyanmicActivator.onActivate();
        }
        catch(Exception e){
            try{
                nFUSE.IPluginActivator dyanmicActivator = (nFUSE.IPluginActivator)Type.forName('ExperianCreditActivator').newInstance();
                dyanmicActivator.onActivate();
            }
            catch(Exception ex){
                //this block should only happen if there are NO FICO OR EXPERIAN plugins present
            }

        }
        BLUPController.BLUPResponse response = new BLUPController.BLUPResponse();
        response = BLUPController.getProductRows(account.Id);
        response = BLUPController.executeBlupRequest(account.Id, FICOEXPERIAN);
        BLUPController.BLUPViewModel viewModel = BLUPController.getBLUPViewModel(log.Id, account.id, FICOEXPERIAN);
        response = BLUPController.updateAccount(account.id, '1234', FICOEXPERIAN);

        test.stopTest();
    }
    private static testMethod void testDNB(){
        nFORCE__System_Properties__c property2 = new nFORCE__System_Properties__c(Name='bbbbb',nFORCE__Category_Name__c='FairIsaac_CreditConfiguration',nFORCE__Is_Active__c=true);
        property2.nFORCE__Key__c = BUREAU_NAME;
        property2.nFORCE__Value__c = DNB_CONFIG;
        insert property2;
        setupData();

        nFUSE__Transaction_Log__c log = new nFUSE__Transaction_Log__c(Name='TestLog',nFUSE__External_Id__c='test');
        log.nFUSE__Action__c = 'new';
        log.nFUSE__Api_Version__c = '1';
        log.nFUSE__App_Plugin__c = 'FairIsaac_Credit';
        log.nFUSE__Primary_Object_Id__c = account.id;
        log.nFUSE__Requested_By_User_Id__c = 'user';
        log.nFUSE__Transaction_Status__c = 'new';
        log.nFUSE__External_Id__c = 'test';
        insert log;

        Attachment att = new Attachment();
        att.name = 'test';
        att.Body = Blob.valueOf('{"listOfSimilars":[{"sequenceNumber":"00","product":"Intelliscore","bureauData":[{"value":"132","key":"NumberOfTradeLines"},{"value":"19780700","key":"FileEstablishDate"},{"value":"","key":"FileEstablishFlag"},{"value":" ","key":"FileEstablishFlag.code"},{"value":"N","key":"SAndPIndicator"},{"value":"Y","key":"KeyFactsIndicator"},{"value":"N","key":"InquiryIndicator"},{"value":"Y","key":"PublicRecordDataIndicator"},{"value":"Y","key":"BankDataIndicator"},{"value":"N","key":"GovernmentDataIndicator"},{"value":"Y","key":"CollectionIndicator"},{"value":"Y","key":"ExecutiveSummaryIndicator"},{"value":"N","key":"IndustryPremierIndicator"},{"value":"Y","key":"UCCIndicator"}],"bin":"700393131","companyInfo":{"zip":"080141000","address":"1 FLOODGATE RD","phone":"","city":"BRIDGEPORT","name":"GODWIN PUMPS OF AMERICA, INC","state":"NJ"},"transactionNumber":"","confidence":"10000","bureau":"XPB"},{"sequenceNumber":"00","product":"Intelliscore","bureauData":[{"value":"000","key":"NumberOfTradeLines"},{"value":"19780700","key":"FileEstablishDate"},{"value":"","key":"FileEstablishFlag"},{"value":" ","key":"FileEstablishFlag.code"},{"value":"N","key":"SAndPIndicator"},{"value":"Y","key":"KeyFactsIndicator"},{"value":"Y","key":"InquiryIndicator"},{"value":"Y","key":"PublicRecordDataIndicator"},{"value":"N","key":"BankDataIndicator"},{"value":"N","key":"GovernmentDataIndicator"},{"value":"Y","key":"CollectionIndicator"},{"value":"Y","key":"ExecutiveSummaryIndicator"},{"value":"N","key":"IndustryPremierIndicator"},{"value":"Y","key":"UCCIndicator"}],"bin":"000000000","companyInfo":{"zip":"08014","address":"84 BRIDGEPORT FLOODGATE RD","phone":"8564673636","city":"BRIDGEPORT","name":"XYLEM DEWATERING SOLUTIONS, INC","state":"NJ"},"transactionNumber":"","confidence":"09900","bureau":"XPB"}, {"sequenceNumber":"00","product":"Intelliscore","bureauData":[{"value":"132","key":"NumberOfTradeLines"},{"value":"19780700","key":"FileEstablishDate"},{"value":"","key":"FileEstablishFlag"},{"value":" ","key":"FileEstablishFlag.code"},{"value":"N","key":"SAndPIndicator"},{"value":"Y","key":"KeyFactsIndicator"},{"value":"N","key":"InquiryIndicator"},{"value":"Y","key":"PublicRecordDataIndicator"},{"value":"Y","key":"BankDataIndicator"},{"value":"N","key":"GovernmentDataIndicator"},{"value":"Y","key":"CollectionIndicator"},{"value":"Y","key":"ExecutiveSummaryIndicator"},{"value":"N","key":"IndustryPremierIndicator"},{"value":"Y","key":"UCCIndicator"}],"bin":"700393131","companyInfo":{"zip":"080141000","address":"1 FLOODGATE RD","phone":"","city":"BRIDGEPORT","name":"GODWIN PUMPS OF AMERICA, INC","state":"NJ"},"transactionNumber":"","confidence":"09900","bureau":"XPB"},{"sequenceNumber":"00","product":"Intelliscore","bureauData":[{"value":"000","key":"NumberOfTradeLines"},{"value":"19780700","key":"FileEstablishDate"},{"value":"","key":"FileEstablishFlag"},{"value":" ","key":"FileEstablishFlag.code"},{"value":"N","key":"SAndPIndicator"},{"value":"Y","key":"KeyFactsIndicator"},{"value":"Y","key":"InquiryIndicator"},{"value":"Y","key":"PublicRecordDataIndicator"},{"value":"N","key":"BankDataIndicator"},{"value":"N","key":"GovernmentDataIndicator"},{"value":"Y","key":"CollectionIndicator"},{"value":"Y","key":"ExecutiveSummaryIndicator"},{"value":"N","key":"IndustryPremierIndicator"},{"value":"Y","key":"UCCIndicator"}],"bin":"000000000","companyInfo":{"zip":"08014","address":"84 BRIDGEPORT FLOODGATE RD","phone":"8564673636","city":"BRIDGEPORT","name":"XYLEM DEWATERING SOLUTIONS, INC","state":"NJ"},"transactionNumber":"","confidence":"09800","bureau":"XPB"}, {"sequenceNumber":"00","product":"Intelliscore","bureauData":[{"value":"132","key":"NumberOfTradeLines"},{"value":"19780700","key":"FileEstablishDate"},{"value":"","key":"FileEstablishFlag"},{"value":" ","key":"FileEstablishFlag.code"},{"value":"N","key":"SAndPIndicator"},{"value":"Y","key":"KeyFactsIndicator"},{"value":"N","key":"InquiryIndicator"},{"value":"Y","key":"PublicRecordDataIndicator"},{"value":"Y","key":"BankDataIndicator"},{"value":"N","key":"GovernmentDataIndicator"},{"value":"Y","key":"CollectionIndicator"},{"value":"Y","key":"ExecutiveSummaryIndicator"},{"value":"N","key":"IndustryPremierIndicator"},{"value":"Y","key":"UCCIndicator"}],"bin":"700393131","companyInfo":{"zip":"080141000","address":"1 FLOODGATE RD","phone":"","city":"BRIDGEPORT","name":"GODWIN PUMPS OF AMERICA, INC","state":"NJ"},"transactionNumber":"","confidence":"09900","bureau":"XPB"},{"sequenceNumber":"00","product":"Intelliscore","bureauData":[{"value":"000","key":"NumberOfTradeLines"},{"value":"19780700","key":"FileEstablishDate"},{"value":"","key":"FileEstablishFlag"},{"value":" ","key":"FileEstablishFlag.code"},{"value":"N","key":"SAndPIndicator"},{"value":"Y","key":"KeyFactsIndicator"},{"value":"Y","key":"InquiryIndicator"},{"value":"Y","key":"PublicRecordDataIndicator"},{"value":"N","key":"BankDataIndicator"},{"value":"N","key":"GovernmentDataIndicator"},{"value":"Y","key":"CollectionIndicator"},{"value":"Y","key":"ExecutiveSummaryIndicator"},{"value":"N","key":"IndustryPremierIndicator"},{"value":"Y","key":"UCCIndicator"}],"bin":"000000000","companyInfo":{"zip":"08014","address":"84 BRIDGEPORT FLOODGATE RD","phone":"8564673636","city":"BRIDGEPORT","name":"XYLEM DEWATERING SOLUTIONS, INC","state":"NJ"},"transactionNumber":"","confidence":"09900","bureau":"XPB"}]}');
        att.ParentId = log.Id;
        insert att;


        test.startTest();
        try{
            //try fico first then try experian after
            nFUSE.IPluginActivator dyanmicActivator = (nFUSE.IPluginActivator)Type.forName(SBSSNamespace + 'FairIsaacCreditActivator').newInstance();
            dyanmicActivator.onActivate();
        }
        catch(Exception e){
            try{
                nFUSE.IPluginActivator dyanmicActivator = (nFUSE.IPluginActivator)Type.forName('ExperianCreditActivator').newInstance();
                dyanmicActivator.onActivate();
            }
            catch(Exception ex){
                //this block should only happen if there are NO FICO OR EXPERIAN plugins present
            }

        }
        BLUPController.BLUPResponse response = new BLUPController.BLUPResponse();
        response = BLUPController.getProductRows(account.Id);
        response = BLUPController.executeBlupRequest(account.Id, FICODNB);
        BLUPController.BLUPViewModel viewModel = BLUPController.getBLUPViewModel(log.Id, account.id, FICODNB);
        response = BLUPController.updateAccount(account.id, '1234', FICODNB);


        test.stopTest();
    }
    private static testMethod void testCheckforServiceException(){
        nFORCE__System_Properties__c property2 = new nFORCE__System_Properties__c(Name='bbbbb',nFORCE__Category_Name__c='FairIsaac_CreditConfiguration',nFORCE__Is_Active__c=true);
        property2.nFORCE__Key__c = BUREAU_NAME;
        property2.nFORCE__Value__c = DNB_CONFIG;
        insert property2;
        setupData();

        nFUSE__Transaction_Log__c log = new nFUSE__Transaction_Log__c(Name='TestLog',nFUSE__External_Id__c='test');
        log.nFUSE__Action__c = 'new';
        log.nFUSE__Api_Version__c = '1';
        log.nFUSE__App_Plugin__c = 'FairIsaac_Credit';
        log.nFUSE__Primary_Object_Id__c = account.id;
        log.nFUSE__Requested_By_User_Id__c = 'user';
        log.nFUSE__Transaction_Status__c = 'new';
        log.nFUSE__External_Id__c = 'test';
        insert log;

        Attachment att = new Attachment();
        att.name = 'test';
        att.Body = Blob.valueOf('{"listOfSimilars":[{"sequenceNumber":"00","product":"Intelliscore","bureauData":[{"value":"132","key":"NumberOfTradeLines"},{"value":"19780700","key":"FileEstablishDate"},{"value":"","key":"FileEstablishFlag"},{"value":" ","key":"FileEstablishFlag.code"},{"value":"N","key":"SAndPIndicator"},{"value":"Y","key":"KeyFactsIndicator"},{"value":"N","key":"InquiryIndicator"},{"value":"Y","key":"PublicRecordDataIndicator"},{"value":"Y","key":"BankDataIndicator"},{"value":"N","key":"GovernmentDataIndicator"},{"value":"Y","key":"CollectionIndicator"},{"value":"Y","key":"ExecutiveSummaryIndicator"},{"value":"N","key":"IndustryPremierIndicator"},{"value":"Y","key":"UCCIndicator"}],"bin":"700393131","companyInfo":{"zip":"080141000","address":"1 FLOODGATE RD","phone":"","city":"BRIDGEPORT","name":"GODWIN PUMPS OF AMERICA, INC","state":"NJ"},"transactionNumber":"","confidence":"09900","bureau":"XPB"}]}');
        att.ParentId = log.Id;
        insert att;


        test.startTest();
        try{
            //try fico first then try experian after
            nFUSE.IPluginActivator dyanmicActivator = (nFUSE.IPluginActivator)Type.forName(SBSSNamespace + 'FairIsaacCreditActivator').newInstance();
            dyanmicActivator.onActivate();
        }
        catch(Exception e){
            try{
                nFUSE.IPluginActivator dyanmicActivator = (nFUSE.IPluginActivator)Type.forName('ExperianCreditActivator').newInstance();
                dyanmicActivator.onActivate();
            }
            catch(Exception ex){
                //this block should only happen if there are NO FICO OR EXPERIAN plugins present
            }

        }
        BLUPController.BLUPPluginInfo info = new BLUPController.BLUPPluginInfo();
        try{
            BLUPController.checkForService(info);
        }
        catch(Exception e){
            system.assertEquals(true, true);
        }
        test.stopTest();
    }
    private static testMethod void testGetProductRowsBadProperty(){
        nFORCE__System_Properties__c property2 = new nFORCE__System_Properties__c(Name='bbbbb',nFORCE__Category_Name__c='FairIsaac_CreditConfiguration',nFORCE__Is_Active__c=true);
        property2.nFORCE__Key__c = BUREAU_NAME;
        property2.nFORCE__Value__c = 'fakeBureau';
        insert property2;
        setupData();

        nFUSE__Transaction_Log__c log = new nFUSE__Transaction_Log__c(Name='TestLog',nFUSE__External_Id__c='test');
        log.nFUSE__Action__c = 'new';
        log.nFUSE__Api_Version__c = '1';
        log.nFUSE__App_Plugin__c = 'FairIsaac_Credit';
        log.nFUSE__Primary_Object_Id__c = account.id;
        log.nFUSE__Requested_By_User_Id__c = 'user';
        log.nFUSE__Transaction_Status__c = 'new';
        log.nFUSE__External_Id__c = 'test';
        insert log;

        Attachment att = new Attachment();
        att.name = 'test';
        att.Body = Blob.valueOf('{"listOfSimilars":[{"sequenceNumber":"00","product":"Intelliscore","bureauData":[{"value":"132","key":"NumberOfTradeLines"},{"value":"19780700","key":"FileEstablishDate"},{"value":"","key":"FileEstablishFlag"},{"value":" ","key":"FileEstablishFlag.code"},{"value":"N","key":"SAndPIndicator"},{"value":"Y","key":"KeyFactsIndicator"},{"value":"N","key":"InquiryIndicator"},{"value":"Y","key":"PublicRecordDataIndicator"},{"value":"Y","key":"BankDataIndicator"},{"value":"N","key":"GovernmentDataIndicator"},{"value":"Y","key":"CollectionIndicator"},{"value":"Y","key":"ExecutiveSummaryIndicator"},{"value":"N","key":"IndustryPremierIndicator"},{"value":"Y","key":"UCCIndicator"}],"bin":"700393131","companyInfo":{"zip":"080141000","address":"1 FLOODGATE RD","phone":"","city":"BRIDGEPORT","name":"GODWIN PUMPS OF AMERICA, INC","state":"NJ"},"transactionNumber":"","confidence":"09900","bureau":"XPB"}]}');
        att.ParentId = log.Id;
        insert att;

        test.startTest();
        try{
            //try fico first then try experian after
            nFUSE.IPluginActivator dyanmicActivator = (nFUSE.IPluginActivator)Type.forName(SBSSNamespace + 'FairIsaacCreditActivator').newInstance();
            dyanmicActivator.onActivate();
        }
        catch(Exception e){
            try{
                nFUSE.IPluginActivator dyanmicActivator = (nFUSE.IPluginActivator)Type.forName('ExperianCreditActivator').newInstance();
                dyanmicActivator.onActivate();
            }
            catch(Exception ex){
                //this block should only happen if there are NO FICO OR EXPERIAN plugins present
            }

        }
        BLUPController.BLUPPluginInfo info = new BLUPController.BLUPPluginInfo();
        info.pluginName = BLUPController.FICO_CREDIT;
        info.pluginVersion = '1.0';
        List<BLUPController.BLUPPluginInfo> pluginInfos = new List<BLUPController.BLUPPluginInfo>();
        pluginInfos.add(info);

        try{
            BLUPController.getProductRows(pluginInfos);
        }
        catch(exception e){
            system.assertEquals(true, true);
        }

        test.stopTest();
    }
    private static testMethod void testFindServiceException(){
        nFORCE__System_Properties__c property2 = new nFORCE__System_Properties__c(Name='bbbbb',nFORCE__Category_Name__c='FairIsaac_CreditConfiguration',nFORCE__Is_Active__c=true);
        property2.nFORCE__Key__c = BUREAU_NAME;
        property2.nFORCE__Value__c = DNB_CONFIG;
        insert property2;
        setupData();

        nFUSE__Transaction_Log__c log = new nFUSE__Transaction_Log__c(Name='TestLog',nFUSE__External_Id__c='test');
        log.nFUSE__Action__c = 'new';
        log.nFUSE__Api_Version__c = '1';
        log.nFUSE__App_Plugin__c = 'FairIsaac_Credit';
        log.nFUSE__Primary_Object_Id__c = account.id;
        log.nFUSE__Requested_By_User_Id__c = 'user';
        log.nFUSE__Transaction_Status__c = 'new';
        log.nFUSE__External_Id__c = 'test';
        insert log;

        Attachment att = new Attachment();
        att.name = 'test';
        att.Body = Blob.valueOf('{"listOfSimilars":[{"sequenceNumber":"00","product":"Intelliscore","bureauData":[{"value":"132","key":"NumberOfTradeLines"},{"value":"19780700","key":"FileEstablishDate"},{"value":"","key":"FileEstablishFlag"},{"value":" ","key":"FileEstablishFlag.code"},{"value":"N","key":"SAndPIndicator"},{"value":"Y","key":"KeyFactsIndicator"},{"value":"N","key":"InquiryIndicator"},{"value":"Y","key":"PublicRecordDataIndicator"},{"value":"Y","key":"BankDataIndicator"},{"value":"N","key":"GovernmentDataIndicator"},{"value":"Y","key":"CollectionIndicator"},{"value":"Y","key":"ExecutiveSummaryIndicator"},{"value":"N","key":"IndustryPremierIndicator"},{"value":"Y","key":"UCCIndicator"}],"bin":"700393131","companyInfo":{"zip":"080141000","address":"1 FLOODGATE RD","phone":"","city":"BRIDGEPORT","name":"GODWIN PUMPS OF AMERICA, INC","state":"NJ"},"transactionNumber":"","confidence":"09900","bureau":"XPB"}]}');
        att.ParentId = log.Id;
        insert att;


        test.startTest();
        BLUPController.BLUPResponse response = new BLUPController.BLUPResponse();
        response = BLUPController.getProductRows(account.Id);
        response = BLUPController.executeBlupRequest(account.Id, FICODNB);
        BLUPController.BLUPViewModel viewModel = BLUPController.getBLUPViewModel(log.Id, account.id, FICODNB);
        response = BLUPController.updateAccount(account.id, '1234', FICODNB);


        test.stopTest();
    }
    private static testMethod void testFindServiceExceptionWithReturn(){
        nFORCE__System_Properties__c property2 = new nFORCE__System_Properties__c(Name='bbbbb',nFORCE__Category_Name__c='FairIsaac_CreditConfiguration',nFORCE__Is_Active__c=true);
        property2.nFORCE__Key__c = BUREAU_NAME;
        property2.nFORCE__Value__c = DNB_CONFIG;
        insert property2;
        setupData();

        nFUSE__Transaction_Log__c log = new nFUSE__Transaction_Log__c(Name='TestLog',nFUSE__External_Id__c='test');
        log.nFUSE__Action__c = 'new';
        log.nFUSE__Api_Version__c = '1';
        log.nFUSE__App_Plugin__c = 'FairIsaac_Credit';
        log.nFUSE__Primary_Object_Id__c = account.id;
        log.nFUSE__Requested_By_User_Id__c = 'user';
        log.nFUSE__Transaction_Status__c = 'new';
        log.nFUSE__External_Id__c = 'test';
        insert log;

        Attachment att = new Attachment();
        att.name = 'test';
        att.Body = Blob.valueOf('{"listOfSimilars":[{"sequenceNumber":"00","product":"Intelliscore","bureauData":[{"value":"132","key":"NumberOfTradeLines"},{"value":"19780700","key":"FileEstablishDate"},{"value":"","key":"FileEstablishFlag"},{"value":" ","key":"FileEstablishFlag.code"},{"value":"N","key":"SAndPIndicator"},{"value":"Y","key":"KeyFactsIndicator"},{"value":"N","key":"InquiryIndicator"},{"value":"Y","key":"PublicRecordDataIndicator"},{"value":"Y","key":"BankDataIndicator"},{"value":"N","key":"GovernmentDataIndicator"},{"value":"Y","key":"CollectionIndicator"},{"value":"Y","key":"ExecutiveSummaryIndicator"},{"value":"N","key":"IndustryPremierIndicator"},{"value":"Y","key":"UCCIndicator"}],"bin":"700393131","companyInfo":{"zip":"080141000","address":"1 FLOODGATE RD","phone":"","city":"BRIDGEPORT","name":"GODWIN PUMPS OF AMERICA, INC","state":"NJ"},"transactionNumber":"","confidence":"09900","bureau":"XPB"}]}');
        att.ParentId = log.Id;
        insert att;


        test.startTest();
        BLUPController.BLUPPluginInfo info = new BLUPController.BLUPPluginInfo();
        info.pluginName = BLUPController.FICO_CREDIT;
        info.pluginVersion = '1.0';
        BLUPController.findService(info);

        test.stopTest();
    }
    private static testMethod void testUpdateAccountException(){
        nFORCE__System_Properties__c property1 = new nFORCE__System_Properties__c(Name='AAAA',nFORCE__Category_Name__c='FairIsaac_CreditConfiguration',nFORCE__Is_Active__c=true);
        property1.nFORCE__Key__c = BUREAU_NAME;
        property1.nFORCE__Value__c = EXPERIAN_CONFIG;
        insert property1;
        setupData();

        nFUSE__Transaction_Log__c log = new nFUSE__Transaction_Log__c(Name='TestLog',nFUSE__External_Id__c='test');
        log.nFUSE__Action__c = 'new';
        log.nFUSE__Api_Version__c = '1';
        log.nFUSE__App_Plugin__c = 'FairIsaac_Credit';
        log.nFUSE__Primary_Object_Id__c = account.id;
        log.nFUSE__Requested_By_User_Id__c = 'user';
        log.nFUSE__Transaction_Status__c = 'new';
        log.nFUSE__External_Id__c = 'test';
        insert log;

        Attachment att = new Attachment();
        att.name = 'test';
        att.Body = Blob.valueOf('{"listOfSimilars":[{"sequenceNumber":"00","product":"Intelliscore","bureauData":[{"value":"132","key":"NumberOfTradeLines"},{"value":"19780700","key":"FileEstablishDate"},{"value":"","key":"FileEstablishFlag"},{"value":" ","key":"FileEstablishFlag.code"},{"value":"N","key":"SAndPIndicator"},{"value":"Y","key":"KeyFactsIndicator"},{"value":"N","key":"InquiryIndicator"},{"value":"Y","key":"PublicRecordDataIndicator"},{"value":"Y","key":"BankDataIndicator"},{"value":"N","key":"GovernmentDataIndicator"},{"value":"Y","key":"CollectionIndicator"},{"value":"Y","key":"ExecutiveSummaryIndicator"},{"value":"N","key":"IndustryPremierIndicator"},{"value":"Y","key":"UCCIndicator"}],"bin":"700393131","companyInfo":{"zip":"080141000","address":"1 FLOODGATE RD","phone":"","city":"BRIDGEPORT","name":"GODWIN PUMPS OF AMERICA, INC","state":"NJ"},"transactionNumber":"","confidence":"09900","bureau":"XPB"}]}');
        att.ParentId = log.Id;
        insert att;

        test.startTest();
        try{
            //try fico first then try experian after
            nFUSE.IPluginActivator dyanmicActivator = (nFUSE.IPluginActivator)Type.forName(SBSSNamespace + 'FairIsaacCreditActivator').newInstance();
            dyanmicActivator.onActivate();
        }
        catch(Exception e){
            try{
                nFUSE.IPluginActivator dyanmicActivator = (nFUSE.IPluginActivator)Type.forName('ExperianCreditActivator').newInstance();
                dyanmicActivator.onActivate();
            }
            catch(Exception ex){
                //this block should only happen if there are NO FICO OR EXPERIAN plugins present
            }

        }
        BLUPController.BLUPResponse response = new BLUPController.BLUPResponse();
        response.transactionLogId = log.Id;
        response = BLUPController.getProductRows(account.Id);
        response = BLUPController.executeBlupRequest(account.Id, FICOEXPERIAN);
        BLUPController.BLUPViewModel viewModel = BLUPController.getBLUPViewModel(log.Id, account.id, FICOEXPERIAN);
        response = BLUPController.updateAccount('', '1234', FICOEXPERIAN);

        test.stopTest();
    }
    private static testMethod void testDeserialization(){

        test.startTest();
        BLUPController.RootObject root = (BLUPController.RootObject)JSON.deserialize('{"listOfSimilars":[{"sequenceNumber":"00","product":"Intelliscore","bureauData":[{"value":"132","key":"NumberOfTradeLines"},{"value":"19780700","key":"FileEstablishDate"},{"value":"","key":"FileEstablishFlag"},{"value":" ","key":"FileEstablishFlag.code"},{"value":"N","key":"SAndPIndicator"},{"value":"Y","key":"KeyFactsIndicator"},{"value":"N","key":"InquiryIndicator"},{"value":"Y","key":"PublicRecordDataIndicator"},{"value":"Y","key":"BankDataIndicator"},{"value":"N","key":"GovernmentDataIndicator"},{"value":"Y","key":"CollectionIndicator"},{"value":"Y","key":"ExecutiveSummaryIndicator"},{"value":"N","key":"IndustryPremierIndicator"},{"value":"Y","key":"UCCIndicator"}],"bin":"700393131","companyInfo":{"zip":"080141000","address":"1 FLOODGATE RD","phone":"","city":"BRIDGEPORT","name":"GODWIN PUMPS OF AMERICA, INC","state":"NJ"},"transactionNumber":"","confidence":"10000","bureau":"XPB"},{"sequenceNumber":"00","product":"Intelliscore","bureauData":[{"value":"000","key":"NumberOfTradeLines"},{"value":"19780700","key":"FileEstablishDate"},{"value":"","key":"FileEstablishFlag"},{"value":" ","key":"FileEstablishFlag.code"},{"value":"N","key":"SAndPIndicator"},{"value":"Y","key":"KeyFactsIndicator"},{"value":"Y","key":"InquiryIndicator"},{"value":"Y","key":"PublicRecordDataIndicator"},{"value":"N","key":"BankDataIndicator"},{"value":"N","key":"GovernmentDataIndicator"},{"value":"Y","key":"CollectionIndicator"},{"value":"Y","key":"ExecutiveSummaryIndicator"},{"value":"N","key":"IndustryPremierIndicator"},{"value":"Y","key":"UCCIndicator"}],"bin":"000000000","companyInfo":{"zip":"08014","address":"84 BRIDGEPORT FLOODGATE RD","phone":"8564673636","city":"BRIDGEPORT","name":"XYLEM DEWATERING SOLUTIONS, INC","state":"NJ"},"transactionNumber":"","confidence":"09900","bureau":"XPB"}, {"sequenceNumber":"00","product":"Intelliscore","bureauData":[{"value":"132","key":"NumberOfTradeLines"},{"value":"19780700","key":"FileEstablishDate"},{"value":"","key":"FileEstablishFlag"},{"value":" ","key":"FileEstablishFlag.code"},{"value":"N","key":"SAndPIndicator"},{"value":"Y","key":"KeyFactsIndicator"},{"value":"N","key":"InquiryIndicator"},{"value":"Y","key":"PublicRecordDataIndicator"},{"value":"Y","key":"BankDataIndicator"},{"value":"N","key":"GovernmentDataIndicator"},{"value":"Y","key":"CollectionIndicator"},{"value":"Y","key":"ExecutiveSummaryIndicator"},{"value":"N","key":"IndustryPremierIndicator"},{"value":"Y","key":"UCCIndicator"}],"bin":"700393131","companyInfo":{"zip":"080141000","address":"1 FLOODGATE RD","phone":"","city":"BRIDGEPORT","name":"GODWIN PUMPS OF AMERICA, INC","state":"NJ"},"transactionNumber":"","confidence":"09900","bureau":"XPB"},{"sequenceNumber":"00","product":"Intelliscore","bureauData":[{"value":"000","key":"NumberOfTradeLines"},{"value":"19780700","key":"FileEstablishDate"},{"value":"","key":"FileEstablishFlag"},{"value":" ","key":"FileEstablishFlag.code"},{"value":"N","key":"SAndPIndicator"},{"value":"Y","key":"KeyFactsIndicator"},{"value":"Y","key":"InquiryIndicator"},{"value":"Y","key":"PublicRecordDataIndicator"},{"value":"N","key":"BankDataIndicator"},{"value":"N","key":"GovernmentDataIndicator"},{"value":"Y","key":"CollectionIndicator"},{"value":"Y","key":"ExecutiveSummaryIndicator"},{"value":"N","key":"IndustryPremierIndicator"},{"value":"Y","key":"UCCIndicator"}],"bin":"000000000","companyInfo":{"zip":"08014","address":"84 BRIDGEPORT FLOODGATE RD","phone":"8564673636","city":"BRIDGEPORT","name":"XYLEM DEWATERING SOLUTIONS, INC","state":"NJ"},"transactionNumber":"","confidence":"09800","bureau":"XPB"}, {"sequenceNumber":"00","product":"Intelliscore","bureauData":[{"value":"132","key":"NumberOfTradeLines"},{"value":"19780700","key":"FileEstablishDate"},{"value":"","key":"FileEstablishFlag"},{"value":" ","key":"FileEstablishFlag.code"},{"value":"N","key":"SAndPIndicator"},{"value":"Y","key":"KeyFactsIndicator"},{"value":"N","key":"InquiryIndicator"},{"value":"Y","key":"PublicRecordDataIndicator"},{"value":"Y","key":"BankDataIndicator"},{"value":"N","key":"GovernmentDataIndicator"},{"value":"Y","key":"CollectionIndicator"},{"value":"Y","key":"ExecutiveSummaryIndicator"},{"value":"N","key":"IndustryPremierIndicator"},{"value":"Y","key":"UCCIndicator"}],"bin":"700393131","companyInfo":{"zip":"080141000","address":"1 FLOODGATE RD","phone":"","city":"BRIDGEPORT","name":"GODWIN PUMPS OF AMERICA, INC","state":"NJ"},"transactionNumber":"","confidence":"09900","bureau":"XPB"},{"sequenceNumber":"00","product":"Intelliscore","bureauData":[{"value":"000","key":"NumberOfTradeLines"},{"value":"19780700","key":"FileEstablishDate"},{"value":"","key":"FileEstablishFlag"},{"value":" ","key":"FileEstablishFlag.code"},{"value":"N","key":"SAndPIndicator"},{"value":"Y","key":"KeyFactsIndicator"},{"value":"Y","key":"InquiryIndicator"},{"value":"Y","key":"PublicRecordDataIndicator"},{"value":"N","key":"BankDataIndicator"},{"value":"N","key":"GovernmentDataIndicator"},{"value":"Y","key":"CollectionIndicator"},{"value":"Y","key":"ExecutiveSummaryIndicator"},{"value":"N","key":"IndustryPremierIndicator"},{"value":"Y","key":"UCCIndicator"}],"bin":"000000000","companyInfo":{"zip":"08014","address":"84 BRIDGEPORT FLOODGATE RD","phone":"8564673636","city":"BRIDGEPORT","name":"XYLEM DEWATERING SOLUTIONS, INC","state":"NJ"},"transactionNumber":"","confidence":"09900","bureau":"XPB"}]}', BLUPController.RootObject.class);
        BLUPController.BureauData data = new BLUPController.BureauData();
        data.key = 'test';
        data.value = 'test';
        BLUPController.ListOfSimilar listOfSimilar = new BLUPController.ListOfSimilar();
        listOfSimilar.sequenceNumber = 'test';
        listOfSimilar.product = 'test';
        listOfSimilar.bureauData = new List<BLUPController.BureauData>();
        listOfSimilar.bureauData.add(data);
        listOfSimilar.transactionNumber = '1234';
        listOfSimilar.bureau = 'test';
        test.stopTest();
    }
    public static String SBSSNamespace {
        get{
            if(SBSSNamespace == null){
                List<ApexPage> apexPages = [SELECT NamespacePrefix FROM ApexPage where NamespacePrefix='SBSS'];
               if(apexPages.size()>0)
                    SBSSNamespace = 'SBSS.';
                else
                    SBSSNamespace = '';
            }
            return SBSSNamespace;
        }
        set{
            SBSSNamespace = value;
        }
    }
    private static final String
            NFUSE_CONFIGURATION_KEYWORD = 'Configuration',
            ACTION='businesslookup',
            PERMISSION_NAME ='Business_Lookup',
            COMMA_SPACE = ', ',
            SALESFORCE_SESSION_ID = 'salesforce_session_id',
            PRIMARY_OBJECT_ID = 'primary_object_id',
            FICO_CREDIT= 'FairIsaac_Credit',
            EXP_CREDIT = 'Experian_Credit',
            EXPERIAN = 'Experian',
            FICODNB = 'Fair Isaac D&B',
            FICOEXPERIAN = 'Fair Isaac Experian',
            EXPERIAN_BIN = 'Experian_BIN__c',
            DUNS = 'LLC_BI__Duns_Number__c',
            BUREAU_NAME = 'FICO Business Bureau Name',
            EXPERIAN_CONFIG = 'EXPERIAN',
            DNB_CONFIG = 'DnB',
            X_MISSING_REQUIRED_PROPERTY = 'Missing BLUP configured property',
            RECORD = 'record';

}