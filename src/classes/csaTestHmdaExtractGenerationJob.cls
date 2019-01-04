@isTest(isParallel=true)
private with sharing class csaTestHmdaExtractGenerationJob {
/*
    @isTest
    static void runJob() {
        Date startDate = Date.today() - 1;
        Date endDate = Date.today() + 1;

        Account testApplicantAccount = nCSA_FRAME.csaTestDataFactory.createAccount(INDIVIDUAL);
        Account testCoApplicantAccount = nCSA_FRAME.csaTestDataFactory.createAccount(INDIVIDUAL);
        
        //Added to satisfy a validation rule on EI. Chintan Adhyapak, West Monroe Partners, August 07, 2018
        testApplicantAccount.LLC_BI__Status__c = 'Participation Relationship';
        testCoApplicantAccount.LLC_BI__Status__c = 'Participation Relationship';
        List<Account> accountList = new List<Account> ();
       	accountList.add(testApplicantAccount);
        accountList.add(testCoApplicantAccount);
        update accountList;
        //End Change
        
        
        LLC_BI__Loan__c testLoan = nCSA_FRAME.csaTestDataFactory.createLoanWithFields(
            testApplicantAccount.Id, null, null, loanFields()
        );
        LLC_BI__Legal_Entities__c testLegalEntity1 = nCSA_FRAME.csaTestDataFactory.createLegalEntityWithFields(
            testApplicantAccount.Id, testLoan.Id, null, BORROWER, legalEntityFields(APPLICANT)
        );
        LLC_BI__Legal_Entities__c testLegalEntity2 = nCSA_FRAME.csaTestDataFactory.createLegalEntityWithFields(
            testCoApplicantAccount.Id, testLoan.Id, null, GUARANTOR, legalEntityFields(COAPPLICANT)
        );
        LLC_BI__Loan_Compliance__c testLoanCompliance = nCSA_FRAME.csaTestDataFactory.createLoanCompliance(
            testLoan.Id, loanComplianceFields()
        );
        LLC_BI__Entity_Compliance__c testEntityCompliance1 = nCSA_FRAME.csaTestDataFactory.createEntityCompliance(
            testLegalEntity1.Id, entityComplianceFields(APPLICANT)
        );
        LLC_BI__Entity_Compliance__c testEntityCompliance2 = nCSA_FRAME.csaTestDataFactory.createEntityCompliance(
            testLegalEntity2.Id, entityComplianceFields(COAPPLICANT)
        );
        LLC_BI__Entity_Compliance__c testEntityCompliance3 = nCSA_FRAME.csaTestDataFactory.createEntityCompliance(
            testLegalEntity2.Id, entityComplianceFields(COAPPLICANT)
        );

        Test.startTest();

        LLC_BI.HmdaDataProvider provider = new LLC_BI.HmdaDataProvider();
        provider.run(false);
        new LLC_BI.LifeCycleDao(provider).performAllDml();

        Id jobId = System.enqueueJob(new csaHmdaExtractGenerationJob(
            UserInfo.getUserEmail(), UserInfo.getName(), startDate, endDate
        ));

        Test.stopTest();
    }

    private static Map<String, Object> entityComplianceFields(String appType) {
        Map<String, Object> toReturn = new Map<String, Object>();
        toReturn.put('LLC_BI__Age__c', 55);
		toReturn.put('LLC_BI__HMDA_Applicant_Type__c', appType);
		toReturn.put('LLC_BI__HMDA_Credit_Score__c', 44.00);
		toReturn.put('LLC_BI__HMDA_Credit_Scoring_Model__c', 'Test');
		toReturn.put('LLC_BI__HMDA_Credit_Scoring_Model_Other__c', 'Test');
		toReturn.put('LLC_BI__HMDA_Ethnicity__c', '2');
		toReturn.put('LLC_BI__HMDA_Ethnicity_Collection_Method__c', '2');
		toReturn.put('LLC_BI__HMDA_Ethnicity_Other__c', 'Other');
		toReturn.put('LLC_BI__HMDA_Income__c', '1000');
		toReturn.put('LLC_BI__HMDA_Not_Provided__c', false);
		toReturn.put('LLC_BI__HMDA_Race__c', '2');
		toReturn.put('LLC_BI__HMDA_Race_Collected__c', '2');
		toReturn.put('LLC_BI__HMDA_Race_Desc_Code_1__c', '4');
		toReturn.put('LLC_BI__HMDA_Race_Desc_Code_27__c', '4');
		toReturn.put('LLC_BI__HMDA_Race_Desc_Code_44__c', '4');
		toReturn.put('LLC_BI__HMDA_Sex__c', '3');
		toReturn.put('LLC_BI__HMDA_Sex_Collection_Method__c', '2');

        return toReturn;
    }

    private static Map<String, Object> loanComplianceFields() {
        Map<String, Object> toReturn = new Map<String, Object>();
        toReturn.put('LLC_BI__Date_Action_Taken__c', Date.today());
		toReturn.put('LLC_BI__Date_Application_Received__c', Date.today());
		toReturn.put('LLC_BI__Date_Rate_Set__c', Date.today());
		toReturn.put('LLC_BI__HMDA_Action_Taken__c', '2');
		toReturn.put('LLC_BI__HMDA_Amount__c', 500);
		toReturn.put('LLC_BI__HMDA_AUS__c', 'Aus');
		toReturn.put('LLC_BI__HMDA_AUS_Other_Result_Text__c', 'Aus');
		toReturn.put('LLC_BI__HMDA_AUS_Other_System_Text__c', 'Aus');
		toReturn.put('LLC_BI__HMDA_AUS_Result__c', '5');
		toReturn.put('LLC_BI__HMDA_Balloon_Payment__c', '2');
		toReturn.put('LLC_BI__HMDA_Business_Or_Commercial_Purpose__c', '1');
		toReturn.put('LLC_BI__HMDA_Co_Applicant__c', true);
		toReturn.put('LLC_BI__HMDA_Combined_LTV__c', '4');
		toReturn.put('LLC_BI__HMDA_Debt_To_Income_Ratio__c', '4');
		toReturn.put('LLC_BI__HMDA_Denial_Reason_Text__c', 'Denail Reason');
		toReturn.put('LLC_BI__HMDA_Denial_Reasons__c', '3;4');
		toReturn.put('LLC_BI__HMDA_Discount_Points__c', '4');
		toReturn.put('LLC_BI__HMDA_HOEPA_Status__c', '2');
		toReturn.put('LLC_BI__HMDA_Initially_Payable_To__c', '2');
		toReturn.put('LLC_BI__HMDA_Interest_Only_Payments__c', '2');
		toReturn.put('LLC_BI__HMDA_Legal_Entity_Identifier__c', '4');
		toReturn.put('LLC_BI__HMDA_Lender_Credits__c', '4');
		toReturn.put('LLC_BI__HMDA_Lien_Status__c', '3');
		toReturn.put('LLC_BI__HMDA_Loan_Purpose__c', '2');
		toReturn.put('LLC_BI__HMDA_Loan_Type__c', '1');
		toReturn.put('LLC_BI__HMDA_Negative_Amortization__c', '2');
		toReturn.put('LLC_BI__HMDA_Open_End_Line_Of_Credit__c', '1');
		toReturn.put('LLC_BI__HMDA_Origination_Charges__c', '4');
		toReturn.put('LLC_BI__HMDA_Other_Non_Amortizing_Features__c', '2');
		toReturn.put('LLC_BI__HMDA_Preapproval_Requested__c', '2');
		toReturn.put('LLC_BI__HMDA_Property_Securing_Address__c', '2345');
		toReturn.put('LLC_BI__HMDA_Property_Securing_Affordable_Units__c', '2345');
		toReturn.put('LLC_BI__HMDA_Property_Securing_Census_Tract__c', 'track');
		toReturn.put('LLC_BI__HMDA_Property_Securing_City__c', 'city');
		toReturn.put('LLC_BI__HMDA_Property_Securing_Construct_Method__c', '2');
		toReturn.put('LLC_BI__HMDA_Property_Securing_FIPS_County_Code__c', 'fips');
		toReturn.put('LLC_BI__HMDA_Property_Securing_Manufactured_Type__c', '1');
		toReturn.put('LLC_BI__HMDA_Property_Securing_Mfd_Home_Int__c', '2');
		toReturn.put('LLC_BI__HMDA_Property_Securing_MSA_MD_Number__c', 'msa');
		toReturn.put('LLC_BI__HMDA_Property_Securing_Occupancy__c', '1');
		toReturn.put('LLC_BI__HMDA_Property_Securing_Occupancy_Type__c', '2');
		toReturn.put('LLC_BI__HMDA_Property_Securing_Property_Type__c', '2');
		toReturn.put('LLC_BI__HMDA_Property_Securing_Property_Value__c', '2345');
		toReturn.put('LLC_BI__HMDA_Property_Securing_State__c', 'NC');
		toReturn.put('LLC_BI__HMDA_Property_Securing_Total_Units__c', 10);
		toReturn.put('LLC_BI__HMDA_Property_Securing_Zip__c','28405');
		toReturn.put('LLC_BI__HMDA_Purchaser_Type__c', '1');
		toReturn.put('LLC_BI__HMDA_Reverse_Mortgage__c', '2');
		toReturn.put('LLC_BI__HMDA_Submission_Of_Application__c', '2');
		toReturn.put('LLC_BI__HMDA_Total_Loan_Costs__c', '444');
		toReturn.put('LLC_BI__HMDA_Total_Points_Fees__c', '3');
		toReturn.put('LLC_BI__HMDA_Universal_Loan_Identifier__c', 'ULIID');
		toReturn.put('LLC_BI__Interest_Rate__c','4');
		toReturn.put('LLC_BI__Introductory_Rate_Period__c','4');
		toReturn.put('LLC_BI__Loan_Term__c', '5');
		toReturn.put('LLC_BI__Mortgage_LO_NMLSR_Id__c', '1234');
		toReturn.put('LLC_BI__Prepayment_Penalty_Term__c', '5');
		toReturn.put('LLC_BI__Rate_Spread__c', '11.333');

        return toReturn;
    }

    private static Map<String, Object> legalEntityFields(String appType) {
        Map<String, Object> toReturn = new Map<String, Object>();
		toReturn.put('LLC_BI__Borrower_Type__c', 'Guarantor');
		toReturn.put('LLC_BI__Contingent_Amount__c', 50);
		toReturn.put('LLC_BI__Contingent_Type__c', 'Joint & Several');
		toReturn.put('LLC_BI__HMDA_Applicant_Type__c', appType);
		toReturn.put('LLC_BI__HMDA_Ethnicity__c', 'Code 1—Hispanic or Latino');
		toReturn.put('LLC_BI__HMDA_Income__c', 100);
		toReturn.put('LLC_BI__HMDA_Not_Provided__c', false);
		toReturn.put('LLC_BI__HMDA_Race__c', 'Code 1—American Indian or Alaska Native');
		toReturn.put('LLC_BI__HMDA_Sex__c', 'Code 1—Male');

        return toReturn;
    }

    private static Map<String, Object> loanFields() {
        Map<String, Object> toReturn = new Map<String, Object>();
        toReturn.put('LLC_BI__HMDA_Action_Taken__c', 'Code 1—Loan originated');
		toReturn.put('LLC_BI__HMDA_Amount__c', 500);
		toReturn.put('LLC_BI__HMDA_Census_Tract__c', 444);
		toReturn.put('LLC_BI__HMDA_Census_Tract_Text__c', 'Tract');
		toReturn.put('LLC_BI__Booked_Date__c', Date.today());
		toReturn.put('LLC_BI__HMDA_Co_Applicant__c', true);
		toReturn.put('LLC_BI__HMDA_Date_Action_Taken__c', Date.today());
		toReturn.put('LLC_BI__HMDA_Date_Application_Received__c', Date.today());
		toReturn.put('LLC_BI__HMDA_Date_Rate_Set__c', Date.today());
		toReturn.put('LLC_BI__HMDA_Denial_Reasons__c', 'Code 2—Employment history');
		toReturn.put('LLC_BI__HMDA_FIPS_County_Code__c', 123);
		toReturn.put('LLC_BI__HMDA_FIPS_County_Code_Text__c', 'USA');
		toReturn.put('LLC_BI__HMDA_FIPS_State_Code__c', 22);
		toReturn.put('LLC_BI__HMDA_FIPS_State_Code_Text__c', 'CA');
		toReturn.put('LLC_BI__HMDA_HOEPA_Status__c', 'Code 1 - For a loan that you originated or purchased that is subject to the Home Ownership and Equity Protection Act of 1994 (HOEPA), because the APR or the points and fees on the loan exceed the HOEPA triggers');
		toReturn.put('LLC_BI__HMDA_Lien_Status__c', 'Code 1—Secured by a first lien.');
		toReturn.put('LLC_BI__HMDA_MSA_MD_Number__c', 1234);
		toReturn.put('LLC_BI__HMDA_MSA_MD_Number_Text__c', '44523');
		toReturn.put('LLC_BI__HMDA_Occupancy__c', 'Code 1—Owner-occupied as a principal dwelling');
		toReturn.put('LLC_BI__HMDA_Preapproval_Requested__c', 'Code 1—Preapproval requested');
		toReturn.put('LLC_BI__HMDA_Property_Type__c', 'Code 2—Manufactured housing');
		toReturn.put('LLC_BI__HMDA_Purchaser_Type__c', 'Code 1—Fannie Mae (FNMA)');
		toReturn.put('LLC_BI__HMDA_Purpose__c', 'Code 2—Home improvement');
		toReturn.put('LLC_BI__HMDA_Rate_Spread__c', 5.55);
		toReturn.put('LLC_BI__HMDA_Record_Type__c', 'HMDA-Effective-2018');
		toReturn.put('LLC_BI__HMDA_Reportable__c', true);
		toReturn.put('LLC_BI__HMDA_Type__c', 'Code 2—FHA-insured (Federal Housing Administration)');

        return toReturn;
    }

    private static final String INDIVIDUAL = 'Individual';
    private static final String BORROWER = 'Borrower';
    private static final String GUARANTOR = 'Guarantor';
    private static final String APPLICANT = 'Applicant';
    private static final String COAPPLICANT = 'Co-Applicant';
*/    
}