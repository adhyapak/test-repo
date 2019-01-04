/* The controller for the LoanCoreBooking page
 * Modified by Chintan Adhyapak, West Monroe Partners. March 23, 2018
 */
global with sharing class CBLoanController {
	//class members
	@testVisible
    private static Boolean forceTestingException = false;
    @testVisible
    private static ICBOrchestrator orchestrator = new CBOrchestrator();
    @testVisible 
    public LLC_BI__Loan__c loan {get; set;}
    @testVisible
    private CBConfiguration configuration = new CBConfiguration();
    @testVisible
    public String debugMessage {get; set;}
    @testVisible
    public boolean isALSdown {get; set;}
    @testVisible
    public String startTime {get; set;}
    @testVisible
    public String endTime {get; set;}
    
    @TestVisible private class ControllerException extends Exception {}
    
    //Constructor
    public CBLoanController(ApexPages.StandardController stdController) {
    	System.debug('CPA Entering Constructor CBLoanController');
    	
    	this.loan = (LLC_BI__Loan__c)stdController.getRecord();
    	loan = [Select Id, Loan_Ready_for_Auto_Booking__c, Navy_Core_Code__c  From LLC_BI__Loan__c Where Id = :loan.Id];
    	System.debug('CPA loan retrieved in Constructor is: ' + loan);
    	
    	//Read Custom Metadata
    	String alsDownStart = '18';
    	String alsDownEnd = '20'; //Default values in case custom metadata is not set
    	List<Account_Setting__mdt> accountSettings = [SELECT DeveloperName,Value__c FROM Account_Setting__mdt WHERE DeveloperName LIKE 'ALS_DOWN%'];
    	System.debug('CPA accountSettings read are: ' + accountSettings);
    	for (Account_Setting__mdt mySetting : accountSettings) {
    		if (mySetting.DeveloperName.equalsIgnoreCase('ALS_DOWN_START')) {
    			alsDownStart = mySetting.Value__c;
    			System.debug('CPA Read ALS_DOWN_START from Custom Metadata as: ' + alsDownStart);
    		} else if (mySetting.DeveloperName.equalsIgnoreCase('ALS_DOWN_END')) {
    			alsDownEnd = mySetting.Value__c;
    			System.debug('CPA Read ALS_DOWN_END from Custom Metadata as: ' + alsDownEnd);
    		}
    	}
    	
    	//Set the values to display on the VF page
    	Integer startInt = Integer.valueOf(alsDownStart);
    	if (startInt == 12)
    		startTime = '12 pm';
    	else if (startInt > 12 && startInt < 24)
    		startTime = String.valueOf(startInt - 12) + ' pm';
    	else if (startInt == 24)
    		startTime = '12 am';
    	
    	Integer endInt = Integer.valueOf(alsDownEnd);
    	if (endInt == 12)
    		endTime = '12 pm';
    	else if (endInt > 12 && endInt < 24)
    		endTime = String.valueOf(endInt - 12) + ' pm';
    	else if (endInt == 24)
    		endTime = '12 am';
    	
    	//If current time is between times set in custom metadata then ALS is unable to process incoming SFBL request
    	isALSdown = false;
    	String currentHour = Datetime.now().format('HH', 'America/New_York');
    	System.debug('CPA currentHour is: ' + currentHour);
    	Integer currentHourInt = Integer.valueOf(currentHour);
    	if (!String.isBlank(loan.Navy_Core_Code__c) && loan.Navy_Core_Code__c.equalsIgnoreCase('SFBL') && currentHourInt >= Integer.valueOf(alsDownStart) && currentHourInt < Integer.valueOf(alsDownEnd))
    		isALSdown = true;
    	
    	//Set end point where msg is being set as a debug tool
    	String translatedUrlKey = configuration.GetTranslatedKey(System.Label.LOAN_ONBOARDING_URL);
        debugMessage = configuration.GetPropertyByKey(translatedUrlKey);
        if (String.isnotBlank(debugMessage) && debugMessage.containsIgnoreCase('mockable'))
        	debugMessage = 'This Loan is being sent to a test site and NOT the NFCU Middleware';
        else
        	debugMessage = '';
    } //debugMessage
    
    
    //This method sends out the bookLoan message to the middleware endpoint
    @RemoteAction
    global static CBEntities.CoreBookingResponse bookLoan(String loanId) {
    	System.debug('CPA Entering Method bookLoan');
        CBEntities.CoreBookingResponse res = new CBEntities.CoreBookingResponse();
        try {
        	res = orchestrator.BookLoan(loanId, null, null, null);
            if(forceTestingException)
                throw new ControllerException();
        } catch(Exception e) {
            res.IsSuccessful = false;
            res.Messages = String.format(System.Label.CBSendServiceOrchestrationException, 
                    new String[] {
                        System.Label.LoanBooking,
                        e.getMessage()
                    });
        }
        System.debug('CPA Returning CoreBookingResponse: ' + res);
        return res;
    } //bookLoan
    
    
    
    @RemoteAction
    global static CBEntities.TransactionLogResponse getTransactionStatus(String externalId) {
    	System.debug('CPA Entering Method getTransactionStatus');
    	CBEntities.TransactionLogResponse response = orchestrator.GetTransactionLogDetails(externalId);
    	
    	System.debug('CPA returning Transaction Log Details: ' + response);
        return response;
    } //getTransactionStatus
}