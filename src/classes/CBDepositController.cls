global with sharing class CBDepositController {
    
    public CBDepositController(ApexPages.StandardController acon){
    }
    
    @TestVisible private class ControllerException extends Exception {}
    
    @testVisible
    private static Boolean forceTestingException = false;
    
    @testVisible
    private static ICBOrchestrator orchestrator = new CBOrchestrator();
    
    @RemoteAction
    global static CBEntities.TransactionLogResponse getTransactionStatus(String externalId){
        return orchestrator.GetTransactionLogDetails(externalId);
    }
    
    @RemoteAction
    global static CBEntities.CoreBookingResponse bookDeposit(String depositId){
        CBEntities.CoreBookingResponse res = new CBEntities.CoreBookingResponse();
        try{
            
            res = orchestrator.BookDeposit(depositId, null, null, null);
            
            if(forceTestingException)
                throw new ControllerException();
                
        }catch(Exception e){
            res.IsSuccessful = false;
            res.Messages = String.format(System.Label.CBSendServiceOrchestrationException, 
                    new String[]{
                        System.Label.DepositBooking,
                        e.getMessage()
                    });
        }
        return res;
    }
}