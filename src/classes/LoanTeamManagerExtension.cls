public with sharing class LoanTeamManagerExtension{
    
    LLC_BI__Loan__c loanObj;
    public String loanName { get; set; }
    public Id objId = ApexPages.currentPage().getParameters().get('id');

    public list<loanTeamWrapper> loanTeamMemberList = new list<loanTeamWrapper>();
    public list<LLC_BI__LoanTeam__c> selectedTeamMembers = new list<LLC_BI__LoanTeam__c>();
    public list<LLC_BI__LoanTeam__c> removeTeamMembers = new list<LLC_BI__LoanTeam__c>();
    public list<LLC_BI__LoanTeam__c> updateTeamMembers = new list<LLC_BI__LoanTeam__c> ();  
    public list <LLC_BI__LoanTeam__c> currentTeamMembers = new list<LLC_BI__LoanTeam__c>();
    public Integer ltmCount {get; set;}
    boolean flag = false ;  
    
    public LLC_BI__LoanTeam__c newLoanTeamMember { get; set; }
    list<LLC_BI__LoanTeam__c> tempLoanTeam = new list<LLC_BI__LoanTeam__c>();   

    public LoanTeamManagerExtension (ApexPages.StandardController controller) {
        loanObj=(LLC_BI__Loan__c)controller.getRecord();
        newLoanTeamMember = new LLC_BI__LoanTeam__c();
        currentTeamMembers = [SELECT Id, Name FROM LLC_BI__LoanTeam__c WHERE LLC_BI__Loan__c =: objId];
        ltmCount = currentTeamMembers.size();
    }

    public String getCurrentLoanId() {
        return objId;
    }

    public String getCurrentLoanName() {
        LLC_BI__Loan__c loan = [SELECT Id, Name FROM LLC_BI__Loan__c WHERE Id =: objId];
        String loanName = loan.Name;
        return loanName;
    }

    public List<selectOption> getUser() {
        List<selectOption> options = new List<selectOption>(); 
        options.add(new selectOption('', '- None  -')); 
        for (User user :[SELECT Id, Name, UserRoleId, Title FROM User WHERE IsActive = true AND (NOT Name LIKE 'ncino%') ORDER BY Name ]){ 
            options.add(new selectOption(user.Id, user.Name + ' - ' + user.Title));
        }
        return options;    
    }

    public List<selectOption> getRole() {
        List<selectOption> options = new List<selectOption>(); 
        options.add(new selectOption('', '- None  -')); 
        for (LLC_BI__Role__c role :[SELECT Id, Name, LLC_BI__Description__c,  LLC_BI__Type__c FROM LLC_BI__Role__c ORDER BY Name ]){ 
            options.add(new selectOption(role.Id, role.Name));
        }
        return options;    
    }

    public list<loanTeamWrapper> getLoanTeamMembers(){   
        loanTeamMemberList.clear();
        for(LLC_BI__LoanTeam__c ltm : 
            [select Id, 
                Name, 
                LLC_BI__Loan__c, 
                LLC_BI__Assigned_Role__c, 
                LLC_BI__User__c
            from LLC_BI__LoanTeam__c 
            where  LLC_BI__Loan__c= :loanObj.Id 
            order by LLC_BI__Assigned_Role__c]){
            loanTeamMemberList.add(new loanTeamWrapper(ltm));
            //Secondary_Team_Member__c,
            //Assign_Delegate__c, Delegate_Team_Member__c 
            if(loanTeamMemberList.size() > 0)
            {
                flag = true;
            }
        }
        return loanTeamMemberList;
    }

    public PageReference getSelected(){
        selectedTeamMembers.clear();
        for(loanTeamWrapper loTmWrTemp : loanTeamMemberList )
            if(loTmWrTemp.selected == true)
                selectedTeamMembers.add(loTmWrTemp.loTmWr);
        return null;
    }

    public class loanTeamWrapper{
        public LLC_BI__LoanTeam__c loTmWr{get; set;}
        public boolean selected {get; set;} 
        public loanTeamWrapper(LLC_BI__LoanTeam__c loanTeamMember)
        {
            loTmWr = loanTeamMember;
            selected = false;
        }
    }

    public PageReference addLoanTeamMember() {

        if(newLoanTeamMember.LLC_BI__User__c==null){
            //ApexPages.addmesage(new ApexPages.message(ApexPages.severity.ERROR, 'You must assign a User as the Loan Team Member'));
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Please select a User as the Loan Team Member'));
            return null;
        }

        else if(newLoanTeamMember.LLC_BI__Assigned_Role__c==null){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Please select a Role for the Loan Team Member.'));
            return null;
        }

        else{
            LLC_BI__LoanTeam__c newLTM = new LLC_BI__LoanTeam__c();
            newLTM.LLC_BI__Loan__c= loanObj.Id;
            newLTM.LLC_BI__Assigned_Role__c = newLoanTeamMember.LLC_BI__Assigned_Role__c;
            newLTM.LLC_BI__User__c = newLoanTeamMember.LLC_BI__User__c;
           // newLTM.Assign_Delegate__c = newLoanTeamMember.Assign_Delegate__c;
           // newLTM.Delegate_Team_Member__c = newLoanTeamMember.Delegate_Team_Member__c;
            insert newLTM;

            newLoanTeamMember.LLC_BI__Assigned_Role__c = null;
            newLoanTeamMember.LLC_BI__User__c = null;
           // newLTM.Assign_Delegate__c = null;
           // newLTM.Delegate_Team_Member__c = null;
            return null;
        }
    }

    public PageReference updateTeamMembers() {
            PageReference returnPage = new PageReference('/' + objId);
            system.debug('loanTeamMemberList-->>'+loanTeamMemberList);
            system.debug('objId + loanobj' + objId + 'MARKER' + loanObj);
            for(loanTeamWrapper loTmWrTemp : loanTeamMemberList)
                if(loTmWrTemp.selected == true)
                    updateTeamMembers.add(loTmWrTemp.loTmWr);
            update updateTeamMembers;
            system.debug('loanTeamMemberList-->>  '+ updateTeamMembers);
            updateTeamMembers.clear();
            return returnPage;
    }

    public pagereference removeTeamMembers() {
        for(loanTeamWrapper loTmWrTemp : loanTeamMemberList){
            if(loTmWrTemp.selected == true)
                removeTeamMembers.add(loTmWrTemp.loTmWr);
        }
        delete  removeTeamMembers;
            removeTeamMembers.clear();
        return null;
    }

}