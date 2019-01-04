/* The controller for the GetPaymentSchedule page
 * Chintan Adhyapak, West Monroe Partners. December 06, 2018
 */
global with sharing class GetPaymentScheduleController {
	//class members
	@testVisible private static Boolean forceTestingException = false;
    @testVisible private static CBOrchestrator orchestrator = new CBOrchestrator();
    @testVisible public LLC_BI__Loan__c loan {get; set;}
    @testVisible private CBConfiguration configuration = new CBConfiguration();
    public String debugMessage {get; set;}

    @TestVisible private class ControllerException extends Exception {}

    //Constructor
    public GetPaymentScheduleController(ApexPages.StandardController stdController) {
    	System.debug('CPA Entering Constructor GetPaymentScheduleController');

    	this.loan = (LLC_BI__Loan__c)stdController.getRecord();
    	loan = [Select Id, Is_Ready_To_Call_Payment_Calculator__c, Navy_Core_Code__c From LLC_BI__Loan__c Where Id = :loan.Id];
    	System.debug('CPA loan retrieved in Constructor is: ' + loan);

    	//Read the end point where msg is being set as a debug tool
    	String translatedUrlKey = configuration.GetTranslatedKey(System.Label.LOAN_PAYMENT_SCHEDULE_ONBOARDING_URL);
        debugMessage = configuration.GetPropertyByKey(translatedUrlKey);
        if (String.isnotBlank(debugMessage) && !debugMessage.containsIgnoreCase('navyfederal.org'))
        	debugMessage = 'This request is being sent to a test site (' + debugMessage + ') and NOT the NFCU Middleware.';
        else
        	debugMessage = '';
		System.debug('CPA debugMessage is: ' + debugMessage);
		System.debug('CPA Exiting Constructor GetPaymentScheduleController');
    } //constructor
    

    
    //This method sends out the getLoanPaymentSchedule message to the middleware endpoint
    @RemoteAction
    global static CBEntities.CoreBookingResponse getPaymentSchedule(String loanId) {
    	System.debug('CPA Entering Method GetPaymentScheduleController');
        CBEntities.CoreBookingResponse response = new CBEntities.CoreBookingResponse();
        try {
        	response = orchestrator.getLoanPaymentSchedule(loanId, null, null, null);
            if (forceTestingException)
                throw new ControllerException();
        } catch(Exception e) {
            response.IsSuccessful = false;
            response.Messages = String.format(System.Label.CBSendServiceOrchestrationException, 
                    new String[] {
                        'Get Payment Schedule',
                        e.getMessage()
                    });
        }
        System.debug('CPA Returning CoreBookingResponse: ' + response);
        return response;
    } //getPaymentSchedule
    
    
    
    @RemoteAction
    global static CBEntities.TransactionLogResponse getTransactionStatus(String externalId) {
    	System.debug('CPA Entering Method getTransactionStatus');
    	CBEntities.TransactionLogResponse response = orchestrator.GetTransactionLogDetails(externalId);
    
    	System.debug('CPA Returning Transaction Log Details: ' + response);
        return response;
    } //getTransactionStatus
}