global class CBPerformDepositBatchable extends CBEntities implements Database.Batchable<CBDepositCalloutInputParams>, Database.AllowsCallouts {

    @TestVisible private class BatchableException extends Exception {}
    
    @testVisible
    private static Boolean forceTestingException = false;
    
    @testVisible
    private ICBOrchestrator orchestrator = new CBOrchestrator();

    List<CBDepositCalloutInputParams> items = new List<CBDepositCalloutInputParams>();

    global CBPerformDepositBatchable(List<CBDepositCalloutInputParams> items) {this.items = items;}

    global Iterable<CBDepositCalloutInputParams> start(Database.BatchableContext bc) {
        return (Iterable<CBDepositCalloutInputParams>)this.items;
    }
    
    global void execute(Database.BatchableContext BC, List<CBDepositCalloutInputParams> items){
        List<CBEntities.CoreBookingResponse> resArr = new List<CBEntities.CoreBookingResponse>();
        
        for(CBDepositCalloutInputParams c : items){
        
            CBEntities.CoreBookingResponse res = new CBEntities.CoreBookingResponse();
            try{
                if(forceTestingException)
                    throw new BatchableException('forceTestingException');
                res = orchestrator.BookDeposit(c.depositId, c.requestedByUserId, c.userSessionId, c.externalReferenceId);
            } catch(Exception ex) {
                res.Messages = String.format(System.Label.CBSendServiceOrchestrationException, 
                    new String[]{
                        System.Label.DepositBooking,
                        ex.getMessage()
                    });
            }  
            
            resArr.add(res);

        }
        
        System.debug(resArr);
        
    }
    global void finish(Database.BatchableContext BC){}
    
}