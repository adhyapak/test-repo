@isTest
public class ltm_RedirectControllerTest {
	@isTest
	public static void initialize() {

    	LLC_BI__Loan__c testLoan = createLoan('Test Loan1', 'Qualification', 'Open', 'Commercial', null);
        LLC_BI__Role__c testRole = createRole('Test Role', 'Test Description');
        User testUser = [
                SELECT Id, Name, UserRole.Name
                FROM User WHERE IsActive = true
                LIMIT 1
            ];
        ApexPages.StandardController sc = new ApexPages.standardController(testRole);
        ltm_RedirectController loanTeamPage = new ltm_RedirectController(sc); 

        LLC_BI__LoanTeam__c ltm = new LLC_BI__LoanTeam__c();
        ltm.LLC_BI__Loan__c = testLoan.Id;
        ltm.LLC_BI__Assigned_Role__c = testRole.Id;
        ltm.LLC_BI__User__c = testUser.Id;
        insert ltm;
        loanTeamPage.getRole();
        loanTeamPage.getUser();
        loanTeamPage.saveAndReturn();
        LLC_BI__LoanTeam__c existingLtm =ltm;
        LLC_BI__LoanTeam__c ltm2 = new LLC_BI__LoanTeam__c();
        ltm2.LLC_BI__Loan__c = existingLtm.LLC_BI__Loan__c;
        ltm2.LLC_BI__Assigned_Role__c = existingLtm.LLC_BI__Assigned_Role__c;
        ltm2.LLC_BI__User__c = existingLtm.LLC_BI__User__c;
        ltm2.LLC_BI__Team_Role__c = ltm.LLC_BI__Team_Role__c;
    }
    
    private static LLC_BI__Loan__c createLoan(String tName, String stage, String status, String pLine, Id branchId) {

		LLC_BI__Loan__c newL = new LLC_BI__Loan__c(
			Name = tName,
			LLC_BI__Stage__c = stage,
			LLC_BI__Status__c = status,
			LLC_BI__Product_Line__c = pLine,
			LLC_BI__Branch__c = branchId,
			LLC_BI__Current_Interest_Rate__c = 5.0,
			LLC_BI__Initial_Advance__c = 0,
			LLC_BI__Funding_at_Close__c = 0,
			LLC_BI__Monthly_Payment__c = 0,
			LLC_BI__Total_Fee_Income__c = 0,
			LLC_BI__Guarantee_Fee_Paid__c = false,
			LLC_BI__Non_Accrual__c = false,
			LLC_BI__TDR__c = false
			);

		Database.insert(newL);
		return newL;
	}
    
    private static LLC_BI__Role__c createRole(String rName, String rDescription) {
        
        LLC_BI__Role__c newR = new LLC_BI__Role__c(
            Name = rName,
            LLC_BI__Description__c = rDescription
        );
        
        Database.insert(newR);
        return newR;
    }
}