global class CBLoanInvocable extends CBEntities {
    
    @InvocableMethod(label='Core Booking - Loan' description='Books the loan provided in the input on behalf of the user specified to the Core.')
    global static void bookLoan(List<CBLoanCalloutInputParams> inputParams) {
        CBPerformLoanBatchable myBatch = new CBPerformLoanBatchable(inputParams);
        Database.executeBatch(myBatch);
    }
    
}