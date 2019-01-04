@isTest
public class TestOverviewUpdateConfiguration{
    @isTest
    private static void testConfigure_ReturnsConfigurationPage(){
        OverviewUpdateConfiguration config = new OverviewUpdateConfiguration();

        Test.startTest();
        PageReference pageRef = config.configure();
        Test.stopTest();

        System.assertNotEquals(null, pageRef);
        System.assertEquals(Page.OverviewUpdatePage.getUrl(), pageRef.getUrl());
        System.assertEquals(true, pageRef.getRedirect());
    }
    @isTest
    private static void testBack_ReturnsOverviewPage(){
        OverviewUpdateConfiguration config = new OverviewUpdateConfiguration();

        Test.startTest();
        PageReference pageRef = config.back();
        Test.stopTest();

        System.assertNotEquals(null, pageRef);
        System.assertEquals(Page.LLC_BI__SystemAdministration.getUrl(), pageRef.getUrl());
    }
}