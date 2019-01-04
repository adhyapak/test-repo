@isTest
private with sharing class csaTestHmdaExtractGenerationController {

    @isTest
    static void testRunGeneration() {
        Datetime dt = Datetime.now();
        Long l = dt.getTime();
        String output = String.valueOf(l);
        Map<String, Object> params = new Map<String, Object>();
        params.put(csaHmdaExtractConstants.STARTDATE, output);
        params.put(csaHmdaExtractConstants.ENDDATE, output);

        Test.startTest();

        nFORCE.RemoteActionController.invoke('csaHmdaExtractGenerationController.RunGeneration', params);
        List<AsyncApexJob> jobInfo = [SELECT Status, NumberOfErrors FROM AsyncApexJob LIMIT 1];

        Test.stopTest();

        System.assertEquals(1, jobInfo.size());
    }

    @TestSetup
    private static void testSetup() {
        nFORCE.BeanRegistry.getInstance().registerBean(
            'ClassTypeProvider',
            nFORCE.ClassTypeProvider.class,
            Type.forName('ClassTypeProvider')
        );
    }
}