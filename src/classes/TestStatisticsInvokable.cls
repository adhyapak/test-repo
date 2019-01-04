@isTest
private class TestStatisticsInvokable {

    @testSetup
    private static void initialSetup() {
        insert new nFORCE__System_Properties__c(
            Name = ENABLE_STATISTICS,
            nFORCE__Category_Name__c = TOTAL_EXPOSURE_CATEGORY,
            nFORCE__Key__c = ENABLE_STATISTICS,
            nFORCE__Value__c = String.valueOf(true),
            nFORCE__Is_Active__c = true
        );
       configureLoanStageStatus(
            False,
            'TestRelationshipStatisticsCalculator Product Line',
            'TestRelationshipStatisticsCalculator Product Type',
            'TRSCPT',
            'TestRelationshipStatisticsCalculator Product');
        configureStatisticsConfiguration();
        clearStatistics();
        setupAccountsAndLoans();

        List<LLC_BI__StatisticsConfiguration__c> statConfigs = [SELECT Id, LLC_BI__Enable_Manual_Calculation__c FROM LLC_BI__StatisticsConfiguration__c];

        for(LLC_BI__StatisticsConfiguration__c statConfig: statConfigs) {
            statConfig.LLC_BI__Enable_Manual_Calculation__c = true;
        }
        update statConfigs;
    }

    @IsTest
    private static void testBatchExecution() {
        Map<String,Id> acctLoanMap = getAccountLoanMap();
        List<LLC_BI__Legal_Entities__c> entities = performEntitiesSetup(acctLoanMap,0,0);
        insert entities;
        clearStatistics();

        Test.startTest();
        ManualExposureCalculation.gottaTestFlows(acctLoanMap.values());
        Test.stopTest();

        testValues(7, (Id)acctLoanMap.get(ACCOUNT_NAME_1), CATEGORY, DIRECT_EXPOSURE, 100.00);
        testValues(7, (Id)acctLoanMap.get(ACCOUNT_NAME_1), CATEGORY, INDIRECT_EXPOSURE, 200.00);
        testValues(7, (Id)acctLoanMap.get(ACCOUNT_NAME_1), CATEGORY, COMMITTED_DIRECT_EXPOSURE, 150.00);
        testValues(7, (Id)acctLoanMap.get(ACCOUNT_NAME_1), CATEGORY, COMMITTED_INDIRECT_EXPOSURE, 400.00);
        testValues(7, (Id)acctLoanMap.get(ACCOUNT_NAME_1), CATEGORY, PROPOSED_DIRECT_EXPOSURE, 500.00);
        testValues(7, (Id)acctLoanMap.get(ACCOUNT_NAME_1), CATEGORY, PROPOSED_INDIRECT_EXPOSURE, 600.00);
    }

    @IsTest
    private static void testBatchExecutionExposureValueGreaterThanContAmtUsesContAmt() {
        Map<String,Id> acctLoanMap = getAccountLoanMap();
        List<LLC_BI__Legal_Entities__c> entities = performEntitiesSetupContingentAmount(acctLoanMap,0,0);
        insert entities;
        clearStatistics();

        Test.startTest();
        ManualExposureCalculation.gottaTestFlows(acctLoanMap.values());
        Test.stopTest();

        testValues(7, (Id)acctLoanMap.get(ACCOUNT_NAME_1), CATEGORY, DIRECT_EXPOSURE, 10.00);
        testValues(7, (Id)acctLoanMap.get(ACCOUNT_NAME_1), CATEGORY, INDIRECT_EXPOSURE, 11.00);
        testValues(7, (Id)acctLoanMap.get(ACCOUNT_NAME_1), CATEGORY, COMMITTED_DIRECT_EXPOSURE, 12.00);
        testValues(7, (Id)acctLoanMap.get(ACCOUNT_NAME_1), CATEGORY, COMMITTED_INDIRECT_EXPOSURE, 13.00);
        testValues(7, (Id)acctLoanMap.get(ACCOUNT_NAME_1), CATEGORY, PROPOSED_DIRECT_EXPOSURE, 14.00);
        testValues(7, (Id)acctLoanMap.get(ACCOUNT_NAME_1), CATEGORY, PROPOSED_INDIRECT_EXPOSURE, 15.00);
    }

    @IsTest
    private static void testBatchExecutionTwoLoan() {
        Map<String,Id> acctLoanMap = getAccountLoanMap();
        List<LLC_BI__Legal_Entities__c> entities = performEntitiesSetup(acctLoanMap,0,0);
        entities.addAll(performEntitiesSetup(acctLoanMap,1,1));
        insert entities;
        clearStatistics();

        Test.startTest();
        ManualExposureCalculation.gottaTestFlows(acctLoanMap.values());
        Test.stopTest();

        testValues(14, (Id)acctLoanMap.get(ACCOUNT_NAME_1), CATEGORY, DIRECT_EXPOSURE, 100.00);
        testValues(14, (Id)acctLoanMap.get(ACCOUNT_NAME_1), CATEGORY, INDIRECT_EXPOSURE, 200.00);
        testValues(14, (Id)acctLoanMap.get(ACCOUNT_NAME_1), CATEGORY, COMMITTED_DIRECT_EXPOSURE, 150.00);
        testValues(14, (Id)acctLoanMap.get(ACCOUNT_NAME_1), CATEGORY, COMMITTED_INDIRECT_EXPOSURE, 400.00);
        testValues(14, (Id)acctLoanMap.get(ACCOUNT_NAME_1), CATEGORY, PROPOSED_DIRECT_EXPOSURE, 500.00);
        testValues(14, (Id)acctLoanMap.get(ACCOUNT_NAME_1), CATEGORY, PROPOSED_INDIRECT_EXPOSURE, 600.00);
        testValues(14, (Id)acctLoanMap.get(ACCOUNT_NAME_2), CATEGORY, DIRECT_EXPOSURE, 1100.00);
        testValues(14, (Id)acctLoanMap.get(ACCOUNT_NAME_2), CATEGORY, INDIRECT_EXPOSURE, 1200.00);
        testValues(14, (Id)acctLoanMap.get(ACCOUNT_NAME_2), CATEGORY, COMMITTED_DIRECT_EXPOSURE, 650.00);
        testValues(14, (Id)acctLoanMap.get(ACCOUNT_NAME_2), CATEGORY, COMMITTED_INDIRECT_EXPOSURE, 1400.00);
        testValues(14, (Id)acctLoanMap.get(ACCOUNT_NAME_2), CATEGORY, PROPOSED_DIRECT_EXPOSURE, 1500.00);
        testValues(14, (Id)acctLoanMap.get(ACCOUNT_NAME_2), CATEGORY, PROPOSED_INDIRECT_EXPOSURE, 1600.00);
    }

    @IsTest
    private static void testBatchExecutionTwoLoanExposureValueGreaterThanContAmtUsesContAmt() {
        Map<String,Id> acctLoanMap = getAccountLoanMap();
        List<LLC_BI__Legal_Entities__c> entities = performEntitiesSetupContingentAmount(acctLoanMap,0,0);
        entities.addAll(performEntitiesSetupContingentAmount(acctLoanMap,1,1));
        insert entities;
        clearStatistics();

        Test.startTest();
        ManualExposureCalculation.gottaTestFlows(acctLoanMap.values());
        Test.stopTest();

        testValues(14, (Id)acctLoanMap.get(ACCOUNT_NAME_1), CATEGORY, DIRECT_EXPOSURE, 10.00);
        testValues(14, (Id)acctLoanMap.get(ACCOUNT_NAME_1), CATEGORY, INDIRECT_EXPOSURE, 11.00);
        testValues(14, (Id)acctLoanMap.get(ACCOUNT_NAME_1), CATEGORY, COMMITTED_DIRECT_EXPOSURE, 12.00);
        testValues(14, (Id)acctLoanMap.get(ACCOUNT_NAME_1), CATEGORY, COMMITTED_INDIRECT_EXPOSURE, 13.00);
        testValues(14, (Id)acctLoanMap.get(ACCOUNT_NAME_1), CATEGORY, PROPOSED_DIRECT_EXPOSURE, 14.00);
        testValues(14, (Id)acctLoanMap.get(ACCOUNT_NAME_1), CATEGORY, PROPOSED_INDIRECT_EXPOSURE, 15.00);
        testValues(14, (Id)acctLoanMap.get(ACCOUNT_NAME_2), CATEGORY, DIRECT_EXPOSURE, 10.00);
        testValues(14, (Id)acctLoanMap.get(ACCOUNT_NAME_2), CATEGORY, INDIRECT_EXPOSURE, 11.00);
        testValues(14, (Id)acctLoanMap.get(ACCOUNT_NAME_2), CATEGORY, COMMITTED_DIRECT_EXPOSURE, 12.00);
        testValues(14, (Id)acctLoanMap.get(ACCOUNT_NAME_2), CATEGORY, COMMITTED_INDIRECT_EXPOSURE, 13.00);
        testValues(14, (Id)acctLoanMap.get(ACCOUNT_NAME_2), CATEGORY, PROPOSED_DIRECT_EXPOSURE, 14.00);
        testValues(14, (Id)acctLoanMap.get(ACCOUNT_NAME_2), CATEGORY, PROPOSED_INDIRECT_EXPOSURE, 15.00);
    }

    @IsTest
    private static void testManualBatchExecutionTwoLoanContingentAmount() {
        clearStatistics();

        Map<String,Id> acctLoanMap = getAccountLoanMap();
        List<LLC_BI__Legal_Entities__c> entities = performEntitiesSetupContingentAmount(acctLoanMap,0,0);
        entities.addAll(performEntitiesSetupContingentAmount(acctLoanMap,1,1));
        insert entities;

        Test.startTest();
        ManualExposureCalculation.gottaTestFlows(acctLoanMap.values());
        Test.stopTest();

        testValues(14, (Id)acctLoanMap.get(ACCOUNT_NAME_1), CATEGORY, DIRECT_EXPOSURE, 10.00);
        testValues(14, (Id)acctLoanMap.get(ACCOUNT_NAME_1), CATEGORY, INDIRECT_EXPOSURE, 11.00);
        testValues(14, (Id)acctLoanMap.get(ACCOUNT_NAME_1), CATEGORY, COMMITTED_DIRECT_EXPOSURE, 12.00);
        testValues(14, (Id)acctLoanMap.get(ACCOUNT_NAME_1), CATEGORY, COMMITTED_INDIRECT_EXPOSURE, 13.00);
        testValues(14, (Id)acctLoanMap.get(ACCOUNT_NAME_1), CATEGORY, PROPOSED_DIRECT_EXPOSURE, 14.00);
        testValues(14, (Id)acctLoanMap.get(ACCOUNT_NAME_1), CATEGORY, PROPOSED_INDIRECT_EXPOSURE, 15.00);
        testValues(14, (Id)acctLoanMap.get(ACCOUNT_NAME_2), CATEGORY, DIRECT_EXPOSURE, 10.00);
        testValues(14, (Id)acctLoanMap.get(ACCOUNT_NAME_2), CATEGORY, INDIRECT_EXPOSURE, 11.00);
        testValues(14, (Id)acctLoanMap.get(ACCOUNT_NAME_2), CATEGORY, COMMITTED_DIRECT_EXPOSURE, 12.00);
        testValues(14, (Id)acctLoanMap.get(ACCOUNT_NAME_2), CATEGORY, COMMITTED_INDIRECT_EXPOSURE, 13.00);
        testValues(14, (Id)acctLoanMap.get(ACCOUNT_NAME_2), CATEGORY, PROPOSED_DIRECT_EXPOSURE, 14.00);
        testValues(14, (Id)acctLoanMap.get(ACCOUNT_NAME_2), CATEGORY, PROPOSED_INDIRECT_EXPOSURE, 15.00);
    }

    @IsTest
    private static void testBatchExecutionOneAcctTwoLoan() {
        Map<String,Id> acctLoanMap = getAccountLoanMap();
        List<LLC_BI__Legal_Entities__c> entities = performEntitiesSetup(acctLoanMap,0,0);
        entities.addAll(performEntitiesSetup(acctLoanMap,0,1));
        insert entities;
        clearStatistics();

        Test.startTest();
        ManualExposureCalculation.gottaTestFlows(acctLoanMap.values());
        Test.stopTest();

        testValues(7, (Id)acctLoanMap.get(ACCOUNT_NAME_1), CATEGORY, DIRECT_EXPOSURE, 1200.00);
        testValues(7, (Id)acctLoanMap.get(ACCOUNT_NAME_1), CATEGORY, INDIRECT_EXPOSURE, 1400.00);
        testValues(7, (Id)acctLoanMap.get(ACCOUNT_NAME_1), CATEGORY, COMMITTED_DIRECT_EXPOSURE, 800.00);
        testValues(7, (Id)acctLoanMap.get(ACCOUNT_NAME_1), CATEGORY, COMMITTED_INDIRECT_EXPOSURE, 1800.00);
        testValues(7, (Id)acctLoanMap.get(ACCOUNT_NAME_1), CATEGORY, PROPOSED_DIRECT_EXPOSURE, 2000.00);
        testValues(7, (Id)acctLoanMap.get(ACCOUNT_NAME_1), CATEGORY, PROPOSED_INDIRECT_EXPOSURE, 2200.00);
    }

    @IsTest
    private static void testBatchExecutionOneAcctTwoLoanExposureValueGreaterThanContAmtUsesContAmt() {
        Map<String,Id> acctLoanMap = getAccountLoanMap();
        List<LLC_BI__Legal_Entities__c> entities = performEntitiesSetupContingentAmount(acctLoanMap,0,0);
        entities.addAll(performEntitiesSetupContingentAmount(acctLoanMap,0,1));
        insert entities;
        clearStatistics();

        Test.startTest();
        ManualExposureCalculation.gottaTestFlows(acctLoanMap.values());
        Test.stopTest();

        testValues(7, (Id)acctLoanMap.get(ACCOUNT_NAME_1), CATEGORY, DIRECT_EXPOSURE, 20.00);
        testValues(7, (Id)acctLoanMap.get(ACCOUNT_NAME_1), CATEGORY, INDIRECT_EXPOSURE, 22.00);
        testValues(7, (Id)acctLoanMap.get(ACCOUNT_NAME_1), CATEGORY, COMMITTED_DIRECT_EXPOSURE, 24.00);
        testValues(7, (Id)acctLoanMap.get(ACCOUNT_NAME_1), CATEGORY, COMMITTED_INDIRECT_EXPOSURE, 26.00);
        testValues(7, (Id)acctLoanMap.get(ACCOUNT_NAME_1), CATEGORY, PROPOSED_DIRECT_EXPOSURE, 28.00);
        testValues(7, (Id)acctLoanMap.get(ACCOUNT_NAME_1), CATEGORY, PROPOSED_INDIRECT_EXPOSURE, 30.00);
    }

    @IsTest
    private static void testBatchExecutionTwoAcctTwoLoan() {
        Map<String,Id> acctLoanMap = getAccountLoanMap();
        List<LLC_BI__Legal_Entities__c> entities = performEntitiesSetup(acctLoanMap,0,0);
        entities.addAll(performEntitiesSetup(acctLoanMap,0,1));
        entities.addAll(performEntitiesSetup(acctLoanMap,1,1));
        entities.addAll(performEntitiesSetup(acctLoanMap,1,0));
        insert entities;
        clearStatistics();

        Test.startTest();
        ManualExposureCalculation.gottaTestFlows(acctLoanMap.values());
        Test.stopTest();

        testValues(14, (Id)acctLoanMap.get(ACCOUNT_NAME_1), CATEGORY, DIRECT_EXPOSURE, 1200.00);
        testValues(14, (Id)acctLoanMap.get(ACCOUNT_NAME_1), CATEGORY, INDIRECT_EXPOSURE, 1400.00);
        testValues(14, (Id)acctLoanMap.get(ACCOUNT_NAME_1), CATEGORY, COMMITTED_DIRECT_EXPOSURE, 800.00);
        testValues(14, (Id)acctLoanMap.get(ACCOUNT_NAME_1), CATEGORY, COMMITTED_INDIRECT_EXPOSURE, 1800.00);
        testValues(14, (Id)acctLoanMap.get(ACCOUNT_NAME_1), CATEGORY, PROPOSED_DIRECT_EXPOSURE, 2000.00);
        testValues(14, (Id)acctLoanMap.get(ACCOUNT_NAME_1), CATEGORY, PROPOSED_INDIRECT_EXPOSURE, 2200.00);
        testValues(14, (Id)acctLoanMap.get(ACCOUNT_NAME_2), CATEGORY, DIRECT_EXPOSURE, 1200.00);
        testValues(14, (Id)acctLoanMap.get(ACCOUNT_NAME_2), CATEGORY, INDIRECT_EXPOSURE, 1400.00);
        testValues(14, (Id)acctLoanMap.get(ACCOUNT_NAME_2), CATEGORY, COMMITTED_DIRECT_EXPOSURE, 800.00);
        testValues(14, (Id)acctLoanMap.get(ACCOUNT_NAME_2), CATEGORY, COMMITTED_INDIRECT_EXPOSURE, 1800.00);
        testValues(14, (Id)acctLoanMap.get(ACCOUNT_NAME_2), CATEGORY, PROPOSED_DIRECT_EXPOSURE, 2000.00);
        testValues(14, (Id)acctLoanMap.get(ACCOUNT_NAME_2), CATEGORY, PROPOSED_INDIRECT_EXPOSURE, 2200.00);
    }

    @IsTest
    private static void testBatchExecutionTwoAcctTwoLoanExposureValueGreaterThanContAmtUsesContAmt() {
        Map<String,Id> acctLoanMap = getAccountLoanMap();
        List<LLC_BI__Legal_Entities__c> entities = performEntitiesSetupContingentAmount(acctLoanMap,0,0);
        entities.addAll(performEntitiesSetupContingentAmount(acctLoanMap,0,1));
        entities.addAll(performEntitiesSetupContingentAmount(acctLoanMap,1,1));
        entities.addAll(performEntitiesSetupContingentAmount(acctLoanMap,1,0));
        insert entities;
        clearStatistics();

        Test.startTest();
        ManualExposureCalculation.gottaTestFlows(acctLoanMap.values());
        Test.stopTest();

        testValues(14, (Id)acctLoanMap.get(ACCOUNT_NAME_1), CATEGORY, DIRECT_EXPOSURE, 20.00);
        testValues(14, (Id)acctLoanMap.get(ACCOUNT_NAME_1), CATEGORY, INDIRECT_EXPOSURE, 22.00);
        testValues(14, (Id)acctLoanMap.get(ACCOUNT_NAME_1), CATEGORY, COMMITTED_DIRECT_EXPOSURE, 24.00);
        testValues(14, (Id)acctLoanMap.get(ACCOUNT_NAME_1), CATEGORY, COMMITTED_INDIRECT_EXPOSURE, 26.00);
        testValues(14, (Id)acctLoanMap.get(ACCOUNT_NAME_1), CATEGORY, PROPOSED_DIRECT_EXPOSURE, 28.00);
        testValues(14, (Id)acctLoanMap.get(ACCOUNT_NAME_1), CATEGORY, PROPOSED_INDIRECT_EXPOSURE, 30.00);
        testValues(14, (Id)acctLoanMap.get(ACCOUNT_NAME_2), CATEGORY, DIRECT_EXPOSURE, 20.00);
        testValues(14, (Id)acctLoanMap.get(ACCOUNT_NAME_2), CATEGORY, INDIRECT_EXPOSURE, 22.00);
        testValues(14, (Id)acctLoanMap.get(ACCOUNT_NAME_2), CATEGORY, COMMITTED_DIRECT_EXPOSURE, 24.00);
        testValues(14, (Id)acctLoanMap.get(ACCOUNT_NAME_2), CATEGORY, COMMITTED_INDIRECT_EXPOSURE, 26.00);
        testValues(14, (Id)acctLoanMap.get(ACCOUNT_NAME_2), CATEGORY, PROPOSED_DIRECT_EXPOSURE, 28.00);
        testValues(14, (Id)acctLoanMap.get(ACCOUNT_NAME_2), CATEGORY, PROPOSED_INDIRECT_EXPOSURE, 30.00);
    }

    private static void configureStatisticsConfiguration()
    {
        Integer counter = 1;
        insert createStatisticsConfiguration(
            DIRECT_EXPOSURE_NAME,
            STATISTICS_EXPOSURE_CALCULATOR_CLASS,
            CATEGORY,
            DIRECT_EXPOSURE,
            DIRECT_EXPOSURE_LABEL_KEY,
            counter,
            ACCOUNT_CLASS_NAME,
            true,
            true,
            true,
            assembleParametersString(
                new Map<String, String>{
                    BORROWER_TYPE_KEY => BORROWERS_VALUE,
                    STATUS_KEY => OPEN_STATUS_VALUE,
                    CLOSED_FUNDED_KEY => POSITIVE_CASE_VALUE,
                    USE_OWNERSHIP_KEY => POSITIVE_CASE_VALUE,
                    USE_PRINCIPAL_BALANCE_KEY => POSITIVE_CASE_VALUE
                }
            ),
            '',
            DIRECT_TYPE,
            1);

        insert createStatisticsConfiguration(
            INDIRECT_EXPOSURE_NAME,
            STATISTICS_EXPOSURE_CALCULATOR_CLASS,
            CATEGORY,
            INDIRECT_EXPOSURE,
            INDIRECT_EXPOSURE_LABEL_KEY,
            counter++,
            ACCOUNT_CLASS_NAME,
            true,
            true,
            true,
            assembleParametersString(
                new Map<String, String>{
                    BORROWER_TYPE_KEY => GUARANTORS_VALUE,
                    STATUS_KEY => OPEN_STATUS_VALUE,
                    CLOSED_FUNDED_KEY => POSITIVE_CASE_VALUE,
                    USE_PRINCIPAL_BALANCE_KEY => POSITIVE_CASE_VALUE
                }
            ),
            '',
            INDIRECT_TYPE,
            2);

        insert createStatisticsConfiguration(
            COMMITTED_DIRECT_EXPOSURE_NAME,
            STATISTICS_EXPOSURE_CALCULATOR_CLASS,
            CATEGORY,
            COMMITTED_DIRECT_EXPOSURE,
            COMMITTED_DIRECT_EXPOSURE_LABEL_KEY,
            counter++,
            ACCOUNT_CLASS_NAME,
            true,
            true,
            true,
            assembleParametersString(
                new Map<String, String>{
                    BORROWER_TYPE_KEY => BORROWERS_VALUE,
                    STAGE_KEY => COMMITTED_STAGES_VALUE,
                    STATUS_KEY => OPEN_STATUS_VALUE,
                    USE_OWNERSHIP_KEY => POSITIVE_CASE_VALUE
                }
            ),
            '',
            DIRECT_TYPE,
            1);

        insert createStatisticsConfiguration(
            COMMITTED_INDIRECT_EXPOSURE_NAME,
            STATISTICS_EXPOSURE_CALCULATOR_CLASS,
            CATEGORY,
            COMMITTED_INDIRECT_EXPOSURE,
            COMMITTED_INDIRECT_EXPOSURE_LABEL_KEY,
            counter++,
            ACCOUNT_CLASS_NAME,
            true,
            true,
            true,
            assembleParametersString(
                new Map<String, String>{
                    BORROWER_TYPE_KEY => GUARANTORS_VALUE,
                    STAGE_KEY => COMMITTED_STAGES_VALUE,
                    STATUS_KEY => OPEN_STATUS_VALUE
                }
            ),
            '',
            INDIRECT_TYPE,
            2);

        insert createStatisticsConfiguration(
            PROPOSED_DIRECT_EXPOSURE_NAME,
            STATISTICS_EXPOSURE_CALCULATOR_CLASS,
            CATEGORY,
            PROPOSED_DIRECT_EXPOSURE,
            PROPOSED_DIRECT_EXPOSURE_LABEL_KEY,
            counter++,
            ACCOUNT_CLASS_NAME,
            true,
            true,
            true,
            assembleParametersString(
                new Map<String, String>{
                    BORROWER_TYPE_KEY => BORROWERS_VALUE,
                    STAGE_KEY => PROPOSED_STAGES_VALUE,
                    STATUS_KEY => OPEN_STATUS_VALUE,
                    USE_OWNERSHIP_KEY => POSITIVE_CASE_VALUE
                }
            ),
            '',
            DIRECT_TYPE,
            1);

        insert createStatisticsConfiguration(
            PROPOSED_INDIRECT_EXPOSURE_NAME,
            STATISTICS_EXPOSURE_CALCULATOR_CLASS,
            CATEGORY,
            PROPOSED_INDIRECT_EXPOSURE,
            PROPOSED_INDIRECT_EXPOSURE_LABEL_KEY,
            counter++,
            ACCOUNT_CLASS_NAME,
            true,
            true,
            true,
            assembleParametersString(
                new Map<String, String>{
                    BORROWER_TYPE_KEY => GUARANTORS_VALUE,
                    STAGE_KEY => PROPOSED_STAGES_VALUE,
                    STATUS_KEY => OPEN_STATUS_VALUE
                }
            ),
            '',
            INDIRECT_TYPE,
            2);

        insert createStatisticsConfiguration(
            TOTAL_NET_NEW_FUNDS_NAME,
            STATISTICS_EXPOSURE_CALCULATOR_CLASS,
            CATEGORY,
            TOTAL_NET_NEW_FUNDS,
            TOTAL_NET_NEW_FUNDS_LABEL_KEY,
            counter++,
            ACCOUNT_CLASS_NAME,
            true,
            true,
            true,
            assembleParametersString(
                new Map<String, String>{
                    BORROWER_TYPE_KEY => BORROWERS_VALUE,
                    STATUS_KEY => OPEN_STATUS_VALUE,
                    CLOSED_FUNDED_KEY => POSITIVE_CASE_VALUE,
                    USE_OWNERSHIP_KEY => POSITIVE_CASE_VALUE,
                    USE_PRINCIPAL_BALANCE_KEY => POSITIVE_CASE_VALUE
                }
            ),
            name(LLC_BI__Legal_Entities__c.LLC_BI__Loan__c, LLC_BI__Loan__c.LLC_BI__Net_New_Funds__c),
            NET_FUNDS_TYPE,
            null);
    }

    private static Map<String,Id> getAccountLoanMap() {

        Map<String,Id> acctLoanMap = new Map<String,Id>();

        List<Account> acctList = [
            SELECT
                Id,
                Name
            FROM
                Account
        ];

        Set<String> relevantAccs = new Set<String>{ACCOUNT_NAME_1,ACCOUNT_NAME_2,ACCOUNT_NAME_3,ACCOUNT_NAME_4};
        for (Account acct : acctList) {
            if (relevantAccs.contains(acct.Name)) {
                acctLoanMap.put(acct.name, acct.Id);
            }
        }

        List<LLC_BI__Loan__c> loanList = new List<LLC_BI__Loan__c>();
        loanList.add(getLoan(LOAN_NAME_11));
        loanList.add(getLoan(LOAN_NAME_12));
        loanList.add(getLoan(LOAN_NAME_13));
        loanList.add(getLoan(LOAN_NAME_14));
        loanList.add(getLoan(LOAN_NAME_15));
        loanList.add(getLoan(LOAN_NAME_16));
        loanList.add(getLoan(LOAN_NAME_21));
        loanList.add(getLoan(LOAN_NAME_22));
        loanList.add(getLoan(LOAN_NAME_23));
        loanList.add(getLoan(LOAN_NAME_24));
        loanList.add(getLoan(LOAN_NAME_25));
        loanList.add(getLoan(LOAN_NAME_26));
        loanList.add(getLoan(LOAN_NAME_31));
        loanList.add(getLoan(LOAN_NAME_41));
        loanList.add(getLoan(LOAN_NAME_42));

        for (LLC_BI__Loan__c ln : loanList) {
            acctLoanMap.put(ln.name, ln.Id);
        }

        return acctLoanMap;
    }

    private static LLC_BI__Loan__c getLoan(String name) {
        return [SELECT Id, Name FROM LLC_BI__Loan__c WHERE Name =: name LIMIT 1];
    }

    private static LLC_BI__StatisticsConfiguration__c createStatisticsConfiguration(
        String nameString,
        String businessLogicClass,
        String categoryName,
        String fieldName,
        String labelKey,
        Decimal displayOrder,
        String objectName,
        Boolean active,
        Boolean postToParentObject,
        Boolean enableAutomation,
        String additionalParameters,
        String calculatedFieldPath,
        String extype,
        Integer calculationPriority)
    {

        String secondAddParm = additionalParameters.substringBefore(PARAMETER_DELIMITER);
        String addParam = additionalParameters.substringAfter(PARAMETER_DELIMITER);

        return new LLC_BI__StatisticsConfiguration__c(
            name = nameString,
            LLC_BI__Active__c = active,
            LLC_BI__Additional_Parameters__c = additionalParameters,
            LLC_BI__Additional_Parameters_2__c = '',
            LLC_BI__Business_Logic_Class__c = businessLogicClass,
            LLC_BI__Category__c = categoryName,
            LLC_BI__Field_Name__c = fieldName,
            LLC_BI__Label_Key__c = labelKey,
            LLC_BI__Object_Name__c = objectName,
            LLC_BI__Post_to_Parent_Object__c = postToParentObject,
            LLC_BI__Enable_Automatic_Calculation__c = enableAutomation,
            LLC_BI__Is_Table__c = false,
            LLC_BI__Relative_Display_Order__c = displayOrder,
            LLC_BI__Calculated_Field_Path__c = calculatedFieldPath,
            LLC_BI__Type__c = extype,
            LLC_BI__Calculation_Priority__c = calculationPriority);
    }

    private static String assembleParametersString(Map<String,String> mParams) {
        String sParams = '';

        if(mParams != null) {
            List<String> lParams = new List<String>();
            for(String key : mParams.keySet()) {
                if(mParams.get(key) != null) {
                    lParams.add(key + KEY_VALUE_DELIMITER + mParams.get(key));
                }
            }
            lParams.sort();
            sParams = String.join(lParams, PARAMETER_DELIMITER);
        }

        return sParams;
    }

    private static String relationship(Schema.SObjectField fld) {
        return fld.getDescribe().getRelationshipName();
    }

    private static String name(Schema.SObjectField fld) {
        return fld.getDescribe().getName();
    }

    private static String name(Schema.SObjectField relationship, Schema.SObjectField fld) {
        return relationship(relationship) + '.' + name(fld);
    }

    private static void clearStatistics()
    {
        List<LLC_BI__Statistic__c> stats =
        [SELECT
            Id
        FROM
            LLC_BI__Statistic__c
        ];
        if (stats != null && stats.size()>0) {
            delete stats;
        }
    }

    private static List<LLC_BI__Legal_Entities__c> performEntitiesSetupContingentAmount(
        Map<String,Id> acctLoanMap,
        Integer acctIndex,
        Integer loanIndex)
    {
        List<LLC_BI__Legal_Entities__c> entities = new List<LLC_BI__Legal_Entities__c>();
        for (Integer counter = 0; counter < 6; counter++) {
            entities.add(
                addLegalEntity(
                    acctLoanMap.get(accounts[acctIndex]),
                    acctLoanMap.get(loans[loanIndex][counter]),
                    borrowerTypes[counter],
                    null,
                    10.00 + counter,
                    false
                )

            );
        }
        return entities;
    }

    private static LLC_BI__Legal_Entities__c addLegalEntity(
        Id acctId,
        Id loanId,
        String borrowerType,
        Decimal ownershipPercentage)
    {
        return addLegalEntity(
            acctId,
            loanId,
            borrowerType,
            ownershipPercentage,
            null,
            true
        );
    }

    private static LLC_BI__Legal_Entities__c addLegalEntity(
        Id acctId,
        Id loanId,
        String borrowerType,
        Decimal ownershipPercentage,
        Decimal contingentAmount,
        Boolean performInsert)
    {
        return addLegalEntity(acctId, loanId, borrowerType, ownershipPercentage, contingentAmount, performInsert, null);
    }

    private static LLC_BI__Legal_Entities__c addLegalEntity(
        Id acctId,
        Id loanId,
        String borrowerType,
        Decimal ownershipPercentage,
        Decimal contingentAmount,
        Boolean performInsert,
        Id prodPackId)
    {
        LLC_BI__Legal_Entities__c legalEntity = new LLC_BI__Legal_Entities__c();
        legalEntity.LLC_BI__Loan__c = loanId;
        legalEntity.LLC_BI__Account__c = acctId;
        legalEntity.LLC_BI__Borrower_Type__c = borrowerType;
        legalEntity.LLC_BI__Product_Package__c = prodPackId;
        if (ownershipPercentage != null) {
            legalEntity.LLC_BI__Ownership__c = ownershipPercentage;
        }
        if (contingentAmount != null) {
            legalEntity.LLC_BI__Contingent_Amount__c = contingentAmount;
        }
        if (performInsert) {
            insert legalEntity;
        }
        return legalEntity;
    }

    private static void testValues(Integer recordCount, Id acctId, String categoryName, String fieldName, Decimal compareValue) {
        if (recordCount != null) {
            Integer recCount = [SELECT count() FROM LLC_BI__Statistic__c];
            System.assertEquals(recordCount, recCount);
        }

        List<LLC_BI__Statistic__c> d =
        [SELECT
                LLC_BI__Value_Currency__c
        FROM
                LLC_BI__Statistic__c
        WHERE
        LLC_BI__Account__c =:acctId
        AND
        LLC_BI__Category__c = :categoryName
        AND
        LLC_BI__Field_Name__c = :fieldName
        ];

        System.assertEquals(compareValue, d[0].LLC_BI__Value_Currency__c);

        String queryString = 'SELECT ' + fieldName + ' FROM Account WHERE Id = :acctId';
        List<Account> a = Database.query(queryString);
        System.assert(a != null);
        System.assertEquals(1, a.size());
        System.assertEquals(compareValue,a[0].get(fieldName));
    }

    private static Map<String,Id> setupAccountsAndLoans() {
        Map<String,Id> acctLoanMap = new Map<String,Id>();
        Map<String,Id> productMap = setupProducts();
        List<Account> acctList = new List<Account>();
        acctList.add(addAccount(ACCOUNT_NAME_1,'Veterinary'));
        acctList.add(addAccount(ACCOUNT_NAME_2,'Veterinary'));
        acctList.add(addAccount(ACCOUNT_NAME_3,'Veterinary'));
        acctList.add(addAccount(ACCOUNT_NAME_4,'Veterinary'));
        insert acctList;
        for (Account acct : acctList) {
            acctLoanMap.put(acct.name, acct.Id);
        }

        List<LLC_BI__Loan__c>loanList = new List<LLC_BI__Loan__c>();
        loanList.add(addLoan(LOAN_NAME_11, acctLoanMap.get(ACCOUNT_NAME_1), 100.0,  100.0,  'Closed Funded', OPEN_STATUS_VALUE, null, productMap.get(PRODUCT_NAME_1)));
        loanList.add(addLoan(LOAN_NAME_12, acctLoanMap.get(ACCOUNT_NAME_1), 200.0,  200.0,  'Closed Funded', OPEN_STATUS_VALUE, null, productMap.get(PRODUCT_NAME_1)));
        loanList.add(addLoan(LOAN_NAME_13, acctLoanMap.get(ACCOUNT_NAME_1), 300.0,  300.0,  'Processing', OPEN_STATUS_VALUE, null, productMap.get(PRODUCT_NAME_1)));
        loanList.add(addLoan(LOAN_NAME_14, acctLoanMap.get(ACCOUNT_NAME_1), 400.0,  400.0,  'Closing', OPEN_STATUS_VALUE, null, productMap.get(PRODUCT_NAME_1)));
        loanList.add(addLoan(LOAN_NAME_15, acctLoanMap.get(ACCOUNT_NAME_1), 500.0,  500.0,  'Credit Underwriting', OPEN_STATUS_VALUE, null, productMap.get(PRODUCT_NAME_1)));
        loanList.add(addLoan(LOAN_NAME_16, acctLoanMap.get(ACCOUNT_NAME_1), 600.0,  600.0,  'Loan Committee', OPEN_STATUS_VALUE, null, productMap.get(PRODUCT_NAME_1)));
        loanList.add(addLoan(LOAN_NAME_21, acctLoanMap.get(ACCOUNT_NAME_2), 1100.0, 1100.0, 'Closed Funded', OPEN_STATUS_VALUE, null, productMap.get(PRODUCT_NAME_1)));
        loanList.add(addLoan(LOAN_NAME_22, acctLoanMap.get(ACCOUNT_NAME_2), 1200.0, 1200.0, 'Closed Funded', OPEN_STATUS_VALUE, null, productMap.get(PRODUCT_NAME_1)));
        loanList.add(addLoan(LOAN_NAME_23, acctLoanMap.get(ACCOUNT_NAME_2), 1300.0, 1300.0, 'Processing', OPEN_STATUS_VALUE, null, productMap.get(PRODUCT_NAME_1)));
        loanList.add(addLoan(LOAN_NAME_24, acctLoanMap.get(ACCOUNT_NAME_2), 1400.0, 1400.0, 'Closing', OPEN_STATUS_VALUE, null, productMap.get(PRODUCT_NAME_1)));
        loanList.add(addLoan(LOAN_NAME_25, acctLoanMap.get(ACCOUNT_NAME_2), 1500.0, 1500.0, 'Credit Underwriting', OPEN_STATUS_VALUE, null, productMap.get(PRODUCT_NAME_1)));
        loanList.add(addLoan(LOAN_NAME_26, acctLoanMap.get(ACCOUNT_NAME_2), 1600.0, 1600.0, 'Loan Committee', OPEN_STATUS_VALUE, null, productMap.get(PRODUCT_NAME_1)));
        loanList.add(addLoan(LOAN_NAME_31, acctLoanMap.get(ACCOUNT_NAME_3), 1700.0, 100.0, 'Closed Funded', OPEN_STATUS_VALUE, null, productMap.get(PRODUCT_NAME_2)));
        loanList.add(addLoan(LOAN_NAME_41, acctLoanMap.get(ACCOUNT_NAME_4), 8000.0, 800.0, 'Closing', OPEN_STATUS_VALUE, null, productMap.get(PRODUCT_NAME_1)));
        loanList.add(addLoan(LOAN_NAME_42, acctLoanMap.get(ACCOUNT_NAME_4), 9000.0, 8800.0, 'Credit Underwriting', OPEN_STATUS_VALUE, null, productMap.get(PRODUCT_NAME_1)));

        insert loanList;
        for (LLC_BI__Loan__c ln : loanList) {
            acctLoanMap.put(ln.name, ln.Id);
        }

        List<LLC_BI__LoanRenewal__c> loanRenewalList = new List<LLC_BI__LoanRenewal__c>();
        loanRenewalList.add(addLoanRenewal(acctLoanMap.get(LOAN_NAME_41), 'Closing', OPEN_STATUS_VALUE, acctLoanMap.get(LOAN_NAME_42)));
        insert loanRenewalList;

        return acctLoanMap;
    }

    private static LLC_BI__Loan__c addLoan(
        String name,
        Id acctId,
        Decimal amount,
        Decimal principalBalance,
        String stage,
        String status,
        String structureHierarchy,
        Id productId)
    {
        LLC_BI__Loan__c ln = new LLC_BI__Loan__c();
        ln.Name = name;
        ln.LLC_BI__Account__c = acctId;
        ln.LLC_BI__Stage__c = stage;
        ln.LLC_BI__Status__c = status;
        ln.LLC_BI__Amount__c = amount;
        ln.LLC_BI__Principal_Balance__c = principalBalance;
        ln.LLC_BI__Product_Reference__c = productId;
        ln.LLC_BI__Structure_Hierarchy__c = structureHierarchy;
        ln.LLC_BI__CloseDate__c = System.Today();
        ln.LLC_BI__Construction_CO_Date__c = System.Today();
        ln.LLC_BI__Credit_Approval_Date__c = System.Today();
        return ln;
    }

    private static Map<String, Id> setupProducts() {
        Map<String,Id> productMap = new Map<String,Id>();

        List<LLC_BI__Product_Feature__c> productFeats =
        [SELECT
                Id
        FROM
                LLC_BI__Product_Feature__c
        WHERE
        LLC_BI__External_Product_Name__c != NULL
        AND
        LLC_BI__External_Product_Name__c
                IN
                (:PRODUCT_EXT_NAME_1,:PRODUCT_EXT_NAME_2)
        ];
        if(productFeats != null && productFeats.size() > 0) {
            delete productFeats;
        }

        List<LLC_BI__Product_Feature__c> productFeatList = new List<LLC_BI__Product_Feature__c>();
        productFeatList.add(addProductFeature(PRODUCT_EXT_NAME_1, false));
        productFeatList.add(addProductFeature(PRODUCT_EXT_NAME_2, true));
        insert productFeatList;
        for(LLC_BI__Product_Feature__c pf : productFeatList) {
            productMap.put(pf.LLC_BI__External_Product_Name__c, pf.Id);
        }

        List<LLC_BI__Product_Type__c> productTypeList =
        [SELECT
            Id, Name
        FROM
            LLC_BI__Product_Type__c
        WHERE
        Name != NULL
        AND
        Name
            IN
            (:PRODUCT_TYPE_NAME_1,:PRODUCT_TYPE_NAME_2)
        ];

        for(LLC_BI__Product_Type__c pt : productTypeList) {
            productMap.put(pt.Name, pt.Id);
        }

        List<LLC_BI__Product__c> productList =
        [SELECT
            Id,
            Name,
            LLC_BI__Product_Type__c,
            LLC_BI__Product_Feature__c
        FROM
            LLC_BI__Product__c
        WHERE
            Name != NULL
        AND
            Name
                IN
                (:PRODUCT_NAME_1,:PRODUCT_NAME_2)
        ];
        if(productList != null && productList.size() > 0) {
            for(LLC_BI__Product__c p : productList) {
                if(p.Name.equals(PRODUCT_NAME_1)) {
                    p.LLC_BI__Product_Feature__c = productMap.get(PRODUCT_EXT_NAME_1);
                }
                if(p.Name.equals(PRODUCT_NAME_2)) {
                    p.LLC_BI__Product_Feature__c = productMap.get(PRODUCT_EXT_NAME_2);

                }
                productMap.put(p.Name, p.Id);
            }
            update productList;
            productList.clear();
        }

        if(productMap.get(PRODUCT_NAME_1) == null) {
            productList.add(addProduct(PRODUCT_NAME_1, productMap.get(PRODUCT_TYPE_NAME_1), productMap.get(PRODUCT_EXT_NAME_1)));
        }
        if(productMap.get(PRODUCT_NAME_2) == null) {
            productList.add(addProduct(PRODUCT_NAME_2, productMap.get(PRODUCT_TYPE_NAME_2), productMap.get(PRODUCT_EXT_NAME_2)));
        }
        if(productList != null && productList.size() > 0) {
            insert productList;
            for(LLC_BI__Product__c p : productList) {
                productMap.put(p.Name, p.Id);
            }
        }

        return productMap;
    }

    private static LLC_BI__Product__c addProduct(
        String name,
        Id productTypeId,
        Id productFeatureId)
    {
        LLC_BI__Product__c p = new LLC_BI__Product__c();
        p.Name = name;
        p.LLC_BI__Product_Type__c = productTypeId;
        p.LLC_BI__Product_Feature__c = productFeatureId;
        return p;
    }

    private static LLC_BI__Product_Feature__c addProductFeature(String name, Boolean isLineOfCredit) {
        return addProductFeature(name, isLineOfCredit, false);
    }

    private static LLC_BI__Product_Feature__c addProductFeature(
        String name,
        Boolean isLineOfCredit,
        Boolean excludeFromExposure)
    {
        return addProductFeature(name, isLineOfCredit, excludeFromExposure, null);
    }

    private static LLC_BI__Product_Feature__c addProductFeature(String name,
        Boolean isLineOfCredit,
        Boolean excludeFromExposure,
        String productFeatureFilter
    ) {
        return new LLC_BI__Product_Feature__c(
            LLC_BI__External_Product_Name__c = name,
            LLC_BI__Line_Of_Credit__c = isLineOfCredit,
            LLC_BI__Exclude_From_Exposure__c = excludeFromExposure,
            LLC_BI__Exposure_Filter__c = productFeatureFilter
        );
    }


    private static Account addAccount(
        String name,
        String industry)
    {
        Account a = new Account();
        a.Name=name;
        a.Industry=industry;
        return a;
    }

    private static LLC_BI__LoanRenewal__c addLoanRenewal(
        Id parentLoanId,
        String previousVersionStage,
        String previousVersionStatus,
        Id renewalLoanId)
    {
        LLC_BI__LoanRenewal__c lr = new LLC_BI__LoanRenewal__c();
        lr.LLC_BI__ParentLoanId__c = parentLoanId;
        lr.LLC_BI__RevisionNumber__c = 1;
        lr.LLC_BI__PreviousVersionStage__c = previousVersionStage;
        lr.LLC_BI__PreviousVersionStatus__c = previousVersionStatus;
        lr.LLC_BI__RenewalLoanId__c = renewalLoanId;
        return lr;
    }

    private static void configureLoanStageStatus(Boolean createSecondProduct) {
        configureLoanStageStatus(
            createSecondProduct,
            'Test Product Line',
            'Test Product Type',
            'TPT',
            'Test Product');
    }

    private static void configureLoanStageStatus(
        Boolean createSecondProduct,
        String productLineName,
        String productTypeName,
        String productTypeLookup,
        String productName) {
        LLC_BI__Product_Line__c pl = new LLC_BI__Product_Line__c(
            Name = productLineName + ' 1',
            LLC_BI__Product_Object__c = LLC_BI__Loan__c.getSObjectType().getDescribe().getLocalName(),
            LLC_BI__lookupKey__c = generateGuid()
        );
        insert pl;

        List<sObject> productTypes = new List<sObject>();

        LLC_BI__Product_Type__c pt = new LLC_BI__Product_Type__c(
            Name = productTypeName + ' 1',
            LLC_BI__Usage_Type__c = 'Loan',
            LLC_BI__Product_Line__c = pl.Id,
            LLC_BI__lookupKey__c = productTypeLookup + '01'
        );
        productTypes.add(pt);

        LLC_BI__Product_Type__c pt2 = new LLC_BI__Product_Type__c(
            Name = productTypeName + ' 2',
            LLC_BI__Usage_Type__c = 'Loan',
            LLC_BI__Product_Line__c = pl.Id,
            LLC_BI__lookupKey__c = productTypeLookup + '02'
        );
        productTypes.add(pt2);

        insert productTypes;

        List<sObject> products = new List<sObject>();

        LLC_BI__Product__c p = new LLC_BI__Product__c(
            Name = productName + ' 1',
            LLC_BI__Product_Type__c = pt.Id,
            LLC_BI__lookupKey__c = generateGuid()
        );
        products.add(p);

        if (createSecondProduct) {
            LLC_BI__Product__c p2 = new LLC_BI__Product__c(
                Name = productName + ' 2',
                LLC_BI__Product_Type__c = pt.Id,
                LLC_BI__lookupKey__c = generateGuid()
            );
            products.add(p2);
        }
        insert products;

        List<sObject> configKeys = new List<sObject>();

        LLC_BI__CFG_ConfigKey__c cm_key_prefix = new LLC_BI__CFG_ConfigKey__c(
            Name = 'KY_GBL_NamespacePrefixBI',
            LLC_BI__lookupKey__c = generateGuid()
        );
        configKeys.add(cm_key_prefix);

        LLC_BI__CFG_ConfigKey__c cfk = new LLC_BI__CFG_ConfigKey__c(
            Name = pt.LLC_BI__lookupKey__c,
            LLC_BI__lookupKey__c = generateGuid()
        );
        configKeys.add(cfk);

        LLC_BI__CFG_ConfigKey__c cfk2 = new LLC_BI__CFG_ConfigKey__c(
            Name = pt2.LLC_BI__lookupKey__c,
            LLC_BI__lookupKey__c = generateGuid()
        );
        configKeys.add(cfk2);

        insert configKeys;

        List<sObject> configValues = new List<sObject>();

        LLC_BI__CFG_ConfigValue__c ccfv_prefix = new LLC_BI__CFG_ConfigValue__c(
            LLC_BI__Key__c = 'Bankr_BI_Prefix',
            LLC_BI__FieldValue__c = '',
            LLC_BI__Category__c = 'General',
            LLC_BI__lookupKey__c = generateGuid()
        );
        configValues.add(ccfv_prefix);

        LLC_BI__CFG_ConfigValue__c ccfv1 = new LLC_BI__CFG_ConfigValue__c(
            LLC_BI__Key__c = 'Complete',
            LLC_BI__Value__c = 'Complete',
            LLC_BI__fieldValue__c = 'Complete',
            LLC_BI__Category__c = 'Loan Stage',
            LLC_BI__lookupKey__c = generateGuid()
        );
        configValues.add(ccfv1);

        LLC_BI__CFG_ConfigValue__c ccfv2 = new LLC_BI__CFG_ConfigValue__c(
            LLC_BI__Key__c = 'Closed',
            LLC_BI__Value__c = 'Closed Funded',
            LLC_BI__fieldValue__c = 'Closed Funded',
            LLC_BI__Category__c = 'Loan Stage',
            LLC_BI__lookupKey__c = generateGuid()
        );
        configValues.add(ccfv2);

        LLC_BI__CFG_ConfigValue__c cvpt2 = new LLC_BI__CFG_ConfigValue__c(
            LLC_BI__Key__c = 'Closed',
            LLC_BI__Value__c = 'Closed Funded',
            LLC_BI__fieldValue__c = 'Closed Funded',
            LLC_BI__Category__c = 'Loan Stage',
            LLC_BI__lookupKey__c = generateGuid()
        );
        configValues.add(cvpt2);

        LLC_BI__CFG_ConfigValue__c ccfv3 = new LLC_BI__CFG_ConfigValue__c(
            LLC_BI__Key__c = 'Declined',
            LLC_BI__Value__c = 'Declined',
            LLC_BI__fieldValue__c = 'Declined',
            LLC_BI__Category__c = 'Loan Status',
            LLC_BI__lookupKey__c = generateGuid()
        );
        configValues.add(ccfv3);

        LLC_BI__CFG_ConfigValue__c cvdt = new LLC_BI__CFG_ConfigValue__c(
            LLC_BI__Key__c = 'CM_DocTabLookupKey',
            LLC_BI__Value__c = 'TestDocTab',
            LLC_BI__fieldValue__c = 'TestDocTab',
            LLC_BI__Category__c = 'Change Memo',
            LLC_BI__lookupKey__c = generateGuid()
        );
        configValues.add(cvdt);

        LLC_BI__CFG_ConfigValue__c cvdty = new LLC_BI__CFG_ConfigValue__c(
            LLC_BI__Key__c = 'CM_DocTypeLookupKey',
            LLC_BI__Value__c = 'TestDocType',
            LLC_BI__fieldValue__c = 'TestDocType',
            LLC_BI__Category__c = 'Change Memo',
            LLC_BI__lookupKey__c = generateGuid()
        );
        configValues.add(cvdty);

        LLC_BI__CFG_ConfigValue__c cvdm = new LLC_BI__CFG_ConfigValue__c(
            LLC_BI__Key__c = 'CM_DocManLookupKey',
            LLC_BI__Value__c = 'TestDocMan',
            LLC_BI__fieldValue__c = 'TestDocMan',
            LLC_BI__Category__c = 'Change Memo',
            LLC_BI__lookupKey__c = generateGuid()
        );
        configValues.add(cvdm);

        insert configValues;

        List<sObject> configJoins = new List<sObject>();

        LLC_BI__CFG_CKJ__c ckj5 = new LLC_BI__CFG_CKJ__c(
            LLC_BI__CFG_ConfigKeys__c = cm_key_prefix.Id,
            LLC_BI__CFG_ConfigValue__c = ccfv_prefix.Id
        );
        configJoins.add(ckj5);

        LLC_BI__CFG_CKJ__c cm_join1 = new LLC_BI__CFG_CKJ__c(
            LLC_BI__CFG_ConfigKeys__c = cfk.Id,
            LLC_BI__CFG_ConfigValue__c = cvdt.Id
        );
        configJoins.add(cm_join1);

        LLC_BI__CFG_CKJ__c cm_join2 = new LLC_BI__CFG_CKJ__c(
            LLC_BI__CFG_ConfigKeys__c = cfk.Id,
            LLC_BI__CFG_ConfigValue__c = cvdty.Id
        );
        configJoins.add(cm_join2);

        LLC_BI__CFG_CKJ__c cm_join3 = new LLC_BI__CFG_CKJ__c(
            LLC_BI__CFG_ConfigKeys__c = cfk.Id,
            LLC_BI__CFG_ConfigValue__c = cvdm.Id
        );
        configJoins.add(cm_join3);

        LLC_BI__CFG_CKJ__c ckj1 = new LLC_BI__CFG_CKJ__c(
            LLC_BI__CFG_ConfigKeys__c = cfk.Id,
            LLC_BI__CFG_ConfigValue__c = ccfv1.Id
        );
        configJoins.add(ckj1);

        LLC_BI__CFG_CKJ__c ckj2 = new LLC_BI__CFG_CKJ__c(
            LLC_BI__CFG_ConfigKeys__c = cfk.Id,
            LLC_BI__CFG_ConfigValue__c = ccfv2.Id
        );
        configJoins.add(ckj2);

        LLC_BI__CFG_CKJ__c ckj3 = new LLC_BI__CFG_CKJ__c(
            LLC_BI__CFG_ConfigKeys__c = cfk2.Id,
            LLC_BI__CFG_ConfigValue__c = cvpt2.Id
        );
        configJoins.add(ckj3);

        LLC_BI__CFG_CKJ__c ckj4 = new LLC_BI__CFG_CKJ__c(
            LLC_BI__CFG_ConfigKeys__c = cfk.Id,
            LLC_BI__CFG_ConfigValue__c = ccfv3.Id
        );
        configJoins.add(ckj4);

        insert configJoins;
    }

    private static List<LLC_BI__Legal_Entities__c> performEntitiesSetup(Map<String,Id> acctLoanMap, Integer acctIndex, Integer loanIndex){
        List<LLC_BI__Legal_Entities__c> entities = new List<LLC_BI__Legal_Entities__c>();
        for (Integer counter = 0; counter < 6; counter++) {
            entities.add(
                addLegalEntity(
                    acctLoanMap.get(accounts[acctIndex]),
                    acctLoanMap.get(loans[loanIndex][counter]),
                    borrowerTypes[counter],
                    ownershipPercentage[counter],
                    null,
                    false
                )
            );
        }
        return entities;
    }

    private static String generateGuid(){
        String returnVal = Math.random() + '';
        returnVal = returnVal.replace('0.', '42');
        return returnVal.substring(0,Math.min(returnVal.length(),17));
    }

    private static final String KEY_VALUE_DELIMITER = '=';
    private static final String PARAMETER_DELIMITER = ';';
    private static final String DIRECT_EXPOSURE_NAME = 'Booked Direct Exposure';
    private static final String INDIRECT_EXPOSURE_NAME = 'Booked Indirect Exposure';
    private static final String COMMITTED_DIRECT_EXPOSURE_NAME = 'Committed Direct Exposure';
    private static final String COMMITTED_INDIRECT_EXPOSURE_NAME = 'Committed Indirect Exposure';
    private static final String PROPOSED_DIRECT_EXPOSURE_NAME = 'Proposed Direct Exposure';
    private static final String PROPOSED_INDIRECT_EXPOSURE_NAME = 'Proposed Indirect Exposure';
    private static final String TOTAL_NET_NEW_FUNDS_NAME = 'Total Net New Funds';
    private static final String STATISTICS_EXPOSURE_CALCULATOR_CLASS = LLC_BI.StatisticsExposureCalculator.class.getName();
    private static final String CATEGORY = 'Statistics';
    private static final String DIRECT_EXPOSURE = Account.LLC_BI__Direct_Exposure__c.getDescribe().getName();
    private static final String INDIRECT_EXPOSURE = Account.LLC_BI__Indirect_Exposure__c.getDescribe().getName();
    private static final String COMMITTED_DIRECT_EXPOSURE = Account.LLC_BI__Committed_Direct_Exposure__c.getDescribe().getName();
    private static final String COMMITTED_INDIRECT_EXPOSURE = Account.LLC_BI__Committed_Indirect_Exposure__c.getDescribe().getName();
    private static final String PROPOSED_DIRECT_EXPOSURE = Account.LLC_BI__Proposed_Direct_Exposure__c.getDescribe().getName();
    private static final String PROPOSED_INDIRECT_EXPOSURE = Account.LLC_BI__Proposed_Indirect_Exposure__c.getDescribe().getName();
    private static final String TOTAL_NET_NEW_FUNDS = Account.LLC_BI__Total_Net_New_Funds__c.getDescribe().getName();
    private static final String DIRECT_EXPOSURE_LABEL_KEY = 'Statistics_Direct_Exposure';
    private static final String INDIRECT_EXPOSURE_LABEL_KEY = 'Statistics_Indirect_Exposure';
    private static final String COMMITTED_DIRECT_EXPOSURE_LABEL_KEY = 'Statistics_Committed_Direct_Exposure';
    private static final String COMMITTED_INDIRECT_EXPOSURE_LABEL_KEY = 'Statistics_Committed_Indirect_Exposure';
    private static final String PROPOSED_DIRECT_EXPOSURE_LABEL_KEY = 'Statistics_Proposed_Direct_Exposure';
    private static final String PROPOSED_INDIRECT_EXPOSURE_LABEL_KEY = 'Statistics_Proposed_Indirect_Exposure';
    private static final String TOTAL_NET_NEW_FUNDS_LABEL_KEY = 'Statistics_Total_Net_New_Funds';
    private static final String ACCOUNT_CLASS_NAME = Account.sObjectType.getDescribe().getName();
    private static final String LAST_CALC_FIELD = Account.LLC_BI__Last_Exposure_Calc_Date__c.getDescribe().getName();
    private static final String BORROWER_TYPE_KEY = 'BorrowerType';
    private static final String CLOSED_FUNDED_KEY = 'EnforceClosedFunded';
    private static final String INCLUDE_RENEWED_LOANS_KEY = 'IncludeRenewedLoans';
    private static final String STAGE_KEY = 'Stage';
    private static final String STATUS_KEY = 'Status';
    private static final String USE_OWNERSHIP_KEY = 'UseOwnership';
    private static final String USE_PRINCIPAL_BALANCE_KEY = 'Statistics Use Principal Balance in Calculation';
    private static final String BORROWERS_VALUE = 'Borrower,Co-Borrower';
    private static final String GUARANTORS_VALUE = 'Guarantor,Limited Guarantor';
    private static final String COMMITTED_STAGES_VALUE = 'Processing,Doc Prep,Doc Review,Closing,Compliance';
    private static final String PROPOSED_STAGES_VALUE = 'Proposal,Credit Underwriting,Loan Committee';
    private static final String OPEN_STATUS_VALUE = 'Open';
    private static final String POSITIVE_CASE_VALUE = 'true';
    private static final String NEGATIVE_CASE_VALUE = 'false';
    private static final String ACCOUNT_NAME_1 = 'TestAccount1 - ' + 'TestRelationshipStatisticsCalculator';
    private static final String LOAN_NAME_11 = 'TestLoan11 - TestRelationshipStatisticsCalculator';
    private static final String LOAN_NAME_12 = 'TestLoan12 - TestRelationshipStatisticsCalculator';
    private static final String LOAN_NAME_13 = 'TestLoan13 - TestRelationshipStatisticsCalculator';
    private static final String LOAN_NAME_14 = 'TestLoan14 - TestRelationshipStatisticsCalculator';
    private static final String LOAN_NAME_15 = 'TestLoan15 - TestRelationshipStatisticsCalculator';
    private static final String LOAN_NAME_16 = 'TestLoan16 - TestRelationshipStatisticsCalculator';
    private static final String ACCOUNT_NAME_2 = 'TestAccount2 - TestRelationshipStatisticsCalculator';
    private static final String LOAN_NAME_21 = 'TestLoan21 - TestRelationshipStatisticsCalculator';
    private static final String LOAN_NAME_22 = 'TestLoan22 - TestRelationshipStatisticsCalculator';
    private static final String LOAN_NAME_23 = 'TestLoan23 - TestRelationshipStatisticsCalculator';
    private static final String LOAN_NAME_24 = 'TestLoan24 - TestRelationshipStatisticsCalculator';
    private static final String LOAN_NAME_25 = 'TestLoan25 - TestRelationshipStatisticsCalculator';
    private static final String LOAN_NAME_26 = 'TestLoan26 - TestRelationshipStatisticsCalculator';
    private static final String ACCOUNT_NAME_3 = 'TestAccount3 - TestRelationshipStatisticsCalculator';
    private static final String LOAN_NAME_31 = 'TestLoan31 - TestRelationshipStatisticsCalculator';
    private static final String ACCOUNT_NAME_4 = 'TestAccount4 - TestRelationshipStatisticsCalculator';
    private static final String LOAN_NAME_41 = 'TestLoan41 - TestRelationshipStatisticsCalculator';
    private static final String LOAN_NAME_42 = 'TestLoan42 - TestRelationshipStatisticsCalculator';
    private static final String PRODUCT_NAME_1 = 'TestRelationshipStatisticsCalculator Product 1';
    private static final String PRODUCT_NAME_2 = 'TestRelationshipStatisticsCalculator Product 2';
    private static final String PRODUCT_EXT_NAME_1 = 'NotLineOfCredit';
    private static final String PRODUCT_EXT_NAME_2 = 'LineOfCredit';
    private static final String PRODUCT_LINE_NAME_1 = 'TestRelationshipStatisticsCalculator Product Line 1';
    private static final String PRODUCT_TYPE_NAME_1 = 'TestRelationshipStatisticsCalculator Product Type 1';
    private static final String PRODUCT_TYPE_NAME_2 = 'TestRelationshipStatisticsCalculator Product Type 2';
    private static final String BORROWER_TYPE_BORROWER = 'Borrower';
    private static final String BORROWER_TYPE_COBORROWER = 'Co-Borrower';
    private static final String BORROWER_TYPE_GUARANTOR = 'Guarantor';
    private static final String BORROWER_TYPE_LIMITED_GUARANTOR = 'Limited Guarantor';
    private static final String DIRECT_TYPE = 'Direct';
    private static final String INDIRECT_TYPE = 'Indirect';
    private static final String NET_FUNDS_TYPE = 'Net Funds';

    private static final String
        TOTAL_EXPOSURE_CATEGORY = 'Total Exposure Configuration',
        ENABLE_STATISTICS = 'EnableStatisticPopulation',
        EXPOSURE_PROPERTY_DESCRIPTION = 'This system property controls whether or not a  total exposure will ' +
            'generate statistics records. When set to true statistics records will be generated. ' +
            'When set to false statistics records will not be generated';

    private static final List<Decimal> ownershipPercentage = new List<Decimal>
    {
        100.0,
        null,
        50.0,
        null,
        100.0,
        100.0
    };
    private static final String[] accounts = new String[]
    {
        ACCOUNT_NAME_1,
        ACCOUNT_NAME_2
    };
    private static final List<List<String>> loans = new List<List<String>>
    {
        new List<String>{LOAN_NAME_11,LOAN_NAME_12,LOAN_NAME_13,LOAN_NAME_14,LOAN_NAME_15,LOAN_NAME_16},
        new List<String>{LOAN_NAME_21,LOAN_NAME_22,LOAN_NAME_23,LOAN_NAME_24,LOAN_NAME_25,LOAN_NAME_26}
    };
    private static final List<String>borrowerTypes = new List<String>
    {
        BORROWER_TYPE_BORROWER,
        BORROWER_TYPE_GUARANTOR,
        BORROWER_TYPE_BORROWER,
        BORROWER_TYPE_GUARANTOR,
        BORROWER_TYPE_BORROWER,
        BORROWER_TYPE_LIMITED_GUARANTOR
    };

}