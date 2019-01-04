/** This is the main class that has all the methods that are called to send a message to the 
  * Navy Middleware endpoint and process the response.
  */
public without sharing class CBOrchestrator implements ICBOrchestrator{
    public class CBOrchestratorServiceFinderException extends Exception {}
    public class CBServiceException extends Exception {}
    
    @testVisible
    private static Boolean forceTestingException = false;

    //
    //PUBLIC METHODS
    //
    
    /** The method that sends a BookLoan message to the Middleware endpoint */
    public CBEntities.CoreBookingResponse bookLoan(String loanId, String overrideUserId, String overrideUserSessionId, String overrideTransactionLogExternalId){
        System.debug('CPA Entering CBOrchestrator.bookLoan');
        //The response to return
        CBEntities.CoreBookingResponse response = new CBEntities.CoreBookingResponse();
        response.IsSuccessful = true;
        
        //Create a Request
        nFUSE.PackageServiceRequest request = new nFUSE.PackageServiceRequest(CBConfiguration.PLUGIN_NAME, CBConfiguration.PLUGIN_VERSION, !String.IsBlank(overrideTransactionLogExternalId) ? overrideTransactionLogExternalId : null);
        //Get a handle to the Service
        nFUSE.SendService service = serviceFinder(request, CBConfiguration.LOANSENDSERVICENAME);
        //Since an error was not thrown we have located the service successfully
        request.primaryObjectId = loanId;
        try {
            //Read the Navy Core Type to pass along to Middleware in the HTTP Header
            //Chintan Adhyapak, West Monroe Partners. December 14, 2017
            String navyCoreCode = getNavyCoreCode(loanId);
            //Create the message to send
            nFUSE.MiddlewareMessage message = prepareLoanBookingMessage(CBConfiguration.LOANBOOKACTION, request, loanId, overrideUserId, overrideUserSessionId, navyCoreCode);
            System.debug('CPA Sending book loan message: ' + message);
            //Send the message to the Middleware endpoint
            service.send(request, message);
            //Mark loan as sent for booking
            updateLoanAsSent(loanId);
            //updateTransactionLog(message,CBConfiguration.IN_PROGRESS_STATUS);
            System.debug('CPA Book loan response.IsSuccessful: ' + response.IsSuccessful);
            If (message.httpResponse.getStatusCode() == 200) {
                response.TransactionLogExternalId = message.messageHeader.transactionId;
                response.IsSuccessful = true;
                response.Messages = message.httpResponse.getBody();
                updateTransactionLog(message,CBConfiguration.MIDDLEWARE_ACK_STATUS);
                //update the Loan to indicate message has been successfully sent
                updateLoanAsBooked(loanId);
            } else {
                response.IsSuccessful = false;
                response.Messages = message.httpResponse.getStatus();
                updateTransactionLog(message,CBConfiguration.IN_ERROR_STATUS);
            }
        } catch(Exception e) {
            System.debug('CPA Error: ' + e.getStackTraceString());
            response.IsSuccessful = false;
            response.Messages = String.format(System.Label.OrchestrationGeneralException,
                    new String[]{
                        System.Label.LoanBooking,
                        e.getMessage(),
                        String.valueof(e.getLineNumber())
                    });
        }
        System.debug('CPA Returning Response: ' + response);
        System.debug('CPA Exiting CBOrchestrator.bookLoan');
        return response;
    } //bookLoan



    /** The method that sends a GetLoanNumber message to the Middleware endpoint */
    public CBEntities.CoreBookingResponse getLoanNumber(String loanId, String overrideUserId, String overrideUserSessionId, String overrideTransactionLogExternalId) {
        //Create a response record to return
        CBEntities.CoreBookingResponse response = new CBEntities.CoreBookingResponse();
        CBEntities.CoreBookingResponse respLoanNum = new CBEntities.CoreBookingResponse();
        response.IsSuccessful = true;

        System.debug('CPA Requesting Loan Number');
        //Create the request
        nFUSE.PackageServiceRequest request = new nFUSE.PackageServiceRequest(CBConfiguration.PLUGIN_NAME, CBConfiguration.PLUGIN_VERSION, !String.IsBlank(overrideTransactionLogExternalId) ? overrideTransactionLogExternalId : null);
        //Get a handle to the send service
        nFUSE.SendService service = serviceFinder(request, CBConfiguration.LOANSENDSERVICENAME);
        //since an error was not thrown we have located the service successfully
        System.debug('CPA Get Loan Number service locater' + service);
        //Set the primary object Id
        request.primaryObjectId = loanId;
        //Send
        try{
            //Create a message
            nFUSE.MiddlewareMessage message = new nFUSE.MiddlewareMessage();
            //Set message attributes
            message.messageHeader.action = CBConfiguration.LOANRESERVENUMBERACTION;
            Map<String,Object> props = new Map<String,Object>();
            props.put('custNum', GetCustomerNumber(loanId) );
            message.properties.put('loanId', loanId);
            message.properties.put('GetALSLoanNumber', props);
            //Adding Core Code, Chintan Adhyapak, West Monroe Partners. November 18, 2018
            message.properties.put('Navy_Core_Code', 'ALSLOANNUM');
            System.debug('CPA service message before send' + message);
            //Send the message
            service.send(request, message);
            //update the transaction log
            updateTransactionLog(message,CBConfiguration.IN_PROGRESS_STATUS);
            System.debug('CPA service message after send' + message);

            //Set the transaction Id in the response record
            response.TransactionLogExternalId = message.messageHeader.transactionId;
            //If endpoint returns a 200
            if (message.httpResponse.getStatusCode() == 200) {
                response.IsSuccessful = true;
                response.Messages = message.httpResponse.getBody();
                //Process the response to get the loan number
                respLoanNum = processALSLoanNumResp(response);
                if (respLoanNum.IsSuccessful == true) {
                    //update the Loan
                    updateLoanNumber(loanId, respLoanNum.externalLoanNumber);
                    response.IsSuccessful = true;
                    response.Messages = respLoanNum.Messages;
                    //update the transaction log
                    updateTransactionLog(message,CBConfiguration.IN_COMPLETED_STATUS);
                } else {
                    response.IsSuccessful = false;
                    response.Messages = respLoanNum.Messages;
                    updateTransactionLog(message,CBConfiguration.IN_ERROR_STATUS);
                }
            } else {
                response.IsSuccessful = false;
                updateTransactionLog(message,CBConfiguration.IN_ERROR_STATUS);
                response.Messages = String.format(System.Label.OrchestrationGeneralException,
                        new String[]{
                                'Get Loan Number',
                                message.httpResponse.getStatus(),
                                String.valueof(message.httpResponse.getBody())
                        });
            }
        } catch(Exception e) {
            response.IsSuccessful = false;
            response.Messages = String.format(System.Label.OrchestrationGeneralException,
                    new String[] {
                            'Get Loan Number',
                            e.getMessage(),
                            String.valueof(e.getLineNumber())
                    });
        }
        //Return the respose
        return response;
    } //getLoanNumber



    /** The method that sends a GetLoanPaymentSchedule  message to the Middleware endpoint
      * Chintan Adhyapak, West Monroe Partners. December 5, 2018
      */
    public CBEntities.CoreBookingResponse getLoanPaymentSchedule (String loanId, String overrideUserId, String overrideUserSessionId, String overrideTransactionLogExternalId) {
        System.debug('CPA Entering CBOrchestrator.getLoanPaymentSchedule');
        //Create a response record to return
        CBEntities.CoreBookingResponse response = new CBEntities.CoreBookingResponse();
        CBEntities.CoreBookingResponse responsePaymentSchedule = new CBEntities.CoreBookingResponse();
        response.IsSuccessful = true;

        //The fields to send are in the fieldset caled 'PaymentCalculator' on the Loan object
        Schema.FieldSet fieldset = SObjectType.LLC_BI__Loan__c.FieldSets.getMap().get('PaymentCalculator');
        List<Schema.FieldSetMember> fieldList = fieldset.getFields();
        System.debug('CPA fieldset Members retrieved are: ' + fieldList);

        //Create query
        String query = 'SELECT ';
        for(Schema.FieldSetMember member : fieldList) {
            query += member.getFieldPath() + ', ';
        }
        query += 'Id FROM LLC_BI__Loan__c Where Id = :loanId';
        System.debug('CPA query is: ' + query);

        //Retrieve loan
        List<LLC_BI__Loan__c> loanList = Database.query(query);
        LLC_BI__Loan__c loan = loanList[0];
        System.debug('CPA retrieved loan is: ' + loan);

        //Create a request
        nFUSE.PackageServiceRequest request = new nFUSE.PackageServiceRequest(CBConfiguration.PLUGIN_NAME, CBConfiguration.PLUGIN_VERSION, !String.IsBlank(overrideTransactionLogExternalId) ? overrideTransactionLogExternalId : null);
        
        //Get a handle to the send service
        nFUSE.SendService service = serviceFinder(request, CBConfiguration.LOANSENDSERVICENAME);
        //since an error was not thrown we have located the service successfully
        System.debug('CPA getLoanPaymentSchedule service locater is: ' + service);
        
        //Set the primary object Id
        request.primaryObjectId = loanId;
        
        //Send
        try{
            //Create a message
            nFUSE.MiddlewareMessage message = new nFUSE.MiddlewareMessage();
            //Set the header action. This allows the CBLoanSendService to pick up the URL to send the message to from the CoreBooking Plugin
            message.messageHeader.action = CBConfiguration.LOANPAYMENTSCHEDULEACTION;
            //Create the JSON elements to send in the message
            Map<String,Object> calculatorProperties = new Map<String,Object>();
            calculatorProperties.put('loanAmount', loan.LLC_BI__Amount__c);
            calculatorProperties.put('loanTerm', loan.LLC_BI__Term_Months__c);
            calculatorProperties.put('firstPaymentDate', loan.LLC_BI__First_Payment_Date__c);
            calculatorProperties.put('cycleDate', loan.Navy_Calculator_Cycle_Day__c);
            calculatorProperties.put('computerCode', loan.Navy_Calculator_ComputeCode__c);
            calculatorProperties.put('interestRate', loan.LLC_BI__InterestRate__c);
            message.properties.put('loanId', loanId);
            message.properties.put('PaymentCalculator', calculatorProperties);
            message.properties.put('Navy_Core_Code', 'LOANPMTCALC');
            System.debug('CPA message before send is: ' + message);

            //Send the message
            service.send(request, message);

            //update the transaction log
            updateTransactionLog(message,CBConfiguration.IN_PROGRESS_STATUS);

            //Set the transaction Id in the response record
            response.TransactionLogExternalId = message.messageHeader.transactionId;

            //If endpoint returns a 200
            if (message.httpResponse.getStatusCode() == 200) {
                response.IsSuccessful = true;
                response.Messages = message.httpResponse.getBody();

                //Deserialize the response that is returned by the middleware
                Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(response.Messages);
                //Read the Status object from the JSON
                Map<String, Object> statusMap = (Map<String, Object>) responseMap.get('Status');

                //Read the status code and description
                String statusCode = (String) statusMap.get('statusCode');
                String statusMessage = (String) statusMap.get('StatusMessage');
                System.debug('CPA Response statusCode is: ' + statusCode + ' and StatusMessage is: ' + statusMessage);

                if (statusCode == '0') {
                    response.IsSuccessful = true;
                    response.Messages = statusMessage;

                    //Read the payment details returned
                    Map<String, Object> loanMap = (Map<String, Object>) responseMap.get('Loan');
                    System.debug('CPA Loan map read in the response is: ' + loanMap);

                    //query for the loan
                    loan = [SELECT Id, Payment_Calculator_Fields_Updated__c, LLC_BI__Term_Months__c, LLC_BI__First_Payment_Date__c, LLC_BI__Monthly_Payment__c,
                            Final_Payment_Amount__c, LLC_BI__Maturity_Date__c, Total_Interest_Life_of_Loan__c, LLC_BI__APR__c, Effective_Rate__c 
                            FROM LLC_BI__Loan__c WHERE Id = :loanId][0];

                    //Set values
                    loan.Payment_Calculator_Fields_Updated__c = System.now();
                    loan.LLC_BI__Term_Months__c = Decimal.valueOf((String)loanMap.get('LoanTerm'));
                    loan.LLC_BI__First_Payment_Date__c = Date.valueOf((String)loanMap.get('FirstPaymentDate'));
                    loan.LLC_BI__Monthly_Payment__c = Decimal.valueOf((String)loanMap.get('LoanPaymentAmount'));
                    loan.Final_Payment_Amount__c = Decimal.valueOf((String)loanMap.get('LastPaymentAmount'));
                    loan.LLC_BI__Maturity_Date__c = Date.valueOf((String)loanMap.get('FinalPayDate'));
                    loan.Total_Interest_Life_of_Loan__c = Decimal.valueOf((String)loanMap.get('TotalInterest'));
                    loan.LLC_BI__APR__c = Decimal.valueOf((String)loanMap.get('LoanAPR'));
                    loan.Effective_Rate__c = Decimal.valueOf((String)loanMap.get('EffectiveRate'));

                    //update loan
                    update loan;

                    //update the transaction log
                    updateTransactionLog(message,CBConfiguration.IN_COMPLETED_STATUS);
                } else {
                    response.IsSuccessful = false;
                    response.Messages = 'statusCode:' + statusCode + '\n\r statusMessage:' + statusMessage;

                    //update the transaction log
                    updateTransactionLog(message,CBConfiguration.IN_ERROR_STATUS);
                }
            } else {
                response.IsSuccessful = false;
                updateTransactionLog(message,CBConfiguration.IN_ERROR_STATUS);
                response.Messages = String.format(System.Label.OrchestrationGeneralException,
                        new String[]{
                                'Get Payment Calculator',
                                message.httpResponse.getStatus(),
                                String.valueof(message.httpResponse.getBody())
                        });

            }
        } catch(Exception e) {
            response.IsSuccessful = false;
            response.Messages = String.format(System.Label.OrchestrationGeneralException,
                    new String[] {
                            'Get Payment Calculator',
                            e.getMessage(),
                            String.valueof(e.getLineNumber())
                    });
        }
        System.debug('CPA Returning response: ' + response);
        System.debug('CPA Exiting CBOrchestrator.getLoanPaymentSchedule');
        //Return the respose
        return response;
    } //getLoanPaymentSchedule



    /** Stub Method for bookCustomer. Not used at NFCU */
    public CBEntities.CoreBookingResponse bookCustomer(String relationshipId, String overrideUserId, String overrideUserSessionId, String overrideTransactionLogExternalId){
        CBEntities.CoreBookingResponse response = new CBEntities.CoreBookingResponse();
        response.IsSuccessful = true;
        
        if(!ShouldBookCustomer(relationshipId)){
            response.IsSuccessful = false;
            response.Messages = String.format(System.Label.BookedPreviously, 
                    new String[]{
                        System.Label.CustomerBooking
                    });
            return response;
        }
        
        System.debug('CPA will call book customer');
        
        nFUSE.PackageServiceRequest request = new nFUSE.PackageServiceRequest(CBConfiguration.PLUGIN_NAME, CBConfiguration.PLUGIN_VERSION, !String.IsBlank(overrideTransactionLogExternalId) ? overrideTransactionLogExternalId : null);
        
        nFUSE.SendService service = serviceFinder(request, CBConfiguration.CUSTOMERSENDSERVICENAME);
        //since an error was not thrown we have located the service successfully
        
        request.primaryObjectId = relationshipId;
        
        try{
            
            nFUSE.MiddlewareMessage message = prepareCustomerBookingMessage(CBConfiguration.CUSTOMERBOOKACTION, request, relationshipId, overrideUserId, overrideUserSessionId);
            
            service.send(request, message);
            updateTransactionLog(message,CBConfiguration.IN_PROGRESS_STATUS);
            
            response.TransactionLogExternalId = message.messageHeader.transactionId;
            response.IsSuccessful = true;
            
        }catch(Exception e){
            
            response.IsSuccessful = false;
            response.Messages = String.format(System.Label.OrchestrationGeneralException, 
                    new String[]{
                        System.Label.CustomerBooking,
                        e.getMessage(),
                        String.valueof(e.getLineNumber())
                    });
            
        }
        
        return response;
    } //bookCustomer
    
    
    
    /** Stub Method for bookDeposit. Not used at NFCU */
    public CBEntities.CoreBookingResponse bookDeposit(String depositId, String overrideUserId, String overrideUserSessionId, String overrideTransactionLogExternalId){
        CBEntities.CoreBookingResponse response = new CBEntities.CoreBookingResponse();
        response.IsSuccessful = true;
        
        if(!ShouldBookDeposit(depositId)){
            response.IsSuccessful = false;
            response.Messages = String.format(System.Label.BookedPreviously, 
                    new String[]{
                        System.Label.DepositBooking
                    });
            return response;
        }
        
        System.debug('CPA will call book deposit');
        
        nFUSE.PackageServiceRequest request = new nFUSE.PackageServiceRequest(CBConfiguration.PLUGIN_NAME, CBConfiguration.PLUGIN_VERSION, !String.IsBlank(overrideTransactionLogExternalId) ? overrideTransactionLogExternalId : null);
        
        nFUSE.SendService service = serviceFinder(request, CBConfiguration.DEPOSITSENDSERVICENAME);
        //since an error was not thrown we have located the service successfully
        
        request.primaryObjectId = depositId;
        
        try{
            
            nFUSE.MiddlewareMessage message = prepareDepositBookingMessage(CBConfiguration.DEPOSITBOOKACTION, request, depositId, overrideUserId, overrideUserSessionId);
            
            service.send(request, message);
            updateTransactionLog(message,CBConfiguration.IN_PROGRESS_STATUS);
            
            
            response.TransactionLogExternalId = message.messageHeader.transactionId;
            response.IsSuccessful = true;
            
        }catch(Exception e){
            
            response.IsSuccessful = false;
            response.Messages = String.format(System.Label.OrchestrationGeneralException, 
                    new String[]{
                        System.Label.DepositBooking,
                        e.getMessage(),
                        String.valueof(e.getLineNumber())
                    });
            
        }
        
        return response;
    } //bookDeposit



    /** Method to return the Transaction Log Response record for a passed in External ID */
    public CBEntities.TransactionLogResponse getTransactionLogDetails(String externalId) {
        CBEntities.TransactionLogResponse response = new CBEntities.TransactionLogResponse();
        nFUSE__Transaction_Log__c transactionLog = [
            SELECT
                Id,
                nFUSE__Vendor_Status__c,
                nFUSE__Transaction_Status__c,
                nFUSE__Transaction_Detail__c,
                nFUSE__External_Id__c
            FROM
                nFUSE__Transaction_Log__c
            WHERE
                nFUSE__External_Id__c = :externalId
        ][0];
        response.VendorStatus = transactionLog.nFUSE__Vendor_Status__c;
        response.Status = transactionLog.nFUSE__Transaction_Status__c;
        response.Details = transactionLog.nFUSE__Transaction_Detail__c;
        response.ExternalId = transactionLog.nFUSE__External_Id__c;
        response.IsComplete = false;
        response.IsSuccessful = true;
        
        if(CBConfiguration.TRANSACTION_STATUS_ERROR_STRINGS.contains(response.Status.toUpperCase())) {
            response.IsSuccessful = false;
        }
        //Modified by Chintan Adhyaak, West Monroe Partners. March 23, 2018
        //if(CBConfiguration.TRANSACTION_STATUS_COMPLETION_STRINGS.contains(response.Status.toUpperCase())) {
        if(CBConfiguration.BOOKLOAN_TRANSACTION_STATUS_COMPLETION_STRINGS.contains(response.Status.toUpperCase())) {
            response.IsComplete = true;
        }
        
        return response;
    } //getTransactionLogDetails
    
    
    
    /** Method to return the SendService for the passed in SendService Name */
    public static nFUSE.SendService serviceFinder(nFUSE.PackageServiceRequest request, String sendServiceName) {
        nFUSE.SendService service = null;
        try {
            if(forceTestingException)
                throw new CBOrchestratorServiceFinderException('forceTestingException');
            nFUSE.ServiceLocator locator = new nFUSE.ServiceLocator();
            service = (nFUSE.SendService)locator.locate(request, nFUSE.SendService.class, sendServiceName);
        } 
        catch(Exception e) {
            if(e.getMessage().toLowerCase().contains('unable to locate service for')) {
                throw new CBOrchestratorServiceFinderException(String.format(System.Label.ServiceLocatorException, 
                    new String[]{
                        sendServiceName,
                        e.getMessage(),
                        String.valueof(e.getLineNumber())
                    }));
            } else {
                throw new CBOrchestratorServiceFinderException(String.format(System.Label.ServiceLocatorGeneralException, 
                    new String[]{
                        sendServiceName,
                        e.getMessage(),
                        String.valueof(e.getLineNumber())
                    }));
            }
        }
        return service;
    } //serviceFinder
    
    
    
    //
    //PRIVATE METHODS
    //

    /** Prepares the JSON structure of the book loan message to send to the middleware */
    @testVisible
    private static nFUSE.MiddlewareMessage prepareLoanBookingMessage(String action, nFUSE.PackageServiceRequest request, Id objectId, String overrideUserId, String overrideUserSessionId, String navyCoreCode) {
        //Create a message object
        nFUSE.MiddlewareMessage message = new nFUSE.MiddlewareMessage();
        message.messageHeader.action = action;
        if (objectId != null) {
            nFORCE.ACrossPackageService loanService = (nFORCE.ACrossPackageService) nFORCE.BeanFactory.getInstance().getBeanByUniqueName(CBConfiguration.NFUSE_LOAN_XPKG_SERVICE);
            if(loanService == null)
                throw new CBServiceException('loanService was not expected to be null (BeanName not found "' + CBConfiguration.NFUSE_LOAN_XPKG_SERVICE + '")');
            if(request == null)
                throw new CBServiceException('request was not expected to be null');
            loanService.setInputParameter('request', new nFUSE.IntegrationClassTypeProvider().serialize(request));
            loanService.setInputParameter('loan_ids', new Set<Id>{ request.primaryObjectId });
            loanService.executeService();
            List<nFORCE.IForce> fLoans = (List<nFORCE.IForce>) loanService.getOutputParameter('loans');
            message.properties.put('loan', fLoans[0]);
            if(!String.isBlank(overrideUserId)) {
                message.properties.put('salesforce_user_id', overrideUserId);
            }
            if(!String.isBlank(overrideUserSessionId)) {
                message.properties.put('salesforce_session_id', overrideUserSessionId);
            }
            //Set a property to pass the Navy Core Code so it can be set in the http header in CBLoanSendService
            //Chintan Adhyapak, West Monroe Partners. December 14, 2017
            System.debug('CPA In prepareLoanBookingMessage Setting Message Property Navy_Code_Code to: ' + navyCoreCode);
            message.properties.put('Navy_Core_Code', navyCoreCode);
        }
        //Return the structured message
        return message;
    } //prepareLoanBookingMessage
    
    

    /** Prepares the JSON structure of the book loan message to send to the middleware. This is the older format to satisfy existing test classes
     * Chintan Adhyapak, West Monroe Partners. January 11, 2018
     */
    @testVisible
    private static nFUSE.MiddlewareMessage prepareLoanBookingMessage(String action, nFUSE.PackageServiceRequest request, Id objectId, String overrideUserId, String overrideUserSessionId) {
        //Create a message object
        nFUSE.MiddlewareMessage message = new nFUSE.MiddlewareMessage();
        message.messageHeader.action = action;
        if (objectId != null) {
            nFORCE.ACrossPackageService loanService = (nFORCE.ACrossPackageService) nFORCE.BeanFactory.getInstance().getBeanByUniqueName(CBConfiguration.NFUSE_LOAN_XPKG_SERVICE);
            if(loanService == null)
                throw new CBServiceException('loanService was not expected to be null (BeanName not found "'+CBConfiguration.NFUSE_LOAN_XPKG_SERVICE+'")');
            if(request == null)
                throw new CBServiceException('request was not expected to be null');
            loanService.setInputParameter('request', new nFUSE.IntegrationClassTypeProvider().serialize(request));
            loanService.setInputParameter('loan_ids', new Set<Id>{ request.primaryObjectId });
            loanService.executeService();
            List<nFORCE.IForce> fLoans = (List<nFORCE.IForce>) loanService.getOutputParameter('loans');
            message.properties.put('loan', fLoans[0]);
            if(!String.isBlank(overrideUserId)) {
                message.properties.put('salesforce_user_id', overrideUserId);
            }
            if(!String.isBlank(overrideUserSessionId)) {
                message.properties.put('salesforce_session_id', overrideUserSessionId);
            }
        }
        //Return the structured message
        return message;
    } //prepareLoanBookingMessage
    
    
    
    /** Method not used by NFCU */
    @testVisible
    private static nFUSE.MiddlewareMessage prepareCustomerBookingMessage(String action, nFUSE.PackageServiceRequest request, Id objectId, String overrideUserId, String overrideUserSessionId) {
        nFUSE.MiddlewareMessage message = new nFUSE.MiddlewareMessage();
        message.messageHeader.action = action;
        
        if (objectId != null) {
            
            nFORCE.ACrossPackageService relationshipService = (nFORCE.ACrossPackageService) nFORCE.BeanFactory.getInstance().getBeanByUniqueName(CBConfiguration.NFUSE_RELATIONSHIP_XPKG_SERVICE);
            
            if(relationshipService == null)
                throw new CBServiceException('relationshipService was not expected to be null (BeanName not found "'+CBConfiguration.NFUSE_RELATIONSHIP_XPKG_SERVICE+'")');
                
            if(request == null)
                throw new CBServiceException('request was not expected to be null');
            
            relationshipService.setInputParameter(
                'request',
                new nFUSE.IntegrationClassTypeProvider().serialize(request)
            );
            
            relationshipService.setInputParameter('relationship_ids', 
                JSON.serialize(new Set<Id>{ request.primaryObjectId })
            );

            relationshipService.executeService();

            List<nFORCE.IForce> fRelationships = (List<nFORCE.IForce>) relationshipService.getOutputParameter('relationships');
            message.properties.put('relationship', fRelationships[0]);
            
            if(!String.isBlank(overrideUserId)){
                message.properties.put('salesforce_user_id', overrideUserId);
            }
            if(!String.isBlank(overrideUserSessionId)){
                message.properties.put('salesforce_session_id', overrideUserSessionId);
            }
            
            message.properties.put('primary_object_id', request.primaryObjectId);
            
        }

        return message;
    } //prepareCustomerBookingMessage
    
    
    
    /** Method not used by NFCU */
    @testVisible
    private static nFUSE.MiddlewareMessage prepareDepositBookingMessage(String action, nFUSE.PackageServiceRequest request, Id objectId, String overrideUserId, String overrideUserSessionId) {
        nFUSE.MiddlewareMessage message = new nFUSE.MiddlewareMessage();
        message.messageHeader.action = action;
        
        if (objectId != null) {
            
            nFORCE.ACrossPackageService depositService = (nFORCE.ACrossPackageService) nFORCE.BeanFactory.getInstance().getBeanByUniqueName(CBConfiguration.NFUSE_DEPOSIT_XPKG_SERVICE);
            
            if(depositService == null)
                throw new CBServiceException('depositService was not expected to be null (BeanName not found "'+CBConfiguration.NFUSE_DEPOSIT_XPKG_SERVICE+'")');
                
            if(request == null)
                throw new CBServiceException('request was not expected to be null');
            
            depositService.setInputParameter(
                'request',
                new nFUSE.IntegrationClassTypeProvider().serialize(request)
            );
            
            depositService.setInputParameter('deposit_ids', 
                new Set<Id>{ request.primaryObjectId }
            );
            
            depositService.executeService();

            List<nFORCE.IForce> fDeposits = (List<nFORCE.IForce>) depositService.getOutputParameter('deposits');
            
            message.properties.put('deposit', fDeposits[0]);
            
            if(!String.isBlank(overrideUserId)){
                message.properties.put('salesforce_user_id', overrideUserId);
            }
            if(!String.isBlank(overrideUserSessionId)){
                message.properties.put('salesforce_session_id', overrideUserSessionId);
            }
            
            message.properties.put('primary_object_id', request.primaryObjectId);
            
        }

        return message;
    } //prepareDepositBookingMessage
    
    
    
    /** Update the transaction log with the passed in message and status */
    @testVisible
    private static nFUSE__Transaction_Log__c updateTransactionLog(nFUSE.AMiddlewareMessage message, String Status) {
        nFUSE__Transaction_Log__c transactionLog = [
            SELECT
                Id,
                CreatedDate
            FROM
                nFUSE__Transaction_Log__c
            WHERE
                nFUSE__External_Id__c = :message.messageHeader.transactionId
        ][0];
        transactionLog.nFUSE__Vendor_Status__c = message.messageHeader.action;
        transactionLog.nFUSE__Transaction_Status__c = Status;
                //CBConfiguration.IN_PROGRESS_STATUS;
        update transactionLog;
        return transactionLog;
    } //updateTransactionLog
    
    
    
    /** Update the passed in loan Id with the current date time stamp to indicate that a book loan 
      * message was successfully sent to the middleware
      * Chintan Adhyapak, West Monroe Partners, December 12, 2017 */
    @testVisible
    private static void updateLoanAsSent(String loanId){
        //query for the loan
        LLC_BI__Loan__c loan = [SELECT Id, BookLoan_Request_Sent__c FROM LLC_BI__Loan__c WHERE Id = :loanId][0];
        loan.BookLoan_Request_Sent__c = System.now();

        update loan;
    } //updateLoanAsSent
    
    
    
    /** Update the passed in loan Id with the current date time stamp to indicate that a book loan 
      * message was successfully acknowledged by the middleware
      * Chintan Adhyapak, West Monroe Partners, December 12, 2017 */
    @testVisible
    private static void updateLoanAsBooked(String loanId){
        //query for the loan
        LLC_BI__Loan__c loan = [SELECT Id, BookLoan_Request_Acknowledged__c FROM LLC_BI__Loan__c WHERE Id = :loanId][0];
        loan.BookLoan_Request_Acknowledged__c = System.now();

        update loan;
    } //updateLoanAsBooked
    
    
    
    /** Returns true if lookup key is blank on Account */
    @testVisible
    private static Boolean ShouldBookCustomer(String accountId){
        Account account = [
            SELECT
                Id,
                LLC_BI__lookupKey__c
            FROM
                Account
            WHERE
                Id = :accountId
        ][0];
        return String.isBlank(account.LLC_BI__lookupKey__c);
    } //ShouldBookCustomer
    
    
    /** Returns true if Lookup Key is blank on the loan */
    @testVisible
    private static Boolean ShouldBookLoan(String loanId){
        LLC_BI__Loan__c loan = [
            SELECT
                Id,
                LLC_BI__lookupKey__c
            FROM
                LLC_BI__Loan__c
            WHERE
                Id = :loanId
        ][0];
        return String.isBlank(loan.LLC_BI__lookupKey__c);
    } //ShouldBookLoan
    
    
    
    /** Returns true if loan satisfies creiteria for sending a GetLoanNumber message to the middleware */
    @testVisible
    private static Boolean isLoanReadyToRequestNumber(String loanId) {
        LLC_BI__Loan__c loan = [SELECT Id, Is_Ready_To_Request_Loan_Number__c FROM LLC_BI__Loan__c WHERE Id = :loanId][0];
        return loan.Is_Ready_To_Request_Loan_Number__c;
    } //isLoanReadyToRequestNumber
    
    
    
    /** Returns true if loan has already been booked with the Core */
    @testVisible
    private static Boolean isLoanBooked(String loanId) {
        LLC_BI__Loan__c loan = [SELECT Id, BookLoan_Request_Acknowledged__c FROM LLC_BI__Loan__c WHERE Id = :loanId][0];
        System.debug('CPA In isLoanBooked BookLoan_Request_Acknowledged__c is: ' + loan.BookLoan_Request_Acknowledged__c);
        System.debug('CPA isLoanBooked Returning: ' + (loan.BookLoan_Request_Acknowledged__c != null));
        return (loan.BookLoan_Request_Acknowledged__c != null);
    } //isLoanBooked
    
    
    
    /** Returns true if loan has already requested a loan number from the Core */
    @testVisible
    private static Boolean hasLoanNumberBeenRequested(String loanId) {
        LLC_BI__Loan__c loan = [SELECT Id, GetLoanNumber_Request_Submitted__c FROM LLC_BI__Loan__c WHERE Id = :loanId][0];
        return (loan.GetLoanNumber_Request_Submitted__c != null);
    } //hasLoanNumberBeenRequested
    
    
    
    /** Returns true if loan satisfies creiteria for sending a GetPaymentCalculations message to the middleware */
    @testVisible
    private static boolean isLoanReadyToRequestPaymentCalculation(String loanId) {
        LLC_BI__Loan__c loan = [SELECT Id, Is_Ready_To_Call_Payment_Calculator__c FROM LLC_BI__Loan__c WHERE Id = :loanId][0];
        return loan.Is_Ready_To_Call_Payment_Calculator__c;
    } //isLoanReadyToRequestPaymentCalculation
    
    
    
    /** Returns if deposit is ready to be booked */
    @testVisible
    private static Boolean ShouldBookDeposit(String depositId){
        LLC_BI__Deposit__c deposit = [
            SELECT
                Id,
                LLC_BI__lookupKey__c
            FROM
                LLC_BI__Deposit__c
            WHERE
                Id = :depositId
        ][0];
        return String.isBlank(deposit.LLC_BI__lookupKey__c);
    } //ShouldBookDeposit



    /** Updates the loan after a successful GetLoanNumber call */ 
    @testVisible
    private static void updateLoanNumber(String loanId, String loanNumber) {
        //query for the loan
        LLC_BI__Loan__c loan = [SELECT Id, LLC_BI__lookupKey__c, GetLoanNumber_Request_Submitted__c FROM LLC_BI__Loan__c WHERE Id = :loanId][0];

        //Set values
        loan.LLC_BI__lookupKey__c = loanNumber;
        loan.GetLoanNumber_Request_Submitted__c = System.now();

        //update
        update loan;
        //return loan;
    } //updateLoanNumber
    
    
    
    /** Private method to return the Navy_Core_Type value for given Loan ID */
    @testVisible
    private static String getNavyCoreCode(String loanId) {
        //query for the loan
        LLC_BI__Loan__c loan = [SELECT Id, Navy_Core_Code__c FROM LLC_BI__Loan__c WHERE Id = :loanId][0];
        System.debug('CPA getNavyCoreCode returning: ' + loan.Navy_Core_Code__c);
        return loan.Navy_Core_Code__c;
    } //getNavyCoreCode
    
    
    
    /** Return the Member Access Number for the passed in Loan ID */
    @testVisible
    private static String GetCustomerNumber(String loanID){
        Account account = [
                SELECT
                        Member_Access_Number__c
                FROM
                        Account
                WHERE
                        Id in (SELECT
                                LLC_BI__Account__c
                        FROM
                                LLC_BI__Loan__c
                        WHERE
                                Id = :loanId)
        ][0];
        return account.Member_Access_Number__c;
    } //GetCustomerNumber



    /** Process the Get Loan Number call response to extract the loan number etc. */
    @testVisible
    private static CBEntities.CoreBookingResponse processALSLoanNumResp(CBEntities.CoreBookingResponse response) {
        //Create a response record to return
        CBEntities.CoreBookingResponse returnResponse = new CBEntities.CoreBookingResponse();

        //Deserialize the response that is passed in
        Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(response.Messages);
        //Read the returned data
        String statusCode = (String) m.get('statusCode');
        String statusMessage = (String) m.get('StatusMessage');
        String reqUID = (String) m.get('ReqUID');
        System.debug('CPA Response deserializeUntyped statusCode is: ' + statusCode + ' StatusMessage is: ' + statusMessage + ' ReqUID is: ' + reqUID);
        //Read the header

        if (statusCode == '0') {
            String loanNumber = (String) m.get('AcctNbr');
            System.debug('CPA response deserializeUntyped AcctNbr is: ' + loanNumber);
            returnResponse.IsSuccessful = true;
            returnResponse.Messages = 'Request UID: ' + reqUID;
            returnResponse.externalLoanNumber = loanNumber;
        } else {
            //String strAdditionalStatus = '';
            //List<Object> listAdditionalStatus = (List<Object>) LoanResponseStatus.get('additionalStatus');
            //for (Object additionalStatusDesc : listAdditionalStatus) {
            //  Map<String, Object> additionalStatusDescAttributes = (Map<String, Object>)additionalStatusDesc;
            //  String strAdditionalStatusDesc = (String) additionalStatusDescAttributes.get('statusDesc');
            //  strAdditionalStatus += strAdditionalStatusDesc + '  ';
            //}
            returnResponse.IsSuccessful = false;
            returnResponse.Messages = 'statusCode:' + statusCode + '\n\r statusMessage:' + statusMessage + '\n\r Request "UID:  ' + reqUID;
        }
        //Return the response
        return returnResponse;
    } //processALSLoanNumResp



    /** Process the Get Loan Number call response to extract the loan number etc. NOT USED ANYMORE */
    @testVisible
    private static CBEntities.CoreBookingResponse processALSLoanNumRespOld(CBEntities.CoreBookingResponse response) {
        //Create a response record to return
        CBEntities.CoreBookingResponse respLoanNum = new CBEntities.CoreBookingResponse();

        //Deserialize the response that is passed in
        Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(response.Messages);
        //Read the Status tree from the JSON
        Map<String, Object> loanResponseStatus = (Map<String, Object>) m.get('Status');
        //Read the code and description
        String statusCode = (String) loanResponseStatus.get('statusCode');
        String statusDesc = (String) loanResponseStatus.get('statusDesc');
        System.debug('CPA Response deserializeUntyped LoanResponseStatus is: ' + statusCode + '--' + statusDesc);
        //Read the header
        Map<String, Object> msgRsHdr = (Map<String, Object>) m.get('MsgRsHdr');
        String confirmationNbr = (String) msgRsHdr.get('confirmationNbr');

        if (statusCode == '0') {
            Map<String, Object> loanNumberResponse = (Map<String, Object>) m.get('NewALSAcctNumRec');
            String loanNumber = (String)loanNumberResponse.get('acctNum');
            System.debug('CPA response deserializeUntyped loanNumberResponse is: ' + loanNumber);
            respLoanNum.IsSuccessful = true;
            respLoanNum.Messages = 'Confirmation Number: ' + confirmationNbr;
            respLoanNum.externalLoanNumber = loanNumber;
        } else {
            String strAdditionalStatus = '';
            List<Object> listAdditionalStatus = (List<Object>) LoanResponseStatus.get('additionalStatus');
            for (Object additionalStatusDesc : listAdditionalStatus) {
                Map<String, Object> additionalStatusDescAttributes = (Map<String, Object>)additionalStatusDesc;
                String strAdditionalStatusDesc = (String) additionalStatusDescAttributes.get('statusDesc');
                strAdditionalStatus += strAdditionalStatusDesc + '  ';
            }
            respLoanNum.IsSuccessful = false;
            respLoanNum.Messages = 'statusCode:' + statusDesc + '\n\r statusDesc:' + statusDesc + '\n\r additionalStatus:' + strAdditionalStatus + '\n\r Confirmation Number:  ' + confirmationNbr;
        }
        //Return the response
        return respLoanNum;
    } //processALSLoanNumRespOld
}