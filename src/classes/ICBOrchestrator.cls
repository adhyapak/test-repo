public interface ICBOrchestrator {
	CBEntities.TransactionLogResponse GetTransactionLogDetails(String externalId);
	CBEntities.CoreBookingResponse BookLoan(String loanId, String overrideUserId, String overrideUserSessionId, String overrideTransactionLogExternalId);
	CBEntities.CoreBookingResponse BookCustomer(String relationshipId, String overrideUserId, String overrideUserSessionId, String overrideTransactionLogExternalId);
	CBEntities.CoreBookingResponse BookDeposit(String depositId, String overrideUserId, String overrideUserSessionId, String overrideTransactionLogExternalId);
}