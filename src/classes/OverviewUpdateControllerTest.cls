@isTest(SeeAllData=true)
private class OverviewUpdateControllerTest {
    static testMethod void CommercialTest() {

    	Commercial_Overview__c com = new Commercial_Overview__c();
    	com.Name = COMMERCIAL_NAME;
    	com.Stage__c = COMMERCIAL_STAGE;
    	com.Active__c = true;
    	com.Report_Name__c = 'Stage = Booked';
    	com.Link_URL__c = '';
    	com.Display_Order__c = 1;
        com.Custom_Label_Key__c = COMMERCIAL_KEY;
    	insert com;

        Test.startTest();
        
        OverviewUpdateController controller = new OverviewUpdateController();
        controller.getProfileName();
        controller.runUpdate(); 

        Test.stopTest();

        Report r = [SELECT Id, Name FROM Report WHERE Name =: com.Report_Name__c];
        Commercial_Overview__c c = [SELECT Id, Name, Stage__c, Link_URL__c, Active__c, Display_Order__c, Report_Name__c FROM Commercial_Overview__c WHERE Active__c = true AND Report_Name__c != null AND Id =: com.Id];
    	
    	System.assertEquals(com.Name, c.Name);
        System.assertEquals(com.Stage__c, c.Stage__c);
        System.assertEquals(com.Active__c, c.Active__c);
        System.assertEquals(com.Report_Name__c, c.Report_Name__c);
        System.assertEquals(com.Display_Order__c, c.Display_Order__c);
    }

    static testMethod void ConsumerTest() {

        Consumer_Overview__c con = new Consumer_Overview__c();
        con.Name = CONSUMER_NAME;
        con.Stage__c = CONSUMER_STAGE;
        con.Active__c = true;
        con.Report_Name__c = 'Stage = Complete';
        con.Link_URL__c = '';
        con.Display_Order__c = 1;
        con.Custom_Label_Key__c = CONSUMER_KEY;
        insert con;

        Test.startTest();
        
        OverviewUpdateController controller = new OverviewUpdateController();
        controller.getProfileName();
        controller.runUpdate(); 

        Test.stopTest();

        Report r = [SELECT Id, Name FROM Report WHERE Name =: con.Report_Name__c];
        Consumer_Overview__c c = [SELECT Id, Name, Stage__c, Link_URL__c, Active__c, Display_Order__c, Report_Name__c FROM Consumer_Overview__c WHERE Active__c = true AND Report_Name__c != null AND Id =: con.Id];
        
        System.assertEquals(con.Name, c.Name);
        System.assertEquals(con.Stage__c, c.Stage__c);
        System.assertEquals(con.Active__c, c.Active__c);
        System.assertEquals(con.Report_Name__c, c.Report_Name__c);
        System.assertEquals(con.Display_Order__c, c.Display_Order__c);
    }

    private static final String COMMERCIAL_NAME = 'Test Commercial Record';
    private static final String COMMERCIAL_STAGE = 'Test Commercial Stage';
    private static final String COMMERCIAL_REPORT_NAME = 'Stage = Booked';
    private static final String COMMERCIAL_KEY = 'Test_Booked_Stage';

    private static final String CONSUMER_NAME = 'Test Consumer Record';
    private static final String CONSUMER_STAGE = 'Test Consumer Stage';
    private static final String CONSUMER_REPORT_NAME = 'Stage = Complete';
    private static final String CONSUMER_KEY = 'Test_Complete_Stage';
}