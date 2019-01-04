/* Handler for the MMS Email Object Trigger
 * Chintan Adhyapak, West Monroe Partners. January 04, 2019
 */
public class MMCEmailTriggerHandler {
    //Class variables  
  	public static Integer runs = 0;
  	private boolean m_isExecuting = false;
  	private integer batchSize = 0;
  	
  	//Constructor
  	public MMCEmailTriggerHandler(boolean isExecuting, integer size) {
    	m_isExecuting = isExecuting;
    	batchSize = size;
  	} //MMCEmailTriggerHandler
  	
  	
  	//
  	//Public Methods
  	//
   	
   	/* After Insert Handler Method */
 	public void OnAfterInsert(List<MMC_Email__c> newEmails, Map<Id, MMC_Email__c> newEmailMap) {
    	System.debug('CPA Entering MMCEmailTriggerHandler.OnAfterInsert');

    	//Retrieve MMC EMail records that need to be sent
        for (MMC_Email__c email : [Select Id, MMC_Notification_Name__c, Related_Account__r.Member_Access_Number__c, Business_Name__c, Name__c, Email_Address__c,
                Related_Account__r.Phone, Related_Loan__r.Incomplete_Items_Needed_By__c, AA_Reason_1__c, AA_Reason_2__c, AA_Reason_3__c, AA_Reason_4__c,
                BDO_Name__c, BDO_Phone__c, Credit_Score__c, Credit_Score_Date__c, Guarantor_Key_Factor_1__c, Guarantor_Key_Factor_2__c, Guarantor_Key_Factor_3__c,
                Guarantor_Key_Factor_4__c, Loan_App_ID__c, Loan_Decline_Date__c, Product__c 
                From MMC_Email__c
                Where MMC_Record_Sent__c = null]) {
            
            
        }

    	System.debug('CPA Exiting MMCEmailTriggerHandler.OnAfterInsert');
   	} //OnAfterInsert

}