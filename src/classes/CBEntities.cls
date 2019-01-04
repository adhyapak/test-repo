global with sharing virtual class CBEntities {
    
    global class CoreBookingResponse {
        global String Messages {get;set;}
        global Boolean IsSuccessful {get;set;}
        global String TransactionLogExternalId {get;set;}
        global String externalLoanNumber {get;set;}
    }
    
    global class TransactionLogResponse {
        global String ExternalId {get;set;}
        global String Details {get;set;}
        global String Status {get;set;}
        global String VendorStatus {get;set;}
        global Boolean IsComplete {get;set;}
        global Boolean IsSuccessful {get;set;}
    }
    
    global class CBLoanCalloutInputParams {
        
        @invocableVariable(required = true
            label = 'loanId'
            description = 'Is the Salesforce loan id to be used for the context base for the loan booking.')
        global String loanId;
        
        @invocableVariable(required = true
            label = 'userSessionId'
            description = 'Is the users session id since the future callout will not have context of that through batch.')
        global String userSessionId;
        
        @invocableVariable(required = false
            label = 'requestedByUserId'
            description = 'Is the user id requesting the log to be created - used only during the log creation.')
        global String requestedByUserId;
        
        @invocableVariable(required = false
            label = 'externalReferenceId'
            description = 'Is the external reference id for the log that has been created as a placeholder for the flow, leave blank if you do not require it for your flow use')
        global String externalReferenceId;
        
    }
    global class CBCustomerCalloutInputParams {
        
        @invocableVariable(required = true
            label = 'relationshipId'
            description = 'Is the Salesforce relationship id (Account Id) to be used for the context base for the customer booking.')
        global String relationshipId;
        
        @invocableVariable(required = true
            label = 'userSessionId'
            description = 'Is the users session id since the future callout will not have context of that through batch.')
        global String userSessionId;
        
        @invocableVariable(required = false
            label = 'requestedByUserId'
            description = 'Is the user id requesting the log to be created - used only during the log creation.')
        global String requestedByUserId;
        
        @invocableVariable(required = false
            label = 'externalReferenceId'
            description = 'Is the external reference id for the log that has been created as a placeholder for the flow, leave blank if you do not require it for your flow use')
        global String externalReferenceId;
        
    }
    global class CBDepositCalloutInputParams {
        
        @invocableVariable(required = true
            label = 'depositId'
            description = 'Is the Salesforce deposit id to be used for the context base for the deposit booking.')
        global String depositId;
        
        @invocableVariable(required = true
            label = 'userSessionId'
            description = 'Is the users session id since the future callout will not have context of that through batch.')
        global String userSessionId;
        
        @invocableVariable(required = false
            label = 'requestedByUserId'
            description = 'Is the user id requesting the log to be created - used only during the log creation.')
        global String requestedByUserId;
        
        @invocableVariable(required = false
            label = 'externalReferenceId'
            description = 'Is the external reference id for the log that has been created as a placeholder for the flow, leave blank if you do not require it for your flow use')
        global String externalReferenceId;
        
    }
    
}