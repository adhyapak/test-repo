global with sharing virtual class ExperianCalloutBase {

    /**
    * Request Credit Report Input Parameter values
    */
    global class ExperianCalloutInputParams {
        /**
        * The requesting loan Id
        */
        @invocableVariable(required = true
            label = 'relationshipId'
            description = 'Is the relationship id to be used for the context base for the credit pull.')
        global String relationshipId;
        
        /**
        * The requesting loan Id
        */
        @invocableVariable(required = true
            label = 'userSessionId'
            description = 'Is the users session id since the future callout will not have context of that through batch.')
        global String userSessionId;
        
        /**
        * The requesting user Id
        */
        @invocableVariable(required = false
            label = 'requestedByUserId'
            description = 'Is the user id requesting the log to be created - used only during the log creation.')
        global String requestedByUserId;
        /**
        * The external reference id    
        */
        @invocableVariable(required = false
            label = 'externalReferenceId'
            description = 'Is the external reference id for the log that has been created as a placeholder for the flow, leave blank if you do not require it for your flow use')
        global String externalReferenceId;
        
        
    }

    
}