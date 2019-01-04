/* The controller for the GetLoanNumber page
 * Chintan Adhyapak, West Monroe Partners. November 19, 2018
 */
global with sharing class GetLoanNumberController {
	//class members
	@testVisible private static Boolean forceTestingException = false;
    @testVisible private static CBOrchestrator orchestrator = new CBOrchestrator();
    @testVisible public LLC_BI__Loan__c loan {get; set;}
    @testVisible private CBConfiguration configuration = new CBConfiguration();
    public String debugMessage {get; set;}

    @TestVisible private class ControllerException extends Exception {}

    //Constructor
    public GetLoanNumberController(ApexPages.StandardController stdController) {
    	System.debug('CPA Entering Constructor GetLoanNumberController');

    	this.loan = (LLC_BI__Loan__c)stdController.getRecord();
    	loan = [Select Id, Is_Ready_To_Request_Loan_Number__c, Navy_Core_Code__c From LLC_BI__Loan__c Where Id = :loan.Id];
    	System.debug('CPA loan retrieved in Constructor is: ' + loan);


    	//Set end point where msg is being set as a debug tool
    	String translatedUrlKey = configuration.GetTranslatedKey(System.Label.RESERVE_LOAN_NUMBER_ONBOARDING_URL);
        debugMessage = configuration.GetPropertyByKey(translatedUrlKey);
        if (String.isnotBlank(debugMessage) && !debugMessage.containsIgnoreCase('navyfederal.org'))
        	debugMessage = 'This request is being sent to a test site and NOT the NFCU Middleware: ' + debugMessage;
        else
        	debugMessage = '';
		System.debug('CPA debugMessage is: ' + debugMessage);
		System.debug('CPA Exiting Constructor GetLoanNumberController');
    } //constructor
    
    
    //This method sends out the getLoanNumber message to the middleware endpoint
    @RemoteAction
    global static CBEntities.CoreBookingResponse getLoanNumber(String loanId) {
    	System.debug('CPA Entering Method getLoanNumber');
        CBEntities.CoreBookingResponse res = new CBEntities.CoreBookingResponse();
        try {
        	res = orchestrator.getLoanNumber(loanId, null, null, null);
            if(forceTestingException)
                throw new ControllerException();
        } catch(Exception e) {
            res.IsSuccessful = false;
            res.Messages = String.format(System.Label.CBSendServiceOrchestrationException, 
                    new String[] {
                        'Get Loan Number',
                        e.getMessage()
                    });
        }
        System.debug('CPA Returning CoreBookingResponse: ' + res);
        return res;
    } //getLoanNumber
    
    
    
    @RemoteAction
    global static CBEntities.TransactionLogResponse getTransactionStatus(String externalId) {
    	System.debug('CPA Entering Method getTransactionStatus');
    	CBEntities.TransactionLogResponse response = orchestrator.GetTransactionLogDetails(externalId);
    
    	System.debug('CPA Returning Transaction Log Details: ' + response);
        return response;
    } //getTransactionStatus
}