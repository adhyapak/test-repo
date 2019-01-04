global class CBCustomerInvocable extends CBEntities {
    
    @InvocableMethod(label='Core Booking - Customer' description='Books the customer provided in the input on behalf of the user specified to the Core.')
    global static void bookCustomer(List<CBCustomerCalloutInputParams> inputParams) {
        CBPerformCustomerBatchable myBatch = new CBPerformCustomerBatchable(inputParams);
        Database.executeBatch(myBatch);
    }
    
}