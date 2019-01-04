public class ManualExposureCalculation {
    @InvocableMethod
    public static void gottaTestFlows(List<Id> loanIds) {
        if (loanIds != null && loanIds.size() > 0) {
            LLC_BI.ManualStatisticsBatchUpdater msbu = new LLC_BI.ManualStatisticsBatchUpdater(null);
            List<LLC_BI__Loan__c> loans = [select Id from LLC_BI__Loan__c where id in :loanIds];
            if (loans != null) {
                msbu.performUpdate(loans);
                new LLC_BI.LifeCycleDao(msbu).performAllDml();
            }
        }
    }
}