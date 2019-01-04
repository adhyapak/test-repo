/**
  * Test class for ScheduleBatchSetExcludeFromExposureCalc
  * Also tests BatchSetExcludeFromExposureCalc
  *
  * @author  Chintan Adhyapak, West Monroe Partners
  * @created 01/03/2018
  */
@isTest
private class SchBatchSetExcludeFromExposureCalc_Test {
	/** Test the Scheduled Apex Class */
	@isTest 
	static void test_ScheduledApex() {
        Test.startTest();
        	ScheduleBatchSetExcludeFromExposureCalc schedApex = new ScheduleBatchSetExcludeFromExposureCalc();
        	String schedule = '0 0 23 * * ?';
        	System.Schedule('Test Batch', schedule, schedApex); 
        Test.stopTest();
	} //test_ScheduledApex
	
	
	/* Test the Batch Class */
	//@isTest(SeeAllData=true)
	@isTest
	static void test_SetExcludeFromExposure() {
		//local vars
		String recordTypeH = null;
		String recordTypeB = null;
		
		//Get RecordTypes for the Account object
		List<RecordType> recordTypeList = [SELECT Id, Name, sObjectType FROM RecordType Where sObjectType ='Account'];
		
		//Save the Household and Business Record Type Ids
		for (RecordType recordType : recordTypeList) {
			if (recordType.Name == 'Household') recordTypeH = recordType.Id;
			else if (recordType.Name == 'Business') recordTypeB = recordType.Id;
		}
		
		//Assert
		System.debug('CPA Household Record Type Id is: ' + recordTypeH);
		System.debug('CPA Business Record Type Id is: ' + recordTypeB);
		System.assertNotEquals(null, recordTypeH);
		System.assertNotEquals(null, recordTypeB);
		
		//Create a Household and Two Business Account Records
		Account householdAccount = new Account();
		householdAccount.Name = 'Apex Household';
		householdAccount.LLC_BI__Proposed_Direct_Exposure__c = 500000.0; 
		householdAccount.recordTypeId = recordTypeH;
		
		Account businessAccountA = new Account();
		businessAccountA.Name = 'Apex Business Account A';
		businessAccountA.recordTypeId = recordTypeB;
		
		Account businessAccountB = new Account();
		businessAccountB.Name = 'Apex Business Account B';
		businessAccountB.recordTypeId = recordTypeB;
		
		//Add to a list
		List<Account> accountList = new List<Account>();
		accountList.add(householdAccount);
		accountList.add(businessAccountA);
		accountList.add(businessAccountB);
		
		//insert the accounts
		insert accountList;
		
		//Assert
		System.assertNotEquals(null, householdAccount.Id);
		System.debug('CPA Test Household Account Id is: ' + householdAccount.Id);
		System.assertNotEquals(null, businessAccountA.Id);
		System.debug('CPA Test Household Member Account A Id is: ' + businessAccountA.Id);
		System.assertNotEquals(null, businessAccountB.Id);
		System.debug('CPA Test Household Member Account B Id is: ' + businessAccountB.Id);
		
		//Create a Product Line
		LLC_BI__Product_Line__c productLineA = new LLC_BI__Product_Line__c();
		productLineA.Name = 'Apex Product Line';
		productLineA.LLC_BI__Category__c = 'Consumer';
		productLineA.LLC_BI__Product_Object__c = 'Loan__c';
		insert productLineA;
		
		//Assert
		System.assertNotEquals(null, productLineA.Id);
		
		//Create a Product Type
		LLC_BI__Product_Type__c productTypeA = new LLC_BI__Product_Type__c();
		productTypeA.Name = 'Apex Product Type';
		productTypeA.LLC_BI__Product_Line__c = productLineA.Id;
		productTypeA.LLC_BI__Category__c = 'Checking';
		insert productTypeA;
		
		//Assert
		System.assertNotEquals(null, productTypeA.Id);
		
		//Create 2 products, one with the exclude from exposure flag set to true
		LLC_BI__Product__c productA = new LLC_BI__Product__c();
		productA.Name = 'Product A';
		productA.Exclude_from_exposure__c = true;
		productA.LLC_BI__Product_Type__c = productTypeA.Id;
		
		LLC_BI__Product__c productB = new LLC_BI__Product__c();
		productB.Name = 'Product B';
		productB.Exclude_from_exposure__c = false;
		productB.LLC_BI__Product_Type__c = productTypeA.Id;
		
		//Add to a list
		List<LLC_BI__Product__c> productList = new List<LLC_BI__Product__c>();
		productList.add(productA);
		productList.add(productB);
		
		//insert the products
		insert productList;
		
		//Assert
		System.assertNotEquals(null, productA.Id);
		System.assertNotEquals(null, productB.Id);
		
		//Create two loans, each with one of the products created above
		LLC_BI__Loan__c loanA = new LLC_BI__Loan__c();
		loanA.LLC_BI__Product_Reference__c = productA.Id;
		loanA.LLC_BI__Principal_Balance__c = 100000.0;
		
		LLC_BI__Loan__c loanB = new LLC_BI__Loan__c();
		loanB.LLC_BI__Product_Reference__c = productB.Id;
		loanB.LLC_BI__Principal_Balance__c = 200000.0;
		
		//Add to a list
		List<LLC_BI__Loan__c> loanList = new List<LLC_BI__Loan__c>();
		loanList.add(loanA);
		loanList.add(loanB);
		
		//insert the loans
		insert loanList;
		
		//Assert
		System.assertNotEquals(null, loanA.Id);
		System.assertNotEquals(null, loanB.Id);
		
		//Create Entity Involvement Records tying the loans to the business accounts
		LLC_BI__Legal_Entities__c eiA = new LLC_BI__Legal_Entities__c();
		eiA.LLC_BI__Account__c = businessAccountA.Id;
		eiA.LLC_BI__Loan__c = loanA.Id;
		
		LLC_BI__Legal_Entities__c eiB = new LLC_BI__Legal_Entities__c();
		eiB.LLC_BI__Account__c = businessAccountB.Id;
		eiB.LLC_BI__Loan__c = loanB.Id;
		
		//Add to a list
		List<LLC_BI__Legal_Entities__c> eiList = new List<LLC_BI__Legal_Entities__c>();
		eiList.add(eiA);
		eiList.add(eiB);
		
		//Insert the Entity Involvement records
		insert eiList;
		
		//Assert
		System.assertNotEquals(null, eiA.Id);
		System.assertNotEquals(null, eiB.Id);
		
		//Create a Connection Role record
		LLC_BI__Connection_Role__c role = new LLC_BI__Connection_Role__c();
		role.Name = 'Household Member';
		role.LLC_BI__Sort_Order__c = 1;
		insert role;
		
		//Assert
		System.assertNotEquals(null, role.Id);
		
		//Create two Connection Records tying the Business accounts to the Household account
		LLC_BI__Connection__c connectionA = new LLC_BI__Connection__c();
		connectionA.LLC_BI__Connected_From__c =  householdAccount.Id;
		connectionA.LLC_BI__Connected_To__c = businessAccountA.Id;
		connectionA.LLC_BI__Connection_Role__c = role.Id;
		
		LLC_BI__Connection__c connectionB = new LLC_BI__Connection__c();
		connectionB.LLC_BI__Connected_From__c =  householdAccount.Id;
		connectionB.LLC_BI__Connected_To__c = businessAccountB.Id;
		connectionB.LLC_BI__Connection_Role__c = role.Id;
		
		//Add to a list
		List<LLC_BI__Connection__c> connectionList = new List<LLC_BI__Connection__c>();
		connectionList.add(connectionA);
		connectionList.add(connectionB);
		
		//Insert
		insert connectionList;
		
		//Assert
		System.assertNotEquals(null, connectionA.Id);
		System.assertNotEquals(null, connectionB.Id);
		
		//Now that the data is all set up, run the batch
		Test.startTest();
        	BatchSetExcludeFromExposureCalc batchJob = new BatchSetExcludeFromExposureCalc();
        	Database.executeBatch(batchJob);
        Test.stopTest();
        
        //Pull Household Account
        householdAccount = [Select Id, Name, Excluded_Exposure__c From Account Where Id = :householdAccount.Id];
        System.debug('CPA Household Record Retrieved is: ' + houseHoldAccount);
        
        //Assert
        System.assertEquals(householdAccount.Excluded_Exposure__c, loanA.LLC_BI__Principal_Balance__c);
	} //test_SetExcludeFromExposure
}