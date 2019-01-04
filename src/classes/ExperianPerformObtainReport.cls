global class ExperianPerformObtainReport extends ExperianCalloutBase implements Database.Batchable<ExperianCalloutInputParams>, Database.AllowsCallouts {

    @TestVisible 
    private class XExperianPerformObtainReportException extends Exception {}
    
    @TestVisible
    private static Boolean forceException = false;
    
    List<ExperianCalloutInputParams> items = new List<ExperianCalloutInputParams>();
    
    global ExperianPerformObtainReport(List<ExperianCalloutInputParams> items) {this.items = items;}

    global Iterable<ExperianCalloutInputParams> start(Database.BatchableContext bc) {
        return (Iterable<ExperianCalloutInputParams>)this.items;
    }
    
    global void execute(Database.BatchableContext BC, List<ExperianCalloutInputParams> items){
        
        List<nFUSE__Transaction_Log__c> errorLogsToAdd = new List<nFUSE__Transaction_Log__c>();
        
        for(ExperianCalloutInputParams c : items){
            
            try{
                
                if(forceException)
                {   
                    throw new XExperianPerformObtainReportException('forceException');
                }
                
                //use the send service invoker
                //https://github.com/loanlifecycle/integrations-framework-force/blob/release/src/classes/SendServiceInvoker.cls#L111
                //https://ncinodev.atlassian.net/wiki/display/DEV/Send+Service
                
                List<nFUSE.RequestCreditReport.InputParams> params = new List<nFUSE.RequestCreditReport.InputParams>(); //possible namespace issue
                nFUSE.RequestCreditReport.InputParams param = new nFUSE.RequestCreditReport.InputParams(); //possible namespace issue
                
                param.pluginName = 'Experian_Credit';
                //param.pluginVersion = '1.0';
                //param.transactionLogId = c.externalReferenceId;
                //param.userSalesforceSessionId = c.userSessionId;
                param.accountId = c.relationshipId;
                param.isHardRequest = true;
                
                List<String> props = new List<String>();
                props.add('primary_object_id|'+c.relationshipId);
                props.add('relationshipId|'+c.relationshipId);
                props.add('salesforce_session_id|'+c.userSessionId);
                param.propertyMap = props;
                
                params.add(param);
                
                List<nFUSE.RequestCreditReport.OutputParams> outParams = nFUSE.RequestCreditReport.invoke(params); //possible namespace issue
                
                
            } catch(Exception ex) {
                
                //do not silently fail - write a log
                
                String logMessage = String.format('An error occurred trying to perform the Credit call. Message: [{0}], Line: [{1}]',new String[]{
                        ex.getMessage(),
                        String.valueof(ex.getLineNumber())
                    });
                
                String externalReferenceId = new nFORCE.GuidGenerator().randomUUIDNoSeparator();    
                
                nFUSE__Transaction_Log__c log = new nFUSE__Transaction_Log__c(Name = externalReferenceId);
                log.nFUSE__Action__c = 'new';
                log.nFUSE__Api_Version__c = ExperianCreditActivator.PLUGIN_VERSION;
                log.nFUSE__App_Plugin__c = ExperianCreditActivator.PLUGIN_NAME;
                log.nFUSE__Requested_By_User_Id__c = c.requestedByUserId;
                log.nFUSE__Requesting_User_Id__c = c.requestedByUserId;
                log.nFUSE__External_Id__c = externalReferenceId;
                log.nFUSE__Primary_Object_Id__c = c.relationshipId;
                log.nFUSE__Transaction_Status__c = 'ERROR';
                log.nFUSE__Transaction_Detail__c = logMessage;
                log.nFUSE__Vendor_Status__c = '?';
                log.nFUSE__Sent_Time__c = datetime.now();
                errorLogsToAdd.add(log);
            }  
    
        }
    
        insert errorLogsToAdd;
    }
    global void finish(Database.BatchableContext BC){}
    
}