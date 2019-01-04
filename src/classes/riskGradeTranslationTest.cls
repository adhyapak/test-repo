@isTest
private class riskGradeTranslationTest
{
    @isTest
    static void checkValuesSuccess()
    {
        //FinalRiskGradeCalc__c         
        LLC_BI__Risk_Grade_Template__c testTemplate = createRiskGradeTemplate();
        Account testAccount = createAccount();
        LLC_BI__Annual_Review__c testReview = createReview(testAccount.Id, 'testComments1', testTemplate.Id);
        String gradingTest = '';
        
        ApexPages.StandardController eCon = new ApexPages.StandardController(testReview);
        riskGradeTranslation poller = new riskGradeTranslation(eCon);
        
        //Providing just enough information to pass the checks
        Test.startTest();    
        poller.RecordId = testReview.Id;
        poller.Grade = testReview.NFCU_Grading__c;
        gradingTest = poller.getGrade();
        
        poller.refreshGrade();
        Test.stopTest();
    }



    private static Account createAccount()
    {
        Account newAccount = new Account(Name = 'TestAcct');
        insert newAccount;
        return newAccount;
    }

    private static LLC_BI__Annual_Review__c createReview(Id acct, String grade, Id rrtemp)
    {
        LLC_BI__Annual_Review__c newReview = new LLC_BI__Annual_Review__c(LLC_BI__Account__c = acct,  LLC_BI__Risk_Grade_Template__c = rrtemp);
        insert newReview;
        return newReview;
    }
    
    private static LLC_BI__Risk_Grade_Template__c createRiskGradeTemplate()
    {
        LLC_BI__Risk_Grade_Template__c newRiskGradeTemplate = new LLC_BI__Risk_Grade_Template__c(Name = 'TestRGTemplate', LLC_BI__Template_Object_Type__c = 'Account');
        insert newRiskGradeTemplate;
        return newRiskGradeTemplate;
    }    
}