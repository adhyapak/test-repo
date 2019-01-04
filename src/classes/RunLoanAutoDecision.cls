global without sharing class RunLoanAutoDecision {
    @InvocableMethod (label='Run Loan Auto Desc' description='Run Loan Auto Desc.')
    global static void runLoanAutoDesc(List<Id> loans) {
        if(loans.size() > 0){
            RunCallout myBatch = new RunCallout(loans[0], UserInfo.getSessionId());
            Database.executeBatch(myBatch);
        }
    }
}