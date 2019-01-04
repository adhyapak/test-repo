global class CBPerformLoanBatchable extends CBEntities implements Database.Batchable<CBLoanCalloutInputParams>, Database.AllowsCallouts {

    @TestVisible private class BatchableException extends Exception {}
    
    @testVisible
    private static Boolean forceTestingException = false;
    
    @testVisible
    private ICBOrchestrator orchestrator = new CBOrchestrator();

    List<CBLoanCalloutInputParams> items = new List<CBLoanCalloutInputParams>();

    global CBPerformLoanBatchable(List<CBLoanCalloutInputParams> items) {this.items = items;}

    global Iterable<CBLoanCalloutInputParams> start(Database.BatchableContext bc) {
        return (Iterable<CBLoanCalloutInputParams>)this.items;
    }
    
    global void execute(Database.BatchableContext BC, List<CBLoanCalloutInputParams> items){
        List<CBEntities.CoreBookingResponse> resArr = new List<CBEntities.CoreBookingResponse>();
        
        for(CBLoanCalloutInputParams c : items){
        
            CBEntities.CoreBookingResponse res = new CBEntities.CoreBookingResponse();
            try{
                if(forceTestingException)
                    throw new BatchableException('forceTestingException');
                res = orchestrator.BookLoan(c.loanId, c.requestedByUserId, c.userSessionId, c.externalReferenceId);
            } catch(Exception ex) {
                res.Messages = String.format(System.Label.CBSendServiceOrchestrationException, 
                    new String[]{
                        System.Label.LoanBooking,
                        ex.getMessage()
                    });
            }  
            
            resArr.add(res);

        }
        
        System.debug(resArr);
        
    }
    global void finish(Database.BatchableContext BC){}
    
}