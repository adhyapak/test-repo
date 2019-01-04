@isTest
private class TestExperianXmlPdfController {
    private static LLC_BI__Loan__c createLoan(String name,Id accountId) {
		LLC_BI__Loan__c loan = new LLC_BI__Loan__c(
			Name = name,
			LLC_BI__Account__c = accountId
		);
		insert loan;
		return loan;
	}
    private static LLC_BI__LLC_LoanDocument__c createLLcLoanDocument(
		String name,
		Id loanId,
		String year,
		String reviewStatus,
		Id documentStoreIndexId,
		Id docTypeId,
		Id docManId) {

		LLC_BI__LLC_LoanDocument__c newLoan = new LLC_BI__LLC_LoanDocument__c(
			Name = name,
			LLC_BI__Loan__c = loanId,
			NDOC__Year__c = year,
			LLC_BI__ReviewStatus__c = reviewStatus,
			LLC_BI__Document_Store_Index__c = documentStoreIndexId,
			LLC_BI__docType__c = docTypeId,
			LLC_BI__docManager__c = docManId
		);
		insert newLoan;
		return newLoan;
	}
    private static ContentVersion getContentVersionById(Id id){
		return [
			SELECT
				Id,
				Title,
				ContentDocumentId
			FROM
				ContentVersion
			WHERE
				Id =: id
		];
	}
    private static ContentVersion createContentVersion(String title, String path, Blob versionData){
		return new ContentVersion(
			Title = title,
			PathOnClient = path,
			VersionData = versionData,
			Origin = 'C'
		);
	}
    private static List<ContentVersion> createContentVersions(Integer count){
		List<ContentVersion> contentVersionList = new List<ContentVersion>();
		for(Integer i = 0; i < count; i++){
			String title = 'Title ' + i;
			String path = 'Test Path ' + i;
			Blob versionData = Blob.valueOf('Test Blob ' + i);
			contentVersionList.add(createContentVersion(title, path ,versionData));
		}
		insert contentVersionList;
		List<Id> contentVersionIds = new List<Id>();
		for(ContentVersion cVer : contentVersionList){
			contentVersionIds.add(cVer.Id);
		}
		return contentVersionList;
	}
	private static Account createAccount(String name) {
		Account account = new Account(
			Name = name);
		insert account;
		return account;
	}
	private static Id createDocumentStore() {
		LLC_BI__Document_Store__c docStore = new LLC_BI__Document_Store__c();
		insert docStore;
		return docStore.Id;
	}
	private static LLC_BI__Document_Store_Index__c createDocumentStoreIndex(Id docStore) {
		LLC_BI__Document_Store_Index__c docStoreIndex = new LLC_BI__Document_Store_Index__c(
			LLC_BI__Document_Store__c = docStore
		);
		insert docStoreIndex;
		return docStoreIndex;
	}
	private static LLC_BI__AccountDocument__c createAccountDocument(
		String name,
		Id accountId,
		String year,
		String reviewStatus,
		Id documentStoreIndexId,
		Id docTypeId,
		Id docManId) {

		LLC_BI__AccountDocument__c newAccountDoc = new LLC_BI__AccountDocument__c(
			Name = name,
			LLC_BI__Account__c = accountId,
			NDOC__Year__c = year,
			LLC_BI__ReviewStatus__c = reviewStatus,
			LLC_BI__Document_Store_Index__c = documentStoreIndexId,
			LLC_BI__docType__c = docTypeId,
			LLC_BI__docManager__c = docManId
		);
		insert newAccountDoc;
		return newAccountDoc;
	}
	
	private static LLC_BI__docType__c createDocType(){
	    LLC_BI__docType__c docType = new LLC_BI__docType__c(
			name = 'test Doc Type'
		);
		insert docType;
		return docType;
	}
	private static LLC_BI__Document_Version__c createDocumentVersion(
		String placeholderId,
		Id docStoreId,
		Id contentVersionId,
		String fileType,
		String fileExtension,
		String title
	){
		LLC_BI__Document_Version__c docVer = new LLC_BI__Document_Version__c(
			LLC_BI__Document_Store__c = docStoreId,
			LLC_BI__Placeholder_Id__c = placeholderId,
			LLC_BI__Content_Version_Id__c = contentVersionId,
			LLC_BI__File_Extension__c = fileExtension,
			LLC_BI__File_Type__c = fileType,
			LLC_BI__Title__c = title
		);
		insert docVer;
		return docVer;
	}
	private static LLC_BI__DocManager__c createDocManager(String targetSObject){
	    LLC_BI__DocManager__c docMan = new LLC_BI__DocManager__c(
			Name = 'DocMan',
			LLC_BI__Type__c = targetSObject//'LLC_BI__Account__c'
		);
		insert docMan;
		return docMan;
	}
	private static ContentDocumentLink createContentDocumentLink(Id documentStoreId, Id contentDocumentId){
		ContentDocumentLink link = new ContentDocumentLink(
			LinkedEntityId = documentStoreId,
			ContentDocumentId = contentDocumentId,
			ShareType = 'V'
		);
		insert link;
		return link;
	}
    
    @isTest
    private static void testControllerLoadsWithOverrideReportType(){
        List<ContentVersion> contentVersions = createContentVersions(1);
        System.debug(contentVersions);
        
        ApexPages.currentPage().getParameters().put('contentVersionId', contentVersions[0].Id);
        ApexPages.currentPage().getParameters().put('reportType', 'SBCS');
        ExperianXmlPdfController controller = new ExperianXmlPdfController();
        System.assertEquals(true,true);
    }
    @isTest
    private static void testControllerLoadsWithOverrideReportTypeElse(){
        List<ContentVersion> contentVersions = createContentVersions(1);
        System.debug(contentVersions);
        
        ApexPages.currentPage().getParameters().put('contentVersionId', contentVersions[0].Id);
        ApexPages.currentPage().getParameters().put('reportType', 'SBCS2');
        ExperianXmlPdfController controller = new ExperianXmlPdfController();
        System.assertEquals(true,true);
    }
    
    @isTest
    private static void testControllerLoadsButThrowsNoVersionOrPlaceholderKey(){
        try{
            ExperianXmlPdfController controller = new ExperianXmlPdfController();
            System.assertEquals(true,false);
        }catch(ExperianXmlPdfController.XExperianXmlPdfControllerContentVersionIdNotProvidedException e){
            System.assertEquals(true,true);
        }
    }
    
    @isTest
    private static void testControllerGetPageParams(){
        ApexPages.currentPage().getParameters().put('resourceOverride', 'test');
        String param = ExperianXmlPdfController.getPageParam('resourceOverride');
        System.assertEquals(true,param == 'test');
    }
    
    @isTest
    private static void testControllerinjectTagToSpecificNode(){
        String injectable = '<root><test>123</test></root>';
        String tagToInjectToRootPayload = '<pizza>test</pizza>';
        String transformed = ExperianXmlPdfController.injectTagToSpecificNode(injectable,'<test>',tagToInjectToRootPayload+'<test>');
        System.assertEquals(true,transformed.contains('<pizza>test</pizza>'));
    }
    
    @isTest
    private static void testgetContentFromContentVersion(){
        
        List<ContentVersion> contentVersions = createContentVersions(1);
        System.debug(contentVersions);
        
        ApexPages.currentPage().getParameters().put('contentVersionId', contentVersions[0].Id);
        
        ExperianXmlPdfController controller = new ExperianXmlPdfController();
        String content = controller.getContentFromContentVersion(contentVersions[0].Id);
        System.assertEquals(true,content == 'Test Blob 0');
    }
    
    @isTest
    private static void testgetContentFromContentVersionFailsNotLatest(){
        
        List<ContentVersion> contentVersions = createContentVersions(1);
        System.debug(contentVersions);
        
        ApexPages.currentPage().getParameters().put('contentVersionId', contentVersions[0].Id);
        
        ExperianXmlPdfController controller = new ExperianXmlPdfController();
        
        try{
            String content = controller.getContentFromContentVersion('7071I00000ROHzq');
            System.assertEquals(true,false);
        }catch(ExperianXmlPdfController.XExperianXmlPdfControllerContentVersionIdNotFoundException e){
            System.assertEquals(true,true);
        }
        
        
        
    }
    
    @isTest
    private static void testgetContentVersionIdFromPlaceholderKey(){
        
        List<ContentVersion> contentVersions = createContentVersions(1);
        System.debug(contentVersions);
        ApexPages.currentPage().getParameters().put('contentVersionId', contentVersions[0].Id);
        
        ExperianXmlPdfController controller = new ExperianXmlPdfController();
        System.assertEquals(true,true);
    }
    
    @isTest(seeAllData=true)
    private static void testgetResourceURL(){
        String url = ExperianXmlPdfController.getResourceURL('EXPRN_EXPSTYLENEW_RelativeLinks');
        System.assertEquals(true,!String.isBlank(url));
    }
    
    @isTest
    private static void testgetResourceURLThrowsWhenNotFound(){
        try{
            String url = ExperianXmlPdfController.getResourceURL('Test');
            System.assertEquals(true,false);
        }catch(Exception e){
            System.assertEquals(true,true);
        }
    }
    
    @isTest
    private static void testgetContentVersionIdFromPlaceholderKeyThrowsOnUnsupportedLocation(){
        try{
            ApexPages.currentPage().getParameters().put('placeholderKey', '7071I00000ROHzq');
            ApexPages.currentPage().getParameters().put('location', 'somethingnotsupported');
            ExperianXmlPdfController controller = new ExperianXmlPdfController();
            System.assertEquals(true,false);
        }catch(ExperianXmlPdfController.XExperianXmlPdfControllerContentVersionIdNotFoundException e){
            System.assertEquals(true,true);
        }
    }
    @isTest
    private static void testControllerLoadsWithPlaceholderKeyFailsOnMoreThanOneContentDocumentLink(){
        Test.testInstall(new nDOC.DocManDataInstaller(), null);
        
        Account account = createAccount('Test');
        LLC_BI__DocManager__c docManager = createDocManager('LLC_BI__Account__c');
        LLC_BI__docType__c docType = createDocType();
        Id documentStoreId = createDocumentStore();
        Id documentStoreId2 = createDocumentStore();
        LLC_BI__Document_Store_Index__c index = createDocumentStoreIndex(documentStoreId);
        LLC_BI__Document_Store_Index__c index2 = createDocumentStoreIndex(documentStoreId2);
        
        LLC_BI__AccountDocument__c accountDocument = createAccountDocument('Test Placeholder',
			account.Id,
			'2015',
			'In-File',
			index.Id,
			docType.id,
			docManager.Id);
		LLC_BI__AccountDocument__c accountDocument2 = createAccountDocument('Test Placeholder',
			account.Id,
			'2015',
			'In-File',
			index2.Id,
			docType.id,
			docManager.Id);
        
        List<ContentVersion> contentVersions = createContentVersions(1);
        System.debug(contentVersions);
        
        ContentVersion v = contentVersions[0];
        
        LLC_BI__Document_Version__c docVersion = createDocumentVersion(
    		accountDocument.Id,
    		documentStoreId,
    		v.Id,
    		'text/plain',
    		'txt',
    		'sampletitle'
    	);
    	LLC_BI__Document_Version__c docVersion2 = createDocumentVersion(
    		accountDocument2.Id,
    		documentStoreId2,
    		v.Id,
    		'text/plain',
    		'txt',
    		'sampletitle'
    	);
    	
        ApexPages.currentPage().getParameters().put('placeholderKey', accountDocument.Id);
        ApexPages.currentPage().getParameters().put('location', 'account');
        
        try{
            ExperianXmlPdfController controller = new ExperianXmlPdfController();
            System.assertEquals(true,false);
        }catch(ExperianXmlPdfController.XExperianXmlPdfControllerContentVersionIdNotFoundException e){
            System.assertEquals(true,e.getMessage().toLowerCase().contains('more than one record returned for contentdocumentlink'));
        }
        
    }
    @isTest
    private static void testControllerLoadsWithPlaceholderKeyFailsOnDocumentLinkMissing(){
        Test.testInstall(new nDOC.DocManDataInstaller(), null);
        
        Account account = createAccount('Test');
        LLC_BI__DocManager__c docManager = createDocManager('LLC_BI__Account__c');
        LLC_BI__docType__c docType = createDocType();
        Id documentStoreId = createDocumentStore();
        LLC_BI__Document_Store_Index__c index = createDocumentStoreIndex(documentStoreId);
        
        LLC_BI__AccountDocument__c accountDocument = createAccountDocument('Test Placeholder',
			account.Id,
			'2015',
			'In-File',
			index.Id,
			docType.id,
			docManager.Id);
        
        List<ContentVersion> contentVersions = createContentVersions(1);
        System.debug(contentVersions);
        
        ContentVersion v = contentVersions[0];
        
        LLC_BI__Document_Version__c docVersion = createDocumentVersion(
    		accountDocument.Id,
    		documentStoreId,
    		v.Id,
    		'text/plain',
    		'txt',
    		'sampletitle'
    	);
    	
        ApexPages.currentPage().getParameters().put('placeholderKey', accountDocument.Id);
        ApexPages.currentPage().getParameters().put('location', 'account');
        
        try{
            ExperianXmlPdfController controller = new ExperianXmlPdfController();
            System.assertEquals(true,false);
        }catch(ExperianXmlPdfController.XExperianXmlPdfControllerContentVersionIdNotFoundException e){
            System.assertEquals(true,true);
        }
        
    }
    @isTest
    private static void testControllerLoadsWithPlaceholderKeyFailsOnContentVersionMissing(){
        Test.testInstall(new nDOC.DocManDataInstaller(), null);
        
        Account account = createAccount('Test');
        LLC_BI__DocManager__c docManager = createDocManager('LLC_BI__Account__c');
        LLC_BI__docType__c docType = createDocType();
        Id documentStoreId = createDocumentStore();
        LLC_BI__Document_Store_Index__c index = createDocumentStoreIndex(documentStoreId);
        
        LLC_BI__AccountDocument__c accountDocument = createAccountDocument('Test Placeholder',
			account.Id,
			'2015',
			'In-File',
			index.Id,
			docType.id,
			docManager.Id);
        
        List<ContentVersion> contentVersions = createContentVersions(1);
        System.debug(contentVersions);
        
        ContentVersion v = contentVersions[0];
        
        LLC_BI__Document_Version__c docVersion = createDocumentVersion(
    		accountDocument.Id,
    		documentStoreId,
    		'7071I00000ROHzq',
    		'text/plain',
    		'txt',
    		'sampletitle'
    	);
    	
        ApexPages.currentPage().getParameters().put('placeholderKey', accountDocument.Id);
        ApexPages.currentPage().getParameters().put('location', 'account');
        
        try{
            ExperianXmlPdfController controller = new ExperianXmlPdfController();
            System.assertEquals(true,false);
        }catch(ExperianXmlPdfController.XExperianXmlPdfControllerContentVersionIdNotFoundException e){
            System.assertEquals(true,true);
        }
        
    }
    @isTest
    private static void testControllerLoadsWithPlaceholderKeyOnAccount(){
        Test.testInstall(new nDOC.DocManDataInstaller(), null);
        
        Account account = createAccount('Test');
        LLC_BI__DocManager__c docManager = createDocManager('LLC_BI__Account__c');
        LLC_BI__docType__c docType = createDocType();
        Id documentStoreId = createDocumentStore();
        LLC_BI__Document_Store_Index__c index = createDocumentStoreIndex(documentStoreId);
        
        LLC_BI__AccountDocument__c accountDocument = createAccountDocument('Test Placeholder',
			account.Id,
			'2015',
			'In-File',
			index.Id,
			docType.id,
			docManager.Id);
        
        List<ContentVersion> contentVersions = createContentVersions(1);
        System.debug('Content Versions ' + contentVersions);
        
        ContentVersion v = contentVersions[0];
        
        LLC_BI__Document_Version__c docVersion = createDocumentVersion(
    		accountDocument.Id,
    		documentStoreId,
    		v.Id,
    		'text/plain',
    		'txt',
    		'sampletitle'
    	);
    	
    	
    	ContentVersion version = getContentVersionById(v.Id);

		ContentDocumentLink contentDocLink = createContentDocumentLink(
			documentStoreId,
			version.ContentDocumentId
		);

        
        Set<Id> newset = new Set<Id>();
        newset.add(contentDocLink.Id);
        System.debug('Content version links ' + [SELECT Id, ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId IN :newset]);
        // System.debug('Content version links by Content Document Id ' + [SELECT Id, ContentDocumentId FROM ContentDocumentLink where ContentDocumentId = :v.Id]);
        // System.debug('Content version links by Content Document Id ' + [SELECT Id, ContentDocumentId FROM ContentDocumentLink where ContentDocumentId = :v.Id]);
        
        ApexPages.currentPage().getParameters().put('placeholderKey', accountDocument.Id);
        ApexPages.currentPage().getParameters().put('location', 'account');
        ExperianXmlPdfController controller = new ExperianXmlPdfController();
        System.assertEquals(true,controller.XMLInjectedSample.toLowerCase().contains('test blob'));
    }
    @isTest
    private static void testControllerLoadsWithPlaceholderKeyOnLoan(){
        Test.testInstall(new nDOC.DocManDataInstaller(), null);
        
        Account account = createAccount('Test');
        LLC_BI__Loan__c loan = createLoan('Test',account.Id);
        LLC_BI__DocManager__c docManager = createDocManager('LLC_BI__Loan__c');
        LLC_BI__docType__c docType = createDocType();
        Id documentStoreId = createDocumentStore();
        LLC_BI__Document_Store_Index__c index = createDocumentStoreIndex(documentStoreId);
        
//         LLC_BI__AccountDocument__c accountDocument = createAccountDocument('Test Placeholder',
// 			account.Id,
// 			'2015',
// 			'In-File',
// 			index.Id,
// 			docType.id,
// 			docManager.Id);
			
		LLC_BI__LLC_LoanDocument__c loanDocument = createLLcLoanDocument(
			'testDoc1',
			loan.id,
			'1812',
			'In File',
			index.id,
			docType.id,
			docManager.Id
		);
        
        List<ContentVersion> contentVersions = createContentVersions(1);
        System.debug('Content Versions ' + contentVersions);
        
        ContentVersion v = contentVersions[0];
        
        LLC_BI__Document_Version__c docVersion = createDocumentVersion(
    		loanDocument.Id,
    		documentStoreId,
    		v.Id,
    		'text/plain',
    		'txt',
    		'sampletitle'
    	);
    	
    	
    	ContentVersion version = getContentVersionById(v.Id);

		ContentDocumentLink contentDocLink = createContentDocumentLink(
			documentStoreId,
			version.ContentDocumentId
		);

        
        Set<Id> newset = new Set<Id>();
        newset.add(contentDocLink.Id);
        System.debug('Content version links ' + [SELECT Id, ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId IN :newset]);
        // System.debug('Content version links by Content Document Id ' + [SELECT Id, ContentDocumentId FROM ContentDocumentLink where ContentDocumentId = :v.Id]);
        // System.debug('Content version links by Content Document Id ' + [SELECT Id, ContentDocumentId FROM ContentDocumentLink where ContentDocumentId = :v.Id]);
        
        ApexPages.currentPage().getParameters().put('placeholderKey', loanDocument.Id);
        ApexPages.currentPage().getParameters().put('location', 'loan');
        ExperianXmlPdfController controller = new ExperianXmlPdfController();
        System.assertEquals(true,controller.XMLInjectedSample.toLowerCase().contains('test blob'));
    }
    
    //TODO: complete
    @isTest
    private static void testgetContentVersionIdFromPlaceholderKey_MoreThanOneAccountDocumentByPlaceholderKey(){
        
        Test.testInstall(new nDOC.DocManDataInstaller(), null);
        
        Account account = createAccount('Test');
        LLC_BI__Loan__c loan = createLoan('Test',account.Id);
        LLC_BI__DocManager__c docManager = createDocManager('LLC_BI__Loan__c');
        LLC_BI__docType__c docType = createDocType();
        Id documentStoreId = createDocumentStore();
        LLC_BI__Document_Store_Index__c index = createDocumentStoreIndex(documentStoreId);
        
//         LLC_BI__AccountDocument__c accountDocument = createAccountDocument('Test Placeholder',
// 			account.Id,
// 			'2015',
// 			'In-File',
// 			index.Id,
// 			docType.id,
// 			docManager.Id);
			
		LLC_BI__LLC_LoanDocument__c loanDocument = createLLcLoanDocument(
			'testDoc1',
			loan.id,
			'1812',
			'In File',
			index.id,
			docType.id,
			docManager.Id
		);
        
        List<ContentVersion> contentVersions = createContentVersions(1);
        System.debug('Content Versions ' + contentVersions);
        
        ContentVersion v = contentVersions[0];
        
        LLC_BI__Document_Version__c docVersion = createDocumentVersion(
    		loanDocument.Id,
    		documentStoreId,
    		v.Id,
    		'text/plain',
    		'txt',
    		'sampletitle'
    	);
    	
    	
    	ContentVersion version = getContentVersionById(v.Id);

		ContentDocumentLink contentDocLink = createContentDocumentLink(
			documentStoreId,
			version.ContentDocumentId
		);

        
        Set<Id> newset = new Set<Id>();
        newset.add(contentDocLink.Id);
        System.debug('Content version links ' + [SELECT Id, ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId IN :newset]);
        // System.debug('Content version links by Content Document Id ' + [SELECT Id, ContentDocumentId FROM ContentDocumentLink where ContentDocumentId = :v.Id]);
        // System.debug('Content version links by Content Document Id ' + [SELECT Id, ContentDocumentId FROM ContentDocumentLink where ContentDocumentId = :v.Id]);
        
        ApexPages.currentPage().getParameters().put('placeholderKey', loanDocument.Id);
        ApexPages.currentPage().getParameters().put('location', 'account');
        
        try{
            ExperianXmlPdfController controller = new ExperianXmlPdfController();
            System.assertEquals(true,controller.XMLInjectedSample.toLowerCase().contains('test blob'));
        }catch(ExperianXmlPdfController.XExperianXmlPdfControllerContentVersionIdNotFoundException e){
            System.assertEquals(true,e.getMessage().toLowerCase().contains('more than one record returned for llc_bi__accountdocument__c'));
        }
        
        
    }
    //TODO: complete
    @isTest
    private static void testgetContentVersionIdFromPlaceholderKey_MoreThanOneLoanDocumentByPlaceholderKey(){
        Test.testInstall(new nDOC.DocManDataInstaller(), null);
        
        Account account = createAccount('Test');
        LLC_BI__DocManager__c docManager = createDocManager('LLC_BI__Account__c');
        LLC_BI__docType__c docType = createDocType();
        Id documentStoreId = createDocumentStore();
        LLC_BI__Document_Store_Index__c index = createDocumentStoreIndex(documentStoreId);
        
        LLC_BI__AccountDocument__c accountDocument = createAccountDocument('Test Placeholder',
			account.Id,
			'2015',
			'In-File',
			index.Id,
			docType.id,
			docManager.Id);
        
        List<ContentVersion> contentVersions = createContentVersions(1);
        System.debug('Content Versions ' + contentVersions);
        
        ContentVersion v = contentVersions[0];
        
        LLC_BI__Document_Version__c docVersion = createDocumentVersion(
    		accountDocument.Id,
    		documentStoreId,
    		v.Id,
    		'text/plain',
    		'txt',
    		'sampletitle'
    	);
    	
    	
    	ContentVersion version = getContentVersionById(v.Id);

		ContentDocumentLink contentDocLink = createContentDocumentLink(
			documentStoreId,
			version.ContentDocumentId
		);

        
        Set<Id> newset = new Set<Id>();
        newset.add(contentDocLink.Id);
        System.debug('Content version links ' + [SELECT Id, ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId IN :newset]);
        // System.debug('Content version links by Content Document Id ' + [SELECT Id, ContentDocumentId FROM ContentDocumentLink where ContentDocumentId = :v.Id]);
        // System.debug('Content version links by Content Document Id ' + [SELECT Id, ContentDocumentId FROM ContentDocumentLink where ContentDocumentId = :v.Id]);
        
        ApexPages.currentPage().getParameters().put('placeholderKey', accountDocument.Id);
        ApexPages.currentPage().getParameters().put('location', 'loan');
        try{
            ExperianXmlPdfController controller = new ExperianXmlPdfController();
            System.assertEquals(true,controller.XMLInjectedSample.toLowerCase().contains('test blob'));
        }catch(ExperianXmlPdfController.XExperianXmlPdfControllerContentVersionIdNotFoundException e){
            System.assertEquals(true,e.getMessage().toLowerCase().contains('more than one record returned for llc_bi__llc_loandocument__c'));
        }
    }
    //TODO: complete
    @isTest
    private static void testgetContentVersionIdFromPlaceholderKey_ContentDocumentLink(){
        
        Test.testInstall(new nDOC.DocManDataInstaller(), null);
        
        Account account = createAccount('Test');
        LLC_BI__DocManager__c docManager = createDocManager('LLC_BI__Account__c');
        LLC_BI__docType__c docType = createDocType();
        
        Id documentStoreId = createDocumentStore();
        LLC_BI__Document_Store_Index__c index = createDocumentStoreIndex(documentStoreId);
        
        Id documentStoreId2 = createDocumentStore();
        LLC_BI__Document_Store_Index__c index2 = createDocumentStoreIndex(documentStoreId2);
        
        LLC_BI__AccountDocument__c accountDocument = createAccountDocument('Test Placeholder',
			account.Id,
			'2015',
			'In-File',
			index2.Id,
			docType.id,
			docManager.Id);
        
        List<ContentVersion> contentVersions = createContentVersions(1);
        System.debug('Content Versions ' + contentVersions);
        
        ContentVersion v = contentVersions[0];
        
        LLC_BI__Document_Version__c docVersion = createDocumentVersion(
    		accountDocument.Id,
    		documentStoreId,
    		v.Id,
    		'text/plain',
    		'txt',
    		'sampletitle'
    	);
    	
    	
    	ContentVersion version = getContentVersionById(v.Id);

		ContentDocumentLink contentDocLink = createContentDocumentLink(
			documentStoreId,
			version.ContentDocumentId
		);

        
        Set<Id> newset = new Set<Id>();
        newset.add(contentDocLink.Id);
        System.debug('Content version links ' + [SELECT Id, ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId IN :newset]);
        // System.debug('Content version links by Content Document Id ' + [SELECT Id, ContentDocumentId FROM ContentDocumentLink where ContentDocumentId = :v.Id]);
        // System.debug('Content version links by Content Document Id ' + [SELECT Id, ContentDocumentId FROM ContentDocumentLink where ContentDocumentId = :v.Id]);
        
        ApexPages.currentPage().getParameters().put('placeholderKey', accountDocument.Id);
        ApexPages.currentPage().getParameters().put('location', 'account');
        
        try{
            ExperianXmlPdfController controller = new ExperianXmlPdfController();
            System.assertEquals(true,controller.XMLInjectedSample.toLowerCase().contains('test blob'));
        }catch(ExperianXmlPdfController.XExperianXmlPdfControllerContentVersionIdNotFoundException e){
            System.assertEquals(true,e.getMessage().toLowerCase().contains('more than one record returned for contentdocumentlink'));
        }
        
    }
    //TODO: complete
    @isTest
    private static void testgetContentVersionIdFromPlaceholderKey_ZeroDocumentStoreIndice(){
        Test.testInstall(new nDOC.DocManDataInstaller(), null);
        
        Account account = createAccount('Test');
        LLC_BI__Loan__c loan = createLoan('Test',account.Id);
        LLC_BI__DocManager__c docManager = createDocManager('LLC_BI__Loan__c');
        LLC_BI__docType__c docType = createDocType();
        Id documentStoreId = createDocumentStore();
        LLC_BI__Document_Store_Index__c index = createDocumentStoreIndex(documentStoreId);
        
//         LLC_BI__AccountDocument__c accountDocument = createAccountDocument('Test Placeholder',
// 			account.Id,
// 			'2015',
// 			'In-File',
// 			index.Id,
// 			docType.id,
// 			docManager.Id);
			
		LLC_BI__LLC_LoanDocument__c loanDocument = createLLcLoanDocument(
			'testDoc1',
			loan.id,
			'1812',
			'In File',
			index.id,
			docType.id,
			docManager.Id
		);
        
        List<ContentVersion> contentVersions = createContentVersions(1);
        System.debug('Content Versions ' + contentVersions);
        
        ContentVersion v = contentVersions[0];
        
        LLC_BI__Document_Version__c docVersion = createDocumentVersion(
    		loanDocument.Id,
    		documentStoreId,
    		v.Id,
    		'text/plain',
    		'txt',
    		'sampletitle'
    	);
    	
    	
    	ContentVersion version = getContentVersionById(v.Id);

		ContentDocumentLink contentDocLink = createContentDocumentLink(
			documentStoreId,
			version.ContentDocumentId
		);

        
        Set<Id> newset = new Set<Id>();
        newset.add(contentDocLink.Id);
        System.debug('Content version links ' + [SELECT Id, ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId IN :newset]);
        // System.debug('Content version links by Content Document Id ' + [SELECT Id, ContentDocumentId FROM ContentDocumentLink where ContentDocumentId = :v.Id]);
        // System.debug('Content version links by Content Document Id ' + [SELECT Id, ContentDocumentId FROM ContentDocumentLink where ContentDocumentId = :v.Id]);
        
        ApexPages.currentPage().getParameters().put('placeholderKey', loanDocument.Id);
        ApexPages.currentPage().getParameters().put('location', 'loan');
        ExperianXmlPdfController.forceZeroDocumentStoreIndices = true;
        
        
        try{
            ExperianXmlPdfController controller = new ExperianXmlPdfController();
            System.assertEquals(true,controller.XMLInjectedSample.toLowerCase().contains('test blob'));
        }catch(ExperianXmlPdfController.XExperianXmlPdfControllerContentVersionIdNotFoundException e){
            System.assertEquals(true,e.getMessage().toLowerCase().contains('more than one record returned for llc_bi__document_store_index__c'));
        }
        
    }
    //TODO: complete
    @isTest
    private static void testgetContentVersionIdFromPlaceholderKey_ZeroDocumentStores(){
        Test.testInstall(new nDOC.DocManDataInstaller(), null);
        
        Account account = createAccount('Test');
        LLC_BI__Loan__c loan = createLoan('Test',account.Id);
        LLC_BI__DocManager__c docManager = createDocManager('LLC_BI__Loan__c');
        LLC_BI__docType__c docType = createDocType();
        Id documentStoreId = createDocumentStore();
        LLC_BI__Document_Store_Index__c index = createDocumentStoreIndex(documentStoreId);
        
//         LLC_BI__AccountDocument__c accountDocument = createAccountDocument('Test Placeholder',
// 			account.Id,
// 			'2015',
// 			'In-File',
// 			index.Id,
// 			docType.id,
// 			docManager.Id);
			
		LLC_BI__LLC_LoanDocument__c loanDocument = createLLcLoanDocument(
			'testDoc1',
			loan.id,
			'1812',
			'In File',
			index.id,
			docType.id,
			docManager.Id
		);
        
        List<ContentVersion> contentVersions = createContentVersions(1);
        System.debug('Content Versions ' + contentVersions);
        
        ContentVersion v = contentVersions[0];
        
        LLC_BI__Document_Version__c docVersion = createDocumentVersion(
    		loanDocument.Id,
    		documentStoreId,
    		v.Id,
    		'text/plain',
    		'txt',
    		'sampletitle'
    	);
    	
    	
    	ContentVersion version = getContentVersionById(v.Id);

		ContentDocumentLink contentDocLink = createContentDocumentLink(
			documentStoreId,
			version.ContentDocumentId
		);

        
        Set<Id> newset = new Set<Id>();
        newset.add(contentDocLink.Id);
        System.debug('Content version links ' + [SELECT Id, ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId IN :newset]);
        // System.debug('Content version links by Content Document Id ' + [SELECT Id, ContentDocumentId FROM ContentDocumentLink where ContentDocumentId = :v.Id]);
        // System.debug('Content version links by Content Document Id ' + [SELECT Id, ContentDocumentId FROM ContentDocumentLink where ContentDocumentId = :v.Id]);
        
        ApexPages.currentPage().getParameters().put('placeholderKey', loanDocument.Id);
        ApexPages.currentPage().getParameters().put('location', 'loan');
        ExperianXmlPdfController.forceZeroDocumentStores = true;
        
        
        try{
            ExperianXmlPdfController controller = new ExperianXmlPdfController();
            System.assertEquals(true,controller.XMLInjectedSample.toLowerCase().contains('test blob'));
        }catch(ExperianXmlPdfController.XExperianXmlPdfControllerContentVersionIdNotFoundException e){
            System.assertEquals(true,e.getMessage().toLowerCase().contains('more than one record returned for llc_bi__document_store__c'));
        }
    }
    //TODO: complete
    @isTest
    private static void testgetContentVersionIdFromPlaceholderKey_ContentVersionMissing(){
        Test.testInstall(new nDOC.DocManDataInstaller(), null);
        
        Account account = createAccount('Test');
        LLC_BI__Loan__c loan = createLoan('Test',account.Id);
        LLC_BI__DocManager__c docManager = createDocManager('LLC_BI__Loan__c');
        LLC_BI__docType__c docType = createDocType();
        Id documentStoreId = createDocumentStore();
        LLC_BI__Document_Store_Index__c index = createDocumentStoreIndex(documentStoreId);
        
//         LLC_BI__AccountDocument__c accountDocument = createAccountDocument('Test Placeholder',
// 			account.Id,
// 			'2015',
// 			'In-File',
// 			index.Id,
// 			docType.id,
// 			docManager.Id);
			
		LLC_BI__LLC_LoanDocument__c loanDocument = createLLcLoanDocument(
			'testDoc1',
			loan.id,
			'1812',
			'In File',
			index.id,
			docType.id,
			docManager.Id
		);
        
        List<ContentVersion> contentVersions = createContentVersions(1);
        System.debug('Content Versions ' + contentVersions);
        
        ContentVersion v = contentVersions[0];
        
        LLC_BI__Document_Version__c docVersion = createDocumentVersion(
    		loanDocument.Id,
    		documentStoreId,
    		v.Id,
    		'text/plain',
    		'txt',
    		'sampletitle'
    	);
    	
    	
    	ContentVersion version = getContentVersionById(v.Id);

		ContentDocumentLink contentDocLink = createContentDocumentLink(
			documentStoreId,
			version.ContentDocumentId
		);

        
        Set<Id> newset = new Set<Id>();
        newset.add(contentDocLink.Id);
        System.debug('Content version links ' + [SELECT Id, ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId IN :newset]);
        // System.debug('Content version links by Content Document Id ' + [SELECT Id, ContentDocumentId FROM ContentDocumentLink where ContentDocumentId = :v.Id]);
        // System.debug('Content version links by Content Document Id ' + [SELECT Id, ContentDocumentId FROM ContentDocumentLink where ContentDocumentId = :v.Id]);
        
        ApexPages.currentPage().getParameters().put('placeholderKey', loanDocument.Id);
        ApexPages.currentPage().getParameters().put('location', 'loan');
        ExperianXmlPdfController.forceZeroContentVersions = true;
        
        
        try{
            ExperianXmlPdfController controller = new ExperianXmlPdfController();
            System.assertEquals(true,controller.XMLInjectedSample.toLowerCase().contains('test blob'));
        }catch(ExperianXmlPdfController.XExperianXmlPdfControllerContentVersionIdNotFoundException e){
            System.assertEquals(true,e.getMessage().toLowerCase().contains('more than one record returned for contentversion'));
        }
    }
}