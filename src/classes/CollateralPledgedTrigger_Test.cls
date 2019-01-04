/**
 * This class tests the trigger on the Collateral Pledged, LLC_BI__Loan_Collateral2__c object
 * Chintan Adhyapak, West Monroe Partners. January 22, 2018
 */
@isTest
private class CollateralPledgedTrigger_Test {
	
	//Create test data for the class
	@testSetup static void setupData() {
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
		
		//Create a product
		LLC_BI__Product__c productA = new LLC_BI__Product__c();
		productA.Name = 'Product A';
		productA.LLC_BI__Product_Type__c = productTypeA.Id;
		insert productA;
		
		//Assert
		System.assertNotEquals(null, productA.Id);
		
		//Create two loans
		LLC_BI__Loan__c loanA = new LLC_BI__Loan__c();
		loanA.LLC_BI__Product_Reference__c = productA.Id;
		loanA.LLC_BI__Principal_Balance__c = 100000.0;
		
		LLC_BI__Loan__c loanB = new LLC_BI__Loan__c();
		loanB.LLC_BI__Product_Reference__c = productA.Id;
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
    } //setupData
	
	
	
	/* Test the before insert and after update triggers */
    static testMethod void runTests() {
    	
    	//Retrieve test data
    	List<LLC_BI__Collateral__c> collateralList = [Select Id From LLC_BI__Collateral__c];
    	List<LLC_BI__Loan__c> loanList = [Select Id From LLC_BI__Loan__c];
    	LLC_BI__Loan_Collateral_Aggregate__c aggregate = [Select Id From LLC_BI__Loan_Collateral_Aggregate__c Limit 1][0];
    	
    	//Assert
    	System.assertEquals(4, collateralList.size());
    	System.assertEquals(2, loanList.size());
    	System.assertNotEquals(null, aggregate.Id);
    	
    	//Create 2 Pledged Collateral
    	LLC_BI__Loan_Collateral2__c pledgedCollateralA = new LLC_BI__Loan_Collateral2__c ();
    	pledgedCollateralA.LLC_BI__Collateral__c = collateralList[0].Id;
    	pledgedCollateralA.LLC_BI__Loan__c = loanList[0].Id;
    	pledgedCollateralA.LLC_BI__Loan_Collateral_Aggregate__c = aggregate.Id;
    	pledgedCollateralA.LLC_BI__Amount_Pledged__c = 400;
    	pledgedCollateralA.Account__c = 'PC_A';
    	
    	LLC_BI__Loan_Collateral2__c pledgedCollateralB = new LLC_BI__Loan_Collateral2__c ();
    	pledgedCollateralB.LLC_BI__Collateral__c = collateralList[1].Id;
    	pledgedCollateralB.LLC_BI__Loan__c = loanList[0].Id;
    	pledgedCollateralB.LLC_BI__Loan_Collateral_Aggregate__c = aggregate.Id;
    	pledgedCollateralB.LLC_BI__Amount_Pledged__c = 200;
    	pledgedCollateralB.Account__c = 'PC_B';
    	
    	List<LLC_BI__Loan_Collateral2__c> pledgedCollateralList = new List<LLC_BI__Loan_Collateral2__c> ();
    	pledgedCollateralList.add(pledgedCollateralA);
    	pledgedCollateralList.add(pledgedCollateralB);
    	insert pledgedCollateralList;
    	
    	//Assert
    	System.assertNotEquals(null, pledgedCollateralA.Id);
    	System.assertNotEquals(null, pledgedCollateralB.Id);
    	
    	test.startTest();
    		//Retrieve
    		Map<Id, LLC_BI__Loan_Collateral2__c>pledgedCollateralMap = new Map<Id, LLC_BI__Loan_Collateral2__c> ([Select Id, LLC_BI__Is_Primary__c From LLC_BI__Loan_Collateral2__c]);
    		
    		//Assert that B is marked primary and A is not
    		System.assertEquals(true, pledgedCollateralMap.get(pledgedCollateralA.Id).LLC_BI__Is_Primary__c);
    		System.assertEquals(false, pledgedCollateralMap.get(pledgedCollateralB.Id).LLC_BI__Is_Primary__c);
    		
    		//Add 2 more pledged collateral records to the same loan
    		LLC_BI__Loan_Collateral2__c pledgedCollateralC = new LLC_BI__Loan_Collateral2__c ();
    		pledgedCollateralC.LLC_BI__Collateral__c = collateralList[2].Id;
    		pledgedCollateralC.LLC_BI__Loan__c = loanList[0].Id;
    		pledgedCollateralC.LLC_BI__Loan_Collateral_Aggregate__c = aggregate.Id;
    		pledgedCollateralC.LLC_BI__Amount_Pledged__c = 300;
    		pledgedCollateralC.Account__c = 'PC_C';
    		
    		LLC_BI__Loan_Collateral2__c pledgedCollateralD = new LLC_BI__Loan_Collateral2__c ();
    		pledgedCollateralD.LLC_BI__Collateral__c = collateralList[3].Id;
    		pledgedCollateralD.LLC_BI__Loan__c = loanList[0].Id;
    		pledgedCollateralD.LLC_BI__Loan_Collateral_Aggregate__c = aggregate.Id;
    		pledgedCollateralD.LLC_BI__Amount_Pledged__c = 100;
    		pledgedCollateralD.Account__c = 'PC_D';
    		
    		pledgedCollateralList = new List<LLC_BI__Loan_Collateral2__c> ();
    		pledgedCollateralList.add(pledgedCollateralC);
    		pledgedCollateralList.add(pledgedCollateralD);
    		insert pledgedCollateralList;
    	
    		//Assert
    		System.assertNotEquals(null, pledgedCollateralC.Id);
    		System.assertNotEquals(null, pledgedCollateralD.Id);
    		
    		//Retrieve
    		pledgedCollateralMap = new Map<Id, LLC_BI__Loan_Collateral2__c> ([Select Id, LLC_BI__Is_Primary__c From LLC_BI__Loan_Collateral2__c]);
    		
    		//Assert that the Primary flag is not set this time
    		System.assertEquals(true, pledgedCollateralMap.get(pledgedCollateralA.Id).LLC_BI__Is_Primary__c);
    		System.assertEquals(false, pledgedCollateralMap.get(pledgedCollateralB.Id).LLC_BI__Is_Primary__c);
    		System.assertEquals(false, pledgedCollateralMap.get(pledgedCollateralC.Id).LLC_BI__Is_Primary__c);
    		System.assertEquals(false, pledgedCollateralMap.get(pledgedCollateralD.Id).LLC_BI__Is_Primary__c);

			//Delete the Primary collateral
			delete pledgedCollateralA;
		test.stopTest();

		//Retrieve
   		pledgedCollateralMap = new Map<Id, LLC_BI__Loan_Collateral2__c> ([Select Id, LLC_BI__Is_Primary__c From LLC_BI__Loan_Collateral2__c]);
    		
   		//Assert that the Primary flag is now set on C
   		System.assertEquals(false, pledgedCollateralMap.get(pledgedCollateralB.Id).LLC_BI__Is_Primary__c);
   		System.assertEquals(true, pledgedCollateralMap.get(pledgedCollateralC.Id).LLC_BI__Is_Primary__c);
   		System.assertEquals(false, pledgedCollateralMap.get(pledgedCollateralD.Id).LLC_BI__Is_Primary__c);
    } //runTests
}