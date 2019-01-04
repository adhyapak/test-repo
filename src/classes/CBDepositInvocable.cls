global class CBDepositInvocable extends CBEntities {
    
    @InvocableMethod(label='Core Booking - Deposit' description='Books the deposit provided in the input on behalf of the user specified to the Core.')
    global static void bookDeposit(List<CBDepositCalloutInputParams> inputParams) {
        CBPerformDepositBatchable myBatch = new CBPerformDepositBatchable(inputParams);
        Database.executeBatch(myBatch);
    }
    
}