@isTest
private class  LoanTeamManagerExtensionTest {
    static testMethod void LoanTeamManagerExtensionTestMethod(){
          User myUser = [SELECT Id, Alias, LastName FROM User WHERE Id =: UserInfo.getUserId()];
         
          LLC_BI__Loan__c loan = new LLC_BI__Loan__c();
          loan.Name = 'loan Test';
          loan.LLC_BI__Amount__c = 100;
          loan.LLC_BI__Status__c = 'Open';
          insert loan;

          LLC_BI__Role__c role1 = new LLC_BI__Role__c();
          role1.LLC_BI__Type__c = 'Team_Member__c';
          role1.Name = 'Credit UnderWriter';
          // role1.LLC_BI__Loan__c = loan.Id;
          insert role1;   

          LLC_BI__Role__c role2 = new LLC_BI__Role__c();
          role2.LLC_BI__Type__c = 'Team_Member__c';
          role2.Name = 'Loan Officer';
          // role2.LLC_BI__Loan__c = loan.Id;
          insert role2;             

          LLC_BI__LoanTeam__c loanTeamMember1 = new LLC_BI__LoanTeam__c();
          loanTeamMember1.LLC_BI__Loan__c = loan.Id;
          loanTeamMember1.LLC_BI__Assigned_Role__c = role1.Id;
          loanTeamMember1.LLC_BI__User__c = myUser.Id;
          insert loanTeamMember1;

     //     LLC_BI__LoanTeam__c loanTeamMember2 = new LLC_BI__LoanTeam__c();
      //    loanTeamMember1.LLC_BI__Loan__c = loan.Id;
      //    loanTeamMember1.LLC_BI__Assigned_Role__c = role2.Id;
      //    loanTeamMember1.LLC_BI__User__c = myUser.Id;
      //    insert loanTeamMember2;
        
          LLC_BI__LoanTeam__c loanTeamMember = new LLC_BI__LoanTeam__c();
        loanTeamMember.LLC_BI__Loan__c  = loan.Id;
        
          ApexPages.StandardController sController = new ApexPages.StandardController(loan);
        LoanTeamManagerExtension loanTeamExtension = new LoanTeamManagerExtension(sController);
        
        
        LoanTeamManagerExtension.loanTeamWrapper loanTeam = new LoanTeamManagerExtension.loanTeamWrapper(loanTeamMember1);
        loanTeam.selected = true;
        // insert.loanTeam;
        
        loanTeamExtension.getLoanTeamMembers();
        loanTeamExtension.newLoanTeamMember=loanTeamMember;
        loanTeamExtension.getRole();
        loanTeamExtension.getUser();
        loanTeamExtension.getSelected();
        loanTeamExtension.addLoanTeamMember();
        loanTeamExtension.updateTeamMembers();      
        loanTeamExtension.removeTeamMembers();      
     }     
}