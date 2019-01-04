@isTest
private class TestCBEntities{
    
    @isTest
	private static void TestEntities() {
	    
	    CBEntities.CBLoanCalloutInputParams result1 = new CBEntities.CBLoanCalloutInputParams();
	    result1.loanId = '';
	    result1.externalReferenceId = '';
	    System.assertEquals(true, String.isBlank(result1.loanId));
	    
	    CBEntities.CBCustomerCalloutInputParams result2 = new CBEntities.CBCustomerCalloutInputParams();
	    result2.relationshipId = '';
	    result2.externalReferenceId = '';
	    System.assertEquals(true, String.isBlank(result2.relationshipId));
	    
	    CBEntities.CBDepositCalloutInputParams result3 = new CBEntities.CBDepositCalloutInputParams();
	    result3.depositId = '';
	    result3.externalReferenceId = '';
	    System.assertEquals(true, String.isBlank(result3.depositId));
	    
	    CBEntities.CoreBookingResponse result4 = new CBEntities.CoreBookingResponse();
	    result4.Messages = '';
	    result4.IsSuccessful = true;
	    result4.TransactionLogExternalId = '';
	    System.assertEquals(true, result4.IsSuccessful);
	    
	    CBEntities.TransactionLogResponse result5 = new CBEntities.TransactionLogResponse();
	    result5.Details = '';
	    result5.IsComplete = true;
	    result5.VendorStatus = '';
	    result5.Status = '';
	    result5.ExternalId = '';
	    result5.IsSuccessful = true;
	    System.assertEquals(true, result5.IsComplete);
	    
	}
	
}