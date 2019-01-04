public with sharing class csaHmdaExtractGenerationJob implements Queueable {
    private class HmdaExtractException extends Exception {}
    private Date startDate;
    private Date endDate;
    private String email;
    private String name;
    private String customFieldName;
    private LLC_BI.SystemProperties properties;
    private nFORCE.SystemProperties nProperties;

    public csaHmdaExtractGenerationJob(String email, String name, Date startDate, Date endDate) {
        this.properties = LLC_BI.SystemProperties.getInstance();
        this.nProperties = nFORCE.SystemProperties.getInstance();
        this.startDate = startDate;
        this.endDate = endDate;
        this.name = name;
        this.email = this.nProperties.getProperty(
            csaHmdaExtractConstants.PROERPTY_CATEGORY,
            csaHmdaExtractConstants.PROPERTY_EMAILKEY,
            email
        );
        this.customFieldName = this.nProperties.getProperty(
            csaHmdaExtractConstants.PROERPTY_CATEGORY,
            csaHmdaExtractConstants.PROPERTY_CUSTOMFIELDKEY,
            csaHmdaExtractConstants.PROPERTY_CUSTOMERFIELDVALUE
        );
    }

    public void execute(QueueableContext context) {
        Map<Id, LLC_BI__Loan__c> loans = loanQuery(this.startDate, this.endDate, this.customFieldName);
        Map<Id, LLC_BI__Legal_Entities__c> legalEntities = legalEntitiesQuery(loans.keySet());
        Map<Id, List<LLC_BI__Legal_Entities__c>> loanLegalEntities = new Map<Id, List<LLC_BI__Legal_Entities__c>>();

        for(LLC_BI__Legal_Entities__c le: legalEntities.values()) {
            if(loanLegalEntities.containsKey(le.LLC_BI__Loan__c)) {
                List<LLC_BI__Legal_Entities__c> records = loanLegalEntities.get(le.LLC_BI__Loan__c);
                records.add(le);
                loanLegalEntities.put(le.LLC_BI__Loan__c, records);
            } else {
                loanLegalEntities.put(le.LLC_BI__Loan__c, new List<LLC_BI__Legal_Entities__c> { le });
            }
        }

        String csv = nCSA_FRAME.csaConstants.BLANK;
        csv += tableOneGeneration(legalEntities.size(), this.properties);
        csv += tableTwoGeneration(loans.keySet(), legalEntities.keySet(), loanLegalEntities, this.properties);
        csv = csv.replace(NULL_VALUE, nCSA_FRAME.csaConstants.BLANK);

        String link = createContentVersion(csv);

        sendEmail(this.email, this.name, link);
    }

    private static String tableOneGeneration(Integer entityCount, LLC_BI.SystemProperties props) {
        String toReturn;

        // Field 1: Record Id# -  entifier
        toReturn = NUMBERONE + PIPE;
        // Field 2: Financial Institution Name
        toReturn += props.getProperty(HMDACATEGORY, HMDAKEY_FINALCIALINSTITUTION) + PIPE;
        // Field 3: Calendar Year
        toReturn += Date.Today().year() + PIPE;
        // Field 4: Calendar Quarter
        toReturn += ((Date.Today().month() / 3) + 1) + PIPE;
        // Field 5: Contact Person’s Name
        toReturn += props.getProperty(HMDACATEGORY, HMDAKEY_CONTACTNAME) + PIPE;
        // Field 6: Contact Person’s Telephone Number
        toReturn += props.getProperty(HMDACATEGORY, HMDAKEY_CONTACTPHONENUMBER) + PIPE;
        // Field 7: Contact Person’s E-mail Address
        toReturn += props.getProperty(HMDACATEGORY, HMDAKEY_CONTACTEMAIL) + PIPE;
        // Field 8: Contact Person’s Office Street Address
        toReturn += props.getProperty(HMDACATEGORY, HMDAKEY_CONTACTSTREETADDRESS) + PIPE;
        // Field 9: Contact Person’s Office City
        toReturn += props.getProperty(HMDACATEGORY, HMDAKEY_CONTACTCITY) + PIPE;
        // Field 10: Contact Person’s Office State
        toReturn += props.getProperty(HMDACATEGORY, HMDAKEY_CONTACTSTATE) + PIPE;
        // Field 11: Contact Person’s Office ZIP Code
        toReturn += props.getProperty(HMDACATEGORY, HMDAKEY_CONTACTZIP) + PIPE;
        // Field 12: Federal Agency
        toReturn += props.getProperty(HMDACATEGORY, HMDAKEY_FEDAGENCY) + PIPE;
        // Field 13: Total Number of Entries Contained in Submission
        toReturn += entityCount + PIPE;
        // Field 14: Federal Taxpayer Identification Number
        toReturn += props.getProperty(HMDACATEGORY, HMDAKEY_FEDTAXID) + PIPE;
        // Field 15: Legal Entity Identifier (LEI)
        toReturn += props.getProperty(HMDACATEGORY, HMDAKEY_LEI)  + NEWLINE;
        // END OF FIRST TABLE ROW

        return toReturn;
    }

    private static String tableTwoGeneration(Set<Id> loanIds, Set<Id> entityIds,
                                             Map<Id, List<LLC_BI__Legal_Entities__c>> loanLegalEntities,
                                             LLC_BI.SystemProperties props) {
        List<LLC_BI__Loan_Compliance__c> lcRecords = loanComplianceRecords(loanIds);
        Map<Id, List<LLC_BI__Entity_Compliance__c>> ecRecords = entityComplianceRecords(entityIds);
        String toReturn = nCSA_FRAME.csaConstants.BLANK;

        //START OF LOAN/APPLICATION REGISTER / TABLE 2
        for (LLC_BI__Loan_Compliance__c lc: lcRecords) {
            // Field 1: Record Identifier
            toReturn += NUMBERTWO + PIPE;
            // Field 2: Legal Entity Identifier (LEI)
            toReturn += props.getProperty(HMDACATEGORY, HMDAKEY_LEI) + PIPE;
            // Field 3: Universal Loan Identifier (ULI)
            toReturn += defaultReturnValue(null, lc.LLC_BI__HMDA_Universal_Loan_Identifier__c, PIPE);
            // Field 4: Application Date
            toReturn += defaultReturnValue(lc.LLC_BI__Date_Application_Received__c, null, NAPIPE);
            // Field 5: Loan Type
            toReturn += lc.LLC_BI__HMDA_Loan_Type__c + PIPE;
            // Field 6: Loan Purpose
            toReturn += defaultReturnValue(null, lc.LLC_BI__HMDA_Loan_Purpose__c, NAPIPE);
            // Field 7: Preapproval
            toReturn += lc.LLC_BI__HMDA_Preapproval_Requested__c + PIPE;
            // Field 8: Construction Method
            toReturn += lc.LLC_BI__HMDA_Property_Securing_Construct_Method__c + PIPE;
            // Field 9: Occupancy Type
            toReturn += lc.LLC_BI__HMDA_Property_Securing_Occupancy_Type__c + PIPE;
            // Field 10: Loan Amount
            toReturn += lc.LLC_BI__HMDA_Amount__c + PIPE;
            // Field 11: Action Taken
            toReturn += defaultReturnValue(null, lc.LLC_BI__HMDA_Action_Taken__c, PIPE);
            // Field 12: Action Taken Date
            toReturn += defaultReturnValue(lc.LLC_BI__Date_Action_Taken__c, null, PIPE);
            // Field 13: Street Address
            toReturn += defaultReturnValue(null, lc.LLC_BI__HMDA_Property_Securing_Address__c, NAPIPE);
            // Field 14: City
            toReturn += defaultReturnValue(null, lc.LLC_BI__HMDA_Property_Securing_City__c, NAPIPE);
            // Field 15: State
            toReturn += defaultReturnValue(null, lc.LLC_BI__HMDA_Property_Securing_State__c, NAPIPE);
            // Field 16: ZIP Code
            toReturn += defaultReturnValue(null, lc.LLC_BI__HMDA_Property_Securing_Zip__c, NAPIPE);
            // Field 17: County
            toReturn += defaultReturnValue(null, lc.LLC_BI__HMDA_Property_Securing_FIPS_County_Code__c, NAPIPE);
            // Field 18: Census Tract
            toReturn += defaultReturnValue(null, lc.LLC_BI__HMDA_Property_Securing_Census_Tract__c, NAPIPE);
            // Field 19 - 23: Ethnicity of Applicant or Borrower
            toReturn += buildEntities(
                loanLegalEntities.get(lc.LLC_BI__Loan__c),
                ecRecords, APPLICANT, HMDAFIELD_ETHNICITY, 5, null
            );
            // Field 24: Ethnicity of Applicant or Borrower: Free Form Text Field for Other Hispanic or Latino
            toReturn += buildEntities(
                loanLegalEntities.get(lc.LLC_BI__Loan__c),
                ecRecords, APPLICANT, HMDAFIELD_ETHNICITYOTHER, 1, null
            );
            // Field 25 - 29: Ethnicity of Co-Applicant or Co-Borrower: 1
            toReturn += buildEntities(
                loanLegalEntities.get(lc.LLC_BI__Loan__c),
                ecRecords, COAPPLICANT, HMDAFIELD_ETHNICITY, 5, 5
            );
            // Field 30: Ethnicity of Applicant or Co-Borrower: Free Form Text Field for Other Hispanic or Latino)
            toReturn += buildEntities(
                loanLegalEntities.get(lc.LLC_BI__Loan__c),
                ecRecords, COAPPLICANT, HMDAFIELD_ETHNICITYOTHER, 1, null
            );
            // Field 31: Ethnicity of Applicant or Borrower Collected on the Basis of Visual Observation or Surname
            toReturn += buildEntities(
                loanLegalEntities.get(lc.LLC_BI__Loan__c),
                ecRecords, APPLICANT, HMDAFIELD_ETHNICITYCOLLECTION, 1, null
            );
            // Field 32: Ethnicity of Co-Applicant or Co-Borrower Collected on the Basis of Visual Observation or Surname
            toReturn += buildEntities(
                loanLegalEntities.get(lc.LLC_BI__Loan__c),
                ecRecords, COAPPLICANT, HMDAFIELD_ETHNICITYCOLLECTION, 1, 4
            );
            // Field 33 - 37: Race of Applicant or Borrower
            toReturn += buildEntities(
                loanLegalEntities.get(lc.LLC_BI__Loan__c),
                ecRecords, APPLICANT, HMDAFIELD_RACE, 5, 8
            );
            // Field 38: Race of Applicant or Borrower: Free Form Text Field for American Indian or Alaska Native Enrolled or Principal Tribe
            toReturn += buildEntities(
                loanLegalEntities.get(lc.LLC_BI__Loan__c),
                ecRecords, APPLICANT, HMDAFIELD_RACEDESC1, 1, null
            );
            // Field 39: Race of Applicant or Borrower: Free Form Text Field for Other Asian
            toReturn += buildEntities(
                loanLegalEntities.get(lc.LLC_BI__Loan__c),
                ecRecords, APPLICANT, HMDAFIELD_RACEDESC27, 1, null
            );
            // Field 40: Race of Applicant or Borrower: Free Form Text Field for Other Pacific Islander
            toReturn += buildEntities(
                loanLegalEntities.get(lc.LLC_BI__Loan__c),
                ecRecords, APPLICANT, HMDAFIELD_RACEDESC44, 1, null
            );
            // Field 41 - 45: Race of Applicant or Borrower
            toReturn += buildEntities(
                loanLegalEntities.get(lc.LLC_BI__Loan__c),
                ecRecords, COAPPLICANT, HMDAFIELD_RACE, 5, 8
            );
            // Field 46: Race of Co-Applicant or Co-Borrower: Free Form Text Field for American Indian or Alaska Native Enrolled or Principal Tribe
            toReturn += buildEntities(
                loanLegalEntities.get(lc.LLC_BI__Loan__c),
                ecRecords, COAPPLICANT, HMDAFIELD_RACEDESC1, 1, null
            );
            // Field 47: Race of Co-Applicant or Co-Borrower: Free Form Text Field for Other Asian
            toReturn += buildEntities(
                loanLegalEntities.get(lc.LLC_BI__Loan__c),
                ecRecords, COAPPLICANT, HMDAFIELD_RACEDESC27, 1, null
            );
            // Field 48: Race of Co-Applicant or Co-Borrower: Free Form Text Field for Other Pacific Islander
            toReturn += buildEntities(
                loanLegalEntities.get(lc.LLC_BI__Loan__c),
                ecRecords, COAPPLICANT, HMDAFIELD_RACEDESC44, 1, null
            );
            // Field 49: Race of Applicant or Borrower Collected on the Basis of Visual Observation or Surname
            toReturn += buildEntities(
                loanLegalEntities.get(lc.LLC_BI__Loan__c),
                ecRecords, APPLICANT, HMDAFIELD_RACECOLLECTION, 1, null
            );
            // Field 50: Race of CoApplicant or Co-Borrower Collected on the Basis of Visual Observation or Surname
            toReturn += buildEntities(
                loanLegalEntities.get(lc.LLC_BI__Loan__c),
                ecRecords, COAPPLICANT, HMDAFIELD_RACECOLLECTION, 1, 4
            );
            // Field 51: Sex of Applicant or Borrower
            toReturn += buildEntities(
                loanLegalEntities.get(lc.LLC_BI__Loan__c),
                ecRecords, APPLICANT, HMDAFIELD_SEX, 1, null
            );
            // Field 52: Sex of Co-Applicant or Co-Borrower
            toReturn += buildEntities(
                loanLegalEntities.get(lc.LLC_BI__Loan__c),
                ecRecords, COAPPLICANT, HMDAFIELD_SEX, 1, 5
            );
            // Field 53: Sex of Applicant or Borrower Collected on the Basis of Visual Observation or Surname
            toReturn += buildEntities(
                loanLegalEntities.get(lc.LLC_BI__Loan__c),
                ecRecords, APPLICANT, HMDAFIELD_SEXCOLLECTION, 1, null
            );
            // Field 54: Sex of Co-Applicant or Co-Borrower Collected on the Basis of Visual Observation or Surname
            toReturn += buildEntities(
                loanLegalEntities.get(lc.LLC_BI__Loan__c),
                ecRecords, COAPPLICANT, HMDAFIELD_SEXCOLLECTION, 1, 4
            );
            // Field 55: Age of Applicant or Borrower
            toReturn += buildEntities(
                loanLegalEntities.get(lc.LLC_BI__Loan__c),
                ecRecords, APPLICANT, HMDAFIELD_AGE, 1, null
            );
            // Field 56: Age of Co-Applicant or Co-Borrower
            toReturn += buildEntities(
                loanLegalEntities.get(lc.LLC_BI__Loan__c),
                ecRecords, COAPPLICANT, HMDAFIELD_AGE, 1, 9999
            );
            // Field 57: Income
            toReturn += buildEntities(
                loanLegalEntities.get(lc.LLC_BI__Loan__c),
                ecRecords, APPLICANT, HMDAFIELD_INCOME, 1, null
            );
            // Field 58: Type of Purchaser
            toReturn += lc.LLC_BI__HMDA_Purchaser_Type__c + PIPE;
            // Field 59: Rate Spread
            toReturn += defaultReturnValue(null, lc.LLC_BI__Rate_Spread__c, NAPIPE);
            // Field 60: HOEPA Status
            toReturn += lc.LLC_BI__HMDA_HOEPA_Status__c + PIPE;
            // Field 61: Lien Status
            toReturn += lc.LLC_BI__HMDA_Lien_Status__c + PIPE;
            // Field 62: Credit Score of Applicant or Borrower
            toReturn += buildEntities(
                loanLegalEntities.get(lc.LLC_BI__Loan__c),
                ecRecords, APPLICANT, HMDAFIELD_CREDITSCORE, 1, 8888
            );
            // Field 63 : Type of Purchaser
            toReturn += buildEntities(
                loanLegalEntities.get(lc.LLC_BI__Loan__c),
                ecRecords, COAPPLICANT, HMDAFIELD_CREDITSCORE, 1, 9999
            );
            // Field 64 : Applicant or Borrower, Name and Version of Credit Scoring Model
            toReturn += buildEntities(
                loanLegalEntities.get(lc.LLC_BI__Loan__c),
                ecRecords, APPLICANT, HMDAFIELD_CREDITSCOREMODEL, 1, 9
            );
            // Field 65 : Applicant or Borrower, Name and Version of Credit Scoring Model: Conditional Free Form Text Field for Code 8
            toReturn += buildEntities(
                loanLegalEntities.get(lc.LLC_BI__Loan__c),
                ecRecords, APPLICANT, HMDAFIELD_CREDITSCOREMODELOTHER, 1, null
            );
            // Field 66 : Co-Applicant or Co-Borrower, Name and Version of Credit Scoring Model
            toReturn += buildEntities(
                loanLegalEntities.get(lc.LLC_BI__Loan__c),
                ecRecords, COAPPLICANT, HMDAFIELD_CREDITSCOREMODEL, 1, 10
            );
            // Field 67: Co-Applicant or Co-Borrower, Name and Version of Credit Scoring Model: Conditional Free Form Text Field for Code 8
            toReturn += buildEntities(
                loanLegalEntities.get(lc.LLC_BI__Loan__c),
                ecRecords, COAPPLICANT, HMDAFIELD_CREDITSCOREMODELOTHER, 1, null
            );
            // Field 68: Reason for Denial: 1
            toReturn += lc.LLC_BI__HMDA_Denial_Reasons__c + PIPE;
            // Field 69: Reason for Denial: 2
            toReturn += PIPE;
            // Field 70: Reason for Denial: 3
            toReturn += PIPE;
            // Field 71: Reason for Denial: 4
            toReturn += PIPE;
            // Field 72: Reason for Denial: Conditional Free Form Text Field for Code 9
            toReturn += lc.LLC_BI__HMDA_Denial_Reason_Text__c + PIPE;
            // Field 73: Total Loan Costs
            toReturn += defaultReturnValue(null, lc.LLC_BI__HMDA_Total_Loan_Costs__c, NAPIPE);
            // Field 74: Total Points and Fees
            toReturn += defaultReturnValue(null, lc.LLC_BI__HMDA_Total_Points_Fees__c, NAPIPE);
            // Field 75: Origination Points
            toReturn += defaultReturnValue(null, lc.LLC_BI__HMDA_Origination_Charges__c, NAPIPE);
            // Field 76: Discount Points
            toReturn += lc.LLC_BI__HMDA_Discount_Points__c + PIPE;
            // Field 77: Lender Credits
            toReturn += lc.LLC_BI__HMDA_Lender_Credits__c + PIPE;
            // Field 78: Interest Rate
            toReturn += defaultReturnValue(null, lc.LLC_BI__Interest_Rate__c, NAPIPE);
            // Field 79: Prepayment Penalty Term
            toReturn += defaultReturnValue(null, lc.LLC_BI__Prepayment_Penalty_Term__c, NAPIPE);
            // Field 80: Debt-to Income Ratio
            toReturn += defaultReturnValue(null, lc.LLC_BI__HMDA_Debt_To_Income_Ratio__c, NAPIPE);
            // Field 81: Combined Loan-to-Value Ratio
            toReturn += lc.LLC_BI__HMDA_Combined_LTV__c + PIPE;
            // Field 82: Loan Term
            toReturn += defaultReturnValue(null, lc.LLC_BI__Loan_Term__c, NAPIPE);
            // Field 83: Introductory Rate Period
            toReturn += defaultReturnValue(null, lc.LLC_BI__Introductory_Rate_Period__c, NAPIPE);
            // Field 84: Balloon Payment
            toReturn += lc.LLC_BI__HMDA_Balloon_Payment__c + PIPE;
            // Field 85: Interest-Only Payments
            toReturn += lc.LLC_BI__HMDA_Interest_Only_Payments__c + PIPE;
            // Field 86: Negative Amortization
            toReturn += lc.LLC_BI__HMDA_Negative_Amortization__c + PIPE;
            // Field 87: Other Non amortizing Features
            toReturn += lc.LLC_BI__HMDA_Other_Non_Amortizing_Features__c + PIPE;
            // Field 88: Property Value
            toReturn += defaultReturnValue(null, lc.LLC_BI__HMDA_Property_Securing_Property_Value__c, NAPIPE);
            // Field 89: Manufactured Home Secured Property Type
            toReturn += lc.LLC_BI__HMDA_Property_Securing_Property_Type__c + PIPE;
            // Field 90: Manufactured Home Land Property Interest
            toReturn += lc.LLC_BI__HMDA_Property_Securing_Mfd_Home_Int__c + PIPE;
            // Field 91: Total Units
            toReturn += lc.LLC_BI__HMDA_Property_Securing_Total_Units__c + PIPE;
            // Field 92: Multifamily Affordable Units
            toReturn += defaultReturnValue(null, lc.LLC_BI__HMDA_Property_Securing_Affordable_Units__c, NAPIPE);
            // Field 93: Submission of Application
            toReturn += lc.LLC_BI__HMDA_Submission_Of_Application__c + PIPE;
            // Field 94: Initially Payable to Your Institution
            toReturn += lc.LLC_BI__HMDA_Initially_Payable_To__c + PIPE;
            // Field 95: Mortgage Loan Originator NMLSR Identifier
            toReturn += defaultReturnValue(null, lc.LLC_BI__Mortgage_LO_NMLSR_Id__c, NAPIPE);
            // Field 96: Automated Underwriting System: 1
            toReturn += lc.LLC_BI__HMDA_AUS__c + PIPE;
            // Field 97: Automated Underwriting System: 2
            toReturn += PIPE;
            // Field 98: Automated Underwriting System: 3
            toReturn += PIPE;
            // Field 99: Automated Underwriting System: 4
            toReturn += PIPE;
            // Field 100: Automated Underwriting System: 5
            toReturn += PIPE;
            // Field 101: Automated Underwriting System: Conditional Free Form Text Field for Code 5
            toReturn += lc.LLC_BI__HMDA_AUS_Other_System_Text__c + PIPE;
            // Field 102: Automated Underwriting System Result: 1
            toReturn += lc.LLC_BI__HMDA_AUS_Other_Result_Text__c + PIPE;
            // Field 103: Automated Underwriting System Result: 2
            toReturn += PIPE;
            // Field 104: Automated Underwriting System Result: 3
            toReturn += PIPE;
            // Field 105: Automated Underwriting System Result: 4
            toReturn += PIPE;
            // Field 106: Automated Underwriting System Result: 5
            toReturn += PIPE;
            // Field 107: Automated Underwriting System Result: Conditional Free Form Text Field for Code 16
            toReturn += PIPE;
            // Field 108: Reverse Mortgage
            toReturn += lc.LLC_BI__HMDA_Reverse_Mortgage__c + PIPE;
            // Field 109: Open-End Line of Credit
            toReturn += lc.LLC_BI__HMDA_Open_End_Line_Of_Credit__c + PIPE;
            // Field 110: Business or Commercial Purpose
            toReturn += lc.LLC_BI__HMDA_Business_Or_Commercial_Purpose__c + NEWLINE;
            //END OF TABLE 2
        }

        return toReturn;
    }

    private static String buildEntities(List<LLC_BI__Legal_Entities__c> entities,
                                        Map<Id, List<LLC_BI__Entity_Compliance__c>> compliances,
                                        String appType,
                                        String fieldName,
                                        Integer defaultLimit,
                                        Integer noCoapplicantDefaultValue) {
        Integer counter = 0;
        String toReturn = nCSA_FRAME.csaConstants.BLANK;
        for(LLC_BI__Legal_Entities__c le: entities) {
            if (compliances.containsKey(le.Id)) {
                LLC_BI__Entity_Compliance__c ec = compliances.get(le.Id)[0];

                if(ec.get(HMDAFIELD_APPLICANTTYPE) == appType) {
                    toReturn += defaultReturnValue(null, ec.get(fieldName), PIPE);
                    counter++;
                }


                if(counter == defaultLimit) {
                    break;
                }
           }
        }

        counter++; //skip to next field position
        if(counter < defaultLimit) {
            defaultLimit = defaultLimit + 1;
            for(Integer i = counter; i < defaultLimit; i++) {
                if (appType == COAPPLICANT && noCoapplicantDefaultValue != null) {
                    toReturn += noCoapplicantDefaultValue + PIPE;
                } else {
                    toReturn += PIPE;
                }
            }
        }

        return toReturn;
    }

    private static Map<Id, LLC_BI__Loan__c> loanQuery(Date startDate, Date endDate, String customFieldName) {
        String query = 'SELECT Id FROM LLC_BI__Loan__c WHERE ' +
            customFieldName +
            ' >= :startDate AND ' +
            customFieldName +
            ' <= :endDate AND LLC_BI__HMDA_Reportable__c = true';

        return new Map<Id, LLC_BI__Loan__c>((List<LLC_BI__Loan__c>)Database.query(query));
    }

    private static Map<Id, LLC_BI__Legal_Entities__c> legalEntitiesQuery(Set<Id> loanIds) {
        return new Map<Id, LLC_BI__Legal_Entities__c>([SELECT
                                                                Id,
                                                                LLC_BI__Loan__c
                                                        FROM
                                                                LLC_BI__Legal_Entities__c
                                                        WHERE
                                                                LLC_BI__Loan__c = :loanIds]);
    }

    private static List<LLC_BI__Loan_Compliance__c> loanComplianceRecords(Set<Id> loanIds) {
        return [SELECT
                        Id,
                        LLC_BI__Date_Action_Taken__c,
                        LLC_BI__Date_Application_Received__c,
                        LLC_BI__Date_Rate_Set__c,
                        LLC_BI__HMDA_Action_Taken__c,
                        LLC_BI__HMDA_Amount__c,
                        LLC_BI__HMDA_AUS__c,
                        LLC_BI__HMDA_AUS_Other_Result_Text__c,
                        LLC_BI__HMDA_AUS_Other_System_Text__c,
                        LLC_BI__HMDA_AUS_Result__c,
                        LLC_BI__HMDA_Balloon_Payment__c,
                        LLC_BI__HMDA_Business_Or_Commercial_Purpose__c,
                        LLC_BI__HMDA_Co_Applicant__c,
                        LLC_BI__HMDA_Combined_LTV__c,
                        LLC_BI__HMDA_Debt_To_Income_Ratio__c,
                        LLC_BI__HMDA_Denial_Reason_Text__c,
                        LLC_BI__HMDA_Denial_Reasons__c,
                        LLC_BI__HMDA_Discount_Points__c,
                        LLC_BI__HMDA_HOEPA_Status__c,
                        LLC_BI__HMDA_Initially_Payable_To__c,
                        LLC_BI__HMDA_Interest_Only_Payments__c,
                        LLC_BI__HMDA_Legal_Entity_Identifier__c,
                        LLC_BI__HMDA_Lender_Credits__c,
                        LLC_BI__HMDA_Lien_Status__c,
                        LLC_BI__HMDA_Loan_Purpose__c,
                        LLC_BI__HMDA_Loan_Type__c,
                        LLC_BI__HMDA_Negative_Amortization__c,
                        LLC_BI__HMDA_Open_End_Line_Of_Credit__c,
                        LLC_BI__HMDA_Origination_Charges__c,
                        LLC_BI__HMDA_Other_Non_Amortizing_Features__c,
                        LLC_BI__HMDA_Preapproval_Requested__c,
                        LLC_BI__HMDA_Property_Securing_Address__c,
                        LLC_BI__HMDA_Property_Securing_Affordable_Units__c,
                        LLC_BI__HMDA_Property_Securing_Census_Tract__c,
                        LLC_BI__HMDA_Property_Securing_City__c,
                        LLC_BI__HMDA_Property_Securing_Construct_Method__c,
                        LLC_BI__HMDA_Property_Securing_FIPS_County_Code__c,
                        LLC_BI__HMDA_Property_Securing_Manufactured_Type__c,
                        LLC_BI__HMDA_Property_Securing_Mfd_Home_Int__c,
                        LLC_BI__HMDA_Property_Securing_MSA_MD_Number__c,
                        LLC_BI__HMDA_Property_Securing_Occupancy__c,
                        LLC_BI__HMDA_Property_Securing_Occupancy_Type__c,
                        LLC_BI__HMDA_Property_Securing_Property_Type__c,
                        LLC_BI__HMDA_Property_Securing_Property_Value__c,
                        LLC_BI__HMDA_Property_Securing_State__c,
                        LLC_BI__HMDA_Property_Securing_Total_Units__c,
                        LLC_BI__HMDA_Property_Securing_Zip__c,
                        LLC_BI__HMDA_Purchaser_Type__c,
                        LLC_BI__HMDA_Reverse_Mortgage__c,
                        LLC_BI__HMDA_Submission_Of_Application__c,
                        LLC_BI__HMDA_Total_Loan_Costs__c,
                        LLC_BI__HMDA_Total_Points_Fees__c,
                        LLC_BI__HMDA_Universal_Loan_Identifier__c,
                        LLC_BI__Interest_Rate__c,
                        LLC_BI__Introductory_Rate_Period__c,
                        LLC_BI__Loan__c,
                        LLC_BI__Loan_Id__c,
                        LLC_BI__Loan_Term__c,
                        LLC_BI__Mortgage_LO_NMLSR_Id__c,
                        LLC_BI__Prepayment_Penalty_Term__c,
                        LLC_BI__Rate_Spread__c
                FROM
                        LLC_BI__Loan_Compliance__c
                WHERE
                        LLC_BI__Loan__c = :loanIds];
    }

    private static Map<Id, List<LLC_BI__Entity_Compliance__c>> entityComplianceRecords(Set<Id> entityIds) {
        Map<Id, List<LLC_BI__Entity_Compliance__c>> toReturn = new Map<Id, List<LLC_BI__Entity_Compliance__c>>();

        List<LLC_BI__Entity_Compliance__c> entityCompliances = [SELECT
                                                                    Id,
                                                                    LLC_BI__Age__c,
                                                                    LLC_BI__Entity__c,
                                                                    LLC_BI__HMDA_Applicant_Type__c,
                                                                    LLC_BI__HMDA_Credit_Score__c,
                                                                    LLC_BI__HMDA_Credit_Scoring_Model__c,
                                                                    LLC_BI__HMDA_Credit_Scoring_Model_Other__c,
                                                                    LLC_BI__HMDA_Ethnicity__c,
                                                                    LLC_BI__HMDA_Ethnicity_Collection_Method__c,
                                                                    LLC_BI__HMDA_Ethnicity_Other__c,
                                                                    LLC_BI__HMDA_Income__c,
                                                                    LLC_BI__HMDA_Not_Provided__c,
                                                                    LLC_BI__HMDA_Race__c,
                                                                    LLC_BI__HMDA_Race_Collected__c,
                                                                    LLC_BI__HMDA_Race_Desc_Code_1__c,
                                                                    LLC_BI__HMDA_Race_Desc_Code_27__c,
                                                                    LLC_BI__HMDA_Race_Desc_Code_44__c,
                                                                    LLC_BI__HMDA_Sex__c,
                                                                    LLC_BI__HMDA_Sex_Collection_Method__c,
                                                                    Name
                                                            FROM
                                                                    LLC_BI__Entity_Compliance__c
                                                            WHERE
                                                                    LLC_BI__Entity__c = :entityIds];

        for(LLC_BI__Entity_Compliance__c ec: entityCompliances) {
            if(toReturn.containsKey(ec.LLC_BI__Entity__c)) {
                List<LLC_BI__Entity_Compliance__c> records = toReturn.get(ec.LLC_BI__Entity__c);
                records.add(ec);
                toReturn.put(ec.LLC_BI__Entity__c, records);
            } else {
                toReturn.put(ec.LLC_BI__Entity__c, new List<LLC_BI__Entity_Compliance__c> { ec });
            }
        }

        return toReturn;
    }

    private static String defaultReturnValue(Date aDate, Object fieldValue, String defaultReturn) {
      if(aDate != null) {
          String dateStr = aDate.format();
          DateTime dt = DateTime.newInstance(aDate.year(), aDate.month(), aDate.day());
          return dt.format(DATEFORMAT) + PIPE;
      } else if (fieldValue != null) {
          String strFieldValue = String.valueOf(fieldValue);
          if (strFieldValue.indexOf(SFDC_MULTISELECT_SEPERATOR) > -1) {
            strFieldValue = strFieldValue.replace(SFDC_MULTISELECT_SEPERATOR, HMDA_MULTISELECT_SEPERATOR);
          }
          return strFieldValue + PIPE;
      }
      return defaultReturn;
    }

    private static String createContentVersion(String csv) {
        ContentVersion version = new ContentVersion(
            title = HMDAFILENAME + System.now() + FILEEXTENSION,
            versionData = Blob.valueOf(csv),
            pathOnClient = SLASH + HMDAFILEPATH + System.now() + FILEEXTENSION
        );

        try {
            insert version;
        } catch(Exception ex) {
            throw new HmdaExtractException(ex);
        }

        return URL.getSalesforceBaseUrl().toExternalForm() + FILEURL_PARTONE + version.Id + FILEURL_PARTTWO;
    }

    private static void sendEmail(String userEmail, String userName, String link) {
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[] {userEmail};
        List<String> params = new List<String>();
        params.add(userName);
        params.add(link);

        mail.setToAddresses(toAddresses);
        mail.setSubject(System.Label.HE_Email_Title);
        mail.setBccSender(false);
        mail.setPlainTextBody(String.format(Label.HE_Email_Body_Text, params));
        mail.setHtmlBody(String.format(Label.HE_Email_Body_Html, params));

        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }

    private static final String PIPE = '|',
                                SLASH = '/',
                                NAPIPE = 'NA|',
                                NEWLINE = '\n',
                                NULL_VALUE = 'null',
                                DATEFORMAT = 'yyyMMdd',
                                SFDC_MULTISELECT_SEPERATOR = ';',
                                HMDA_MULTISELECT_SEPERATOR = ',',
                                HMDACATEGORY = 'HMDA',
                                NUMBERONE = '1',
                                NUMBERTWO = '2',
                                FILEURL_PARTONE = '/sfc/servlet.shepherd/version/download/',
                                FILEURL_PARTTWO = '?asPdf=false',
                                HMDAKEY_FINALCIALINSTITUTION = 'Financial_Institution',
                                HMDAKEY_CONTACTNAME = 'Contact_Name',
                                HMDAKEY_CONTACTPHONENUMBER = 'Contact_Phone_Number',
                                HMDAKEY_CONTACTEMAIL = 'Contact_Email',
                                HMDAKEY_CONTACTSTREETADDRESS = 'Contact_Street_Address',
                                HMDAKEY_CONTACTCITY = 'Contact_City',
                                HMDAKEY_CONTACTSTATE = 'Contact_State',
                                HMDAKEY_CONTACTZIP = 'Contact_Zip',
                                HMDAKEY_FEDAGENCY = 'Fed_Agency',
                                HMDAKEY_FEDTAXID = 'Fed_Tax_Id',
                                HMDAKEY_LEI = 'LEI',
                                APPLICANT = 'Applicant',
                                COAPPLICANT = 'Co-Applicant',
                                FILEEXTENSION = '.txt',
                                HMDAFILENAME = 'HMDA 2018 Extract',
                                HMDAFILEPATH = 'HMDA_2018_Extract',
                                HMDAFILEDESCRIPTION = 'This File is the Extract executed from Admin Page for the HMDA 2018 format.',
                                HMDAFIELD_ETHNICITY = 'LLC_BI__HMDA_Ethnicity__c',
                                HMDAFIELD_ETHNICITYOTHER = 'LLC_BI__HMDA_Ethnicity_Other__c',
                                HMDAFIELD_ETHNICITYCOLLECTION = 'LLC_BI__HMDA_Ethnicity_Collection_Method__c',
                                HMDAFIELD_RACE = 'LLC_BI__HMDA_Race__c',
                                HMDAFIELD_RACEDESC1 = 'LLC_BI__HMDA_Race_Desc_Code_1__c',
                                HMDAFIELD_RACEDESC27 = 'LLC_BI__HMDA_Race_Desc_Code_27__c',
                                HMDAFIELD_RACEDESC44 = 'LLC_BI__HMDA_Race_Desc_Code_44__c',
                                HMDAFIELD_RACECOLLECTION = 'LLC_BI__HMDA_Race_Collected__c',
                                HMDAFIELD_SEX = 'LLC_BI__HMDA_Sex__c',
                                HMDAFIELD_SEXCOLLECTION = 'LLC_BI__HMDA_Sex_Collection_Method__c',
                                HMDAFIELD_AGE = 'LLC_BI__Age__c',
                                HMDAFIELD_INCOME = 'LLC_BI__HMDA_Income__c',
                                HMDAFIELD_CREDITSCORE = 'LLC_BI__HMDA_Credit_Score__c',
                                HMDAFIELD_CREDITSCOREMODEL = 'LLC_BI__HMDA_Credit_Scoring_Model__c',
                                HMDAFIELD_CREDITSCOREMODELOTHER = 'LLC_BI__HMDA_Credit_Scoring_Model_Other__c',
                                HMDAFIELD_APPLICANTTYPE = 'LLC_BI__HMDA_Applicant_Type__c';
}