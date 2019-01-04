@isTest
global class TestRunLoanAutoDecision {
 
  @testSetup
  private static void initialSetup() {
    String engineName = nFORCE.TestARuleEngine.registerUnitTestRuleEngine(
      'nFORCE.FlowRuleEngine:rule-engine',
      MockRuleEngine.class);
    Object p = new nFORCE.ClassInstantiator().instantiate(LLC_BI.RuleEngineDataProvider.class);
    LLC_BI.ALifeCycleDataProvider uiDataProvider = (LLC_BI.ALifeCycleDataProvider) p;
    uiDataProvider.run(false);
    new LLC_BI.LifeCycleDao(uiDataProvider).performAllDml();
    nFORCE__Rule_Engine_Context_Rule__c contextRule = [SELECT ID FROM nFORCE__Rule_Engine_Context_Rule__c WHERE name = 'Loan Auto-Decision'];
    nFORCE__Rule_Engine_Rule__c savedRule = saveRule(
      contextRule,
      'external',
      'description',
      engineName);
  }
 
  private static LLC_BI__Loan__c perTestSetup() {
    status = nFORCE.RuleEngineResult.STATUS_SUCCESS;
 
    List<Account> accts = new List<Account>();
    List<LLC_BI__Legal_Entities__c> entities = new List<LLC_BI__Legal_Entities__c>();
    Account acc1 = new Account(Name = 'corrowername', Type = 'Individual', LLC_BI__FICO_Source__c = 'Experian', LLC_BI__FICO_Credit_Report__c = 'ID', LLC_BI__FICO_Score__c = 800, LLC_BI__Status__c = 'Participation Relationship');
    Account acc2 = new Account(Name = 'coborrowername', Type = 'Individual', LLC_BI__Status__c = 'Participation Relationship');
    Account acc3 = new Account(Name = 'relatedentity', Type = 'Individual');
    accts.add(acc1);
    accts.add(acc2);
    accts.add(acc3);
    insert accts;
 
    LLC_BI__Loan__c loan = new LLC_BI__Loan__c(Name = 'Test Loan', LLC_BI__Account__c = acc1.Id, LLC_BI__Amount__c = 1500);
    insert loan;
 
    LLC_BI__Legal_Entities__c entity1 = new LLC_BI__Legal_Entities__c(LLC_BI__Loan__c = loan.Id, LLC_BI__Account__c = acc1.Id, LLC_BI__Borrower_Type__c = 'Borrower');
    LLC_BI__Legal_Entities__c entity2 = new LLC_BI__Legal_Entities__c(LLC_BI__Loan__c = loan.Id, LLC_BI__Account__c = acc2.Id, LLC_BI__Borrower_Type__c = 'Co-Borrower');
    entities.add(entity1);
    entities.add(entity2);
    insert entities;
 
    return loan;
  }
 
  @isTest
  static void runAutoDecision() {
    LLC_BI__Loan__c loan = perTestSetup();
    List <Id> LoanIdList = new list <Id> ();
    LoanIdList.add(loan.Id);
 
    Test.startTest();
 
    RunLoanAutoDecision.runLoanAutoDesc(LoanIdList);
 
    Test.stopTest();
  }
 
  private static nFORCE__Rule_Engine_Rule__c saveRule(
    nFORCE__Rule_Engine_Context_Rule__c contextRule,
    String externalName,
    String description,
    String engine) {
    nFORCE__Rule_Engine_Rule__c rule = new nFORCE__Rule_Engine_Rule__c();
    rule.nFORCE__Rule_Engine__c = engine;
    rule.nFORCE__Rule_Engine_Rule_Name__c = externalName;
    rule.nFORCE__Rule_Engine_Rule_Reference__c = externalName;
    rule.nFORCE__Description__c = description;
    rule.nFORCE__Rule_Engine_Context_Rule__c = contextRule.Id;
    rule.nFORCE__Start_Date__c = Date.today().addYears(-1);
    rule.nFORCE__End_Date__c = Date.today().addYears(+1);
    insert rule;
    return rule;
  }
 
  global class MockRuleEngine extends nFORCE.TestARuleEngine.ExternalUnitTestRuleEngine {
    public override nFORCE.RuleEngineResult executeRule(nFORCE.RuleEngineRule rule, Map < String, Object > inputParameters) {
      nFORCE.RuleEngineResult result = new nFORCE.RuleEngineResult();
      result.setStatus(status);
      if (status == nFORCE.RuleEngineResult.STATUS_FAILURE) {
        result.addError('Error1');
        result.addError('Error2');
      }
      result.setOutputParameters(TestRunLoanAutoDecision.outputParameters);
      return result;
    }
  }
 
  public static Map <String, Object> outputParameters = new Map <String, Object> ();
  public static String status = nFORCE.RuleEngineResult.STATUS_SUCCESS;
}