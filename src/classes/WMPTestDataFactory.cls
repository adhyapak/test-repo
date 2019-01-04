/**
 * This class has static methods to create records for other test classes
 * Adam Smith, West Monroe Partners. April 3, 2018 (created as WMPTestDataFactory)
 * Chintan Adhyapak, West monroe Partners. April 18, 2018. Added new methods
 */
@isTest
public class WMPTestDataFactory
{
	//class variables
	private static final String CHECKING_CATEGORY = 'Checking';
	private static final String SAVINGS_CATEGORY = 'Savings';
	private static final Decimal SAVINGS_AMOUNT1 = 1000.00;
	private static final Decimal SAVINGS_AMOUNT2 = 2000.00;
	private static final Decimal SAVINGS_AMOUNT3 = 3000.00;
	private static final String SAVINGS_ACCOUNT_NUMBER1 = 'Account 1';
	private static final String SAVINGS_ACCOUNT_NUMBER2 = 'Account 2';
	private static final String SAVINGS_ACCOUNT_NUMBER3 = 'Account 3';
	private static final String PRIMARY_OWNER = 'Primary Owner';
	private static final String FROM_STAGE = 'Decisioning';
	private static final Map<String, Id> recordTypeMap = new Map<String, Id>();

	//Save account/relationship record types
	public static void saveAccountTypes() {
		System.debug('CPA Saving Account Types');

		//Read Account/Relationship record types
		for (RecordType recType : [SELECT Id,Name FROM RecordType WHERE SobjectType = 'Account' AND IsActive = true AND NamespacePrefix = 'LLC_BI']) {
			recordTypeMap.put(recType.Name, recType.Id);
		}
		System.assertEquals(false, recordTypeMap.isEmpty());
	}
	
	

	//Create Accounts
	public static List<Account> createAccounts(Integer numAccts, String recordType) {
		System.debug('CPA creating ' + numAccts + ' accounts with ' + recordType + ' record type');

		saveAccountTypes();

		List<Account> accts = new List<Account> ();

		for (Integer i = 0; i < numAccts; i++) {
			Account acct = new Account (
				Name = 'Apex Relationship ' + i,
				LLC_BI__Tax_Identification_Number_PE__c = '123456789',
				ShippingState = 'IL',
				BillingState = 'IL',
				recordTypeId = recordTypeMap.get(recordType)
			);
			accts.add(acct);
		}
		insert accts;
		return accts;
	}



	//Create Product Lines > Product Types > Products
	public static List<LLC_BI__Product__c> createProducts() {
		System.debug('CPA creating products');

		List<LLC_BI__Product_Line__c> productLines = new List<LLC_BI__Product_Line__c> ();
		List<LLC_BI__Product_Type__c> productTypes = new List<LLC_BI__Product_Type__c> ();
		List<LLC_BI__Product__c> products = new List<LLC_BI__Product__c> ();

		//Create product line
		LLC_BI__Product_Line__c productLineA = new LLC_BI__Product_Line__c(
			Name = 'Apex Product Line A',
			LLC_BI__Category__c = 'Consumer',
			LLC_BI__Product_Object__c = 'Loan__c'
		);
		productLines.add(productLineA);
		insert productLines;

		//Create product types
		LLC_BI__Product_Type__c productTypeA = new LLC_BI__Product_Type__c(
			Name = CHECKING_CATEGORY,
			LLC_BI__Product_Line__c = productLineA.Id,
			LLC_BI__Category__c = CHECKING_CATEGORY
		);
		LLC_BI__Product_Type__c productTypeB = new LLC_BI__Product_Type__c(
			Name = SAVINGS_CATEGORY,
			LLC_BI__Product_Line__c = productLineA.Id,
			LLC_BI__Category__c = SAVINGS_CATEGORY
		);
		productTypes.add(productTypeA);
		productTypes.add(productTypeB);
		insert productTypes;

		//Create products
		LLC_BI__Product__c productA = new LLC_BI__Product__c(
			Name = 'Product A',
			LLC_BI__Product_Type__c = productTypeA.Id
		);
		LLC_BI__Product__c productB = new LLC_BI__Product__c(
			Name = 'Product B',
			LLC_BI__Product_Type__c = productTypeB.Id
		);
		products.add(productA);
		products.add(productB);

		insert products;
		return products;
	}
	
	

	//Create Loans
	public static List<LLC_BI__Loan__c> createLoans(Integer numLoans) {
		List<LLC_BI__Loan__c> loans = new List<LLC_BI__Loan__c> ();

		for (Integer i = 0; i < numLoans; i++) {
			LLC_BI__Loan__c loan = new LLC_BI__Loan__c (

			);
			loans.add(loan);
		}
		return loans;
	}



	//Create FICO Information
	public static List<SBSS__FICO_LiquidCredit_Information__c> createFICO() {
		System.debug('CPA creating FICO Information records');

		List<SBSS__FICO_LiquidCredit_Information__c> ficos = new List<SBSS__FICO_LiquidCredit_Information__c> ();

		SBSS__FICO_LiquidCredit_Information__c ficoA = new SBSS__FICO_LiquidCredit_Information__c (
			SBSS__cba_cb_bkrp_ind__c = 'Bankruptcy on credit bureau report'
		);

		return ficos;
	}
	
	
	
	/** Random Number Generator
	  * Chintan Adhyapak, West Monroe Partners, April 18, 2018
	  */
	public static Integer getRandomNumber(Integer upperLimit) {
        Integer rand = Math.round(Math.random()*1000);
        return Math.mod(rand, upperLimit);
    } //getRandomNumber
    
    
	
	/**
     * Creates a test user  
     * @param profileName - the Profile for the user
     * @param noWorkFlow - The No Workflow checkbox for the user
     * @returns User the newly created User
     * Chintan Adhyapak, West Monroe Partners, April 18, 2018
     */
    public static User createUser(String profileName, Boolean noWorkFlow) {
        return createUser(profileName, noWorkFlow, 'West Monroe', 'Partners');
    } //createUser
    
    
    
    
    /**
     * Creates a test user  
     * @param profileName - the Profile for the user
     * @param noWorkFlow - The No Workflow checkbox for the user
     * @param firstName - FirstName
     * @param lastName - LastName
     * @returns User the newly created User
     * Chintan Adhyapak, West Monroe Partners, April 18, 2018
     */
    public static User createUser(String profileName, Boolean noWorkFlow, String firstName, String lastName) {
        User newUser = new User(); 
        newUser.Username = getRandomNumber(5000) + '@apexTest.com';
        newUser.FirstName = firstName;
        newUser.LastName = lastName;        
        newUser.Email = getRandomNumber(5000) + '@apexTest.com';
        newUser.Alias = 'wmp' + getRandomNumber(5);
        newUser.CommunityNickname = 'wmpro' + getRandomNumber(5000);
        newUser.TimeZoneSidKey = 'America/Chicago';
        newUser.LocaleSidKey = 'en_US';
        newUser.EmailEncodingKey = 'UTF-8';
        newUser.LanguageLocaleKey = 'en_US';
        newUser.Lending_Auth_Non_Critical_Exceptions__c = 100.0;
        newUser.Total_Lending_Limit__c = 100.0;
        newUser.Lending_Auth_Override__c = 10.0;
        newUser.Lending_Auth_w_Critical_Exceptions__c = 50.0;
        newUser.ProfileId = [SELECT Id FROM Profile WHERE Name = :profileName LIMIT 1].Id;
        newUser.No_WorkfLow__c = noWorkFlow;
        
        return newUser;
    } //createUser
}