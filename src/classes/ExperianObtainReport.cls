global class ExperianObtainReport extends ExperianCalloutBase {

    @InvocableMethod(label='Obtain Experian Credit Report' description='Obtains the Experian Credit Report for the relationship provided in the input on behalf of the user specified.')
    global static void obtainReport(List<ExperianCalloutInputParams> inputParams) {
        ExperianPerformObtainReport myBatch = new ExperianPerformObtainReport(inputParams);
        Database.executeBatch(myBatch);
    }
    
}