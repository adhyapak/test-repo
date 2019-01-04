public class CSA_LoanAccountRiskRatingController {
    public LLC_BI__Loan__c loan {get;Set;}
    public Id loanId {get;set;}
    public String loanName {get;set;}
    public String selectedAccount {get;Set;}
    public Id rrId {get;Set;}
            
    public CSA_LoanAccountRiskRatingController() {
        this.loan = this.getLoan(ApexPages.currentPage().getParameters().get(PARAMETER_NAME));
        this.loanId = loan.Id;
        this.loanName = loan.Name;
    }

    public PageReference loanRiskRatingSave() {
        if (String.ISNOTBLANK(this.loan.Risk_Rating_Template__c) && String.ISNOTBLANK(this.selectedAccount)) {
            try {           
                Database.update(this.loan);

                LLC_BI__Annual_Review__c newAR = new LLC_BI__Annual_Review__c(
                    LLC_BI__Loan__c = this.loanId,
                    LLC_BI__Account__c = this.selectedAccount);

                try {           
                    Database.insert(newAR);
                    System.debug('add the ***'+newAR.Id);
                    rrId = newAR.Id;

                    PageReference pageRef = this.getRiskRatingPageURL(this.loanId, newAR.Id);
                    return pageRef;
                } catch(Exception e) {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
                }
            } catch(Exception e) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
            }
        } else {
            if (String.ISBLANK(this.loan.Risk_Rating_Template__c)) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.Risk_Rating_Selector_Template_Error_Msg));
            }
            if (String.ISBLANK(this.selectedAccount)) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.Risk_Rating_Selector_Account_Error_Msg));
            }
        }
        return null;
    }

    public PageReference getRiskRatingPageURL(Id recordId, Id arId) {
        try{
            PageReference pageRef;
            nFORCE.RouteController rc = new nFORCE.RouteController();
            nFORCE__Route__c route = rc.getDashboardRoute();

            String app = route != null ? route.nFORCE__App__c : null;
            if(String.isNotBlank(app)){
                
                pageRef = new PageReference(System.Label.Risk_Rating_Selector_Save_URL_UI + recordId);
            } else {
                pageRef = new PageReference(SLASH + arId);
            }
            pageRef.setRedirect(true);
            return null;
        } catch (Exception e){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
        }
        return null;
    }

    private LLC_BI__Loan__c getLoan(Id recordId) {
        return [
            SELECT
                Id,
                Name,
                Risk_Rating_Template__c
            FROM
                LLC_BI__Loan__c
            WHERE
                Id = :recordId LIMIT 1];
    }

    public List<SelectOption> getAccounts() {
        List<SelectOption> newSO = new List<SelectOption>();
        //Modifying as test class is failing.  Chintan Adhyapak, West Monroe Partners. 4/22/2018
        Map<Id, String> accountMap = new Map<Id, String>();

        newSO.add(new SelectOption(BLANK, NONE_SELECT_OPTION));

        for (LLC_BI__Legal_Entities__c l: this.getLegalEntities(this.loanId)) {
            //Adding to Map. Chintan Adhyapak, West Monroe Partners. 4/22/2018
            accountMap.put(l.LLC_BI__Account__c, l.LLC_BI__Account__r.Name);
            //newSO.add(new SelectOption(l.LLC_BI__Account__c, l.LLC_BI__Account__r.Name));
        }
        System.debug('CPA accountMap is: ' + accountMap);
        for (Id accountId : accountMap.keySet()) {
            newSO.add(new SelectOption(accountId, accountMap.get(accountId)));
        }
        
        return newSO;
    }

    private List<LLC_BI__Legal_Entities__c> getLegalEntities(Id recordId) {
        return [
            SELECT 
                Id, 
                LLC_BI__Account__c,
                LLC_BI__Account__r.Name 
            FROM 
                LLC_BI__Legal_Entities__c 
            WHERE 
                LLC_BI__Loan__c =: recordId AND LLC_BI__Account__r.RecordTypeId = '012f40000001l8g'];
    }

    public Boolean getIsHelpTextAccount() {
        return String.isNotBlank(this.getFieldResult(LLC_BI__Legal_Entities__c.LLC_BI__Account__c.getDescribe()).getInlineHelpText());
    }

    public Boolean getIsHelpTextRiskTemplate() {
        return String.isNotBlank(this.getFieldResult(LLC_BI__Loan__c.Risk_Rating_Template__c.getDescribe()).getInlineHelpText());
    }

    public String getHelpTextAccount() {
        return this.getFieldResult(LLC_BI__Legal_Entities__c.LLC_BI__Account__c.getDescribe()).getInlineHelpText();
    }

    public String getHelpTextRiskTemplate() {
        return this.getFieldResult(LLC_BI__Loan__c.Risk_Rating_Template__c.getDescribe()).getInlineHelpText();
    }

    private Schema.DescribeFieldResult getFieldResult(Schema.DescribeFieldResult result) {
        return result;
    }

    private static final String PARAMETER_NAME = 'id';
    private static final String BLANK = '';
    private static final String NONE_SELECT_OPTION = '-- None --';
    private static final String SLASH = '/';
}