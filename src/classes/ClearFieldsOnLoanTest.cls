@isTest
public class ClearFieldsOnLoanTest {
	 static LLC_BI__Loan__c testSetup(){
        ///create test account and loan
        Account testAccount = new Account(Name='Testing Account');
        insert testAccount;
    
        LLC_BI__Loan__c Loan = new LLC_BI__Loan__c(Name='Testing Loan', LLC_BI__Account__c=testAccount.Id);
        
        //insert Loan;
        return Loan;
    }
    
    static testMethod void testCopy()
    {
        LLC_BI__Loan__c testLoanCopy = testSetup();
        testLoanCopy.LLC_BI__Is_Copy__c = true;
        insert testLoanCopy;
        
        set<String> fieldSet = new Set<String>();
    	for(Schema.FieldSetMember fields : Schema.SObjectType.LLC_BI__Loan__c.fieldsets.getMap().get('ClearFields_Copy').getFields())
    	{
        	fieldSet.add(fields.getFieldPath());
    	}
        
        for(String s : fieldSet)
        {
            if(testLoanCopy.get(s) == true || testLoanCopy.get(s) == false)
            {
                System.assert(testLoanCopy.get(s) == false);
            }
            else
            {
                System.assert(testLoanCopy.get(s) == null);
            } 
        }
    }
    
    static testMethod void testRenewMod()
    {
        LLC_BI__Loan__c testLoanRenewMod = testSetup();
        testLoanRenewMod.LLC_BI__isRenewal__c = true;
        insert testLoanRenewMod;
        
        set<String> fieldSet = new Set<String>();
    	for(Schema.FieldSetMember fields : Schema.SObjectType.LLC_BI__Loan__c.fieldsets.getMap().get('ClearFields_Renew_Mod').getFields())
    	{
        	fieldSet.add(fields.getFieldPath());
    	}
        
        for(String s : fieldSet)
        {
            if(testLoanRenewMod.get(s) == true || testLoanRenewMod.get(s) == false)
            {
                System.assert(testLoanRenewMod.get(s) == false);
            }
            else
            {
                System.assert(testLoanRenewMod.get(s) == null);
            } 
        }
    }
}