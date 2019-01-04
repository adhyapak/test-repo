global class CBPerformCustomerBatchable extends CBEntities implements Database.Batchable<CBCustomerCalloutInputParams>, Database.AllowsCallouts {

    @TestVisible private class BatchableException extends Exception {}
    
    @testVisible
    private static Boolean forceTestingException = false;
    
    @testVisible
    private ICBOrchestrator orchestrator = new CBOrchestrator();

    List<CBCustomerCalloutInputParams> items = new List<CBCustomerCalloutInputParams>();

    global CBPerformCustomerBatchable(List<CBCustomerCalloutInputParams> items) {this.items = items;}

    global Iterable<CBCustomerCalloutInputParams> start(Database.BatchableContext bc) {
        return (Iterable<CBCustomerCalloutInputParams>)this.items;
    }
    
    global void execute(Database.BatchableContext BC, List<CBCustomerCalloutInputParams> items){
        List<CBEntities.CoreBookingResponse> resArr = new List<CBEntities.CoreBookingResponse>();
        
        for(CBCustomerCalloutInputParams c : items){
        
            CBEntities.CoreBookingResponse res = new CBEntities.CoreBookingResponse();
            try{
                if(forceTestingException)
                    throw new BatchableException('forceTestingException');
                res = orchestrator.BookCustomer(c.relationshipId, c.requestedByUserId, c.userSessionId, c.externalReferenceId);
            } catch(Exception ex) {
                res.Messages = String.format(System.Label.CBSendServiceOrchestrationException, 
                    new String[]{
                        System.Label.CustomerBooking,
                        ex.getMessage()
                    });
            }  
            
            resArr.add(res);

        }
        
        System.debug(resArr);
        
    }
    global void finish(Database.BatchableContext BC){}
    
}