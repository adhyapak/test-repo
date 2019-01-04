global class RunCallout implements Database.Batchable<Id>, Database.AllowsCallouts {
    public Id loanId {get;set;}
    public String sessId {get;set;}
 
    global RunCallout(Id loanId, String sessId) {
        this.loanId = loanId;
        this.sessId = sessId;
    }
 
    global Iterable<Id> start(Database.BatchableContext bc) {
        return (Iterable<Id>)new List<ID>{this.loanId};
    }
    
    global void execute(Database.BatchableContext BC, List<Id> accountIds){
        
    }
    
    global void finish(Database.BatchableContext BC){
    
    LLC_BI.LoanAutoDecisionController.generateDecision(this.loanId, this.sessId);
    
    }
}