@isTest(SeeAllData=true)
public class TestCSA_PPoNLYCMApprovalWidget {
	@isTest(SeeAllData=true) //Needed due to SFDC limitation in StepAndWorkItems
							 //https://success.salesforce.com/issues_view?id=a1p30000000SWMFAA4
	public static void testGetSetApprovalSteps() {
	CSA_PPOnlyCMApprovalHistory testHistory = new CSA_PPOnlyCMApprovalHistory();
       
	LLC_BI__Product_Package__c productpackageid = testCreateApprovalProcessWorkflow();
	Test.startTest();

        
	testHistory.pp_id = productpackageid.Id;
	testHistory.listHelper = new nFORCE.SObjectScreenResourceListHelper();
	testHistory.resources = testHistory.listHelper.buildResourceList(productpackageid);
	testHistory.load();
	Test.stopTest();
	}


	private static User createUser() {
		Profile pro = [
			SELECT
				Id
			FROM
				Profile
			WHERE
				Id != null
			AND
				Name = 'System Administrator'
			LIMIT 1];

		User u = new User(
			FirstName = 'testFName',
			LastName = 'testLName',
			Username = 'test5555@username.com',
			Alias = 'testU',
			Email = 'test@email.com',
			EmailEncodingKey = 'UTF-8',
			LanguageLocaleKey = 'en_US',
			LocaleSidKey = 'en_US',
			ProfileId = pro.Id,
			TimeZoneSidKey = 'America/Los_Angeles',
			Lending_Auth_Non_Critical_Exceptions__c = 1000.0,
			Total_Lending_Limit__c = 1000.0,
			Lending_Auth_Override__c = 1000.0,
			Lending_Auth_w_Critical_Exceptions__c = 355.0);
		insert u;
		return u;
	}

	private static LLC_BI__Product_Package__c testCreateApprovalProcessWorkflow(){
		User testUser = createUser();
		LLC_BI__Product_Package__c testProductPackage = new LLC_BI__Product_Package__c(Name = 'Test Product Package Accelerator', OwnerId = testUser.Id);
        insert testProductPackage;
		System.debug('***********' + testProductPackage.Id);
		Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
		req1.setComments('Submitting request');
		req1.setObjectId(testProductPackage.Id);
		req1.setNextApproverIds(new List<Id>{testUser.Id});
		//Next 2 lines added by Chintan Adhyapak, West Monroe Partners, April 12, 2018
		req1.setProcessDefinitionNameOrId('PAPP200_Credits_w_No_Exceptions');
        req1.setSkipEntryCriteria(true);

		Approval.ProcessResult result = Approval.process(req1);
		System.assert(result.isSuccess());
		System.assertEquals('Pending', result.getInstanceStatus(),
		'Instance Status ' + result.getInstanceStatus());
		List<Id> newWorkItemIds = result.getNewWorkitemIds();
		System.debug('Test work id'+ newWorkItemIds);
		Approval.ProcessWorkItemRequest req2 =
			new Approval.ProcessWorkItemRequest();
		
        req2.setComments('Approving Request');
		req2.setAction('Approve');
		req2.setNextApproverIds(new List<Id>{testUser.Id});
		req2.setWorkitemId(newWorkItemIds.get(0));

		Approval.ProcessResult result2 = Approval.process(req2);
		System.assert(result2.isSuccess(), 'Result Status:'+ result2.isSuccess());
		System.assertEquals(
			'Approved', result2.getInstanceStatus(),
			'Instance Status ' + result2.getInstanceStatus());

        return testProductPackage;
	}


	private static final String TEST_LOAN_APPROVAL_PROCESS_LOAN_NAME = 'TEST_SINGLE_STEP_LOAN_APPROVAL_PROCESS';
}