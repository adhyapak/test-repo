/**
 * This class contains setup code for the unit tests 
 */
@isTest
public class TestUtility {

    /*
    * public method to setup default product catalog
    */
    public static void configurationSetup() {
 
    productReset();
    
    // Load Product Lines 
    List<LLC_BI__Product_Line__c> prodLines = new List<LLC_BI__Product_Line__c>();
    
        LLC_BI__Product_Line__c loanProductLine = (LLC_BI__Product_Line__c)
          newObject(
            PRODUCT_LINE_TABLE,
            PRODUCT_LINE_KEYS,
            new String[]{LOAN_PRODUCT_LINE,PRODUCT_OBJECT_LOAN}
          );
        prodLines.add(loanProductLine);
        
        LLC_BI__Product_Line__c acctProductLine = (LLC_BI__Product_Line__c)
          newObject(
            PRODUCT_LINE_TABLE,
            PRODUCT_LINE_KEYS,
            new String[]{ACCOUNT_PRODUCT_LINE,PRODUCT_OBJECT_ACCOUNT}
          );
        prodLines.add(acctProductLine);
        
        insert prodLines;
        
        // Load Product Type(s)
        List<LLC_BI__Product_Type__c> productTypes = new List<LLC_BI__Product_Type__c>();

        LLC_BI__Product_Type__c loanProductType = (LLC_BI__Product_Type__c)
          newObject(
            PRODUCT_TYPE_TABLE,
            PRODUCT_TYPE_KEYS,
            new String[]{LOAN_PRODUCT_TYPE,USAGE_TYPE_LOAN, loanProductLine.Id, LOAN_PRODUCT_TYPE_LOOKUPKEY}
          );
        productTypes.add(loanProductType);
            
        LLC_BI__Product_Type__c acctProductType = (LLC_BI__Product_Type__c)
          newObject(
            PRODUCT_TYPE_TABLE,
            PRODUCT_TYPE_KEYS,
            new String[]{ACCOUNT_PRODUCT_TYPE,USAGE_TYPE_ACCOUNT, acctProductLine.Id, ACCOUNT_PRODUCT_TYPE_LOOKUPKEY}
          );
        productTypes.add(acctProductType);
        
        insert productTypes;
        
        // Load Products
        List<LLC_BI__Product__c> products = new List<LLC_BI__Product__c>();
            
        LLC_BI__Product__c loanProduct = (LLC_BI__Product__c)
      newObject(
        PRODUCT_TABLE,
        PRODUCT_KEYS,
        new String[]{LOAN_PRODUCT, loanProductType.Id}
      );
        products.add(loanProduct);

        LLC_BI__Product__c accountProduct = (LLC_BI__Product__c)
      newObject(
        PRODUCT_TABLE,
        PRODUCT_KEYS,
        new String[]{ACCOUNT_PRODUCT, acctProductType.Id}
      );
        products.add(accountProduct);
        
        insert products;

      //
      // Configure Change Memo Enabled
      //
     configurationReset('KY_GBL_ChangeMemo');
    
    LLC_BI__CFG_ConfigKey__c CM_key = 
      (LLC_BI__CFG_ConfigKey__c)newObject(
        CONFIG_KEY_TABLE,
        new String[]{'Name'},
        new String[]{'KY_GBL_ChangeMemo'}
      );    
    insert CM_key;
    
    LLC_BI__CFG_ConfigValue__c CM_value = 
      (LLC_BI__CFG_ConfigValue__c)newObject(
        CONFIG_VALUE_TABLE,
        CONFIG_VALUE_KEYS,
        new String[]{'CM_Enabled',null,'Yes','Change Memo'}
      );
    insert CM_value;
    
    LLC_BI__CFG_CKJ__c CM_joinRecord = 
      (LLC_BI__CFG_CKJ__c)newObject(
        'LLC_BI__CFG_CKJ__c',
        CONFIG_JOIN_KEYS,
        new String[]{CM_key.Id, CM_value.Id}
      );    
    insert CM_joinRecord;

      //
      // Configure Change Memo Name
      //
    
    CM_key = 
      (LLC_BI__CFG_ConfigKey__c)newObject(
        CONFIG_KEY_TABLE,
        new String[]{'Name'},
        new String[]{'KY_GBL_ChangeMemo'}
      );    
    insert CM_key;
    
    CM_value = 
      (LLC_BI__CFG_ConfigValue__c)newObject(
        CONFIG_VALUE_TABLE,
        CONFIG_VALUE_KEYS,
        new String[]{'CM_Name',null,'Change Memo','Change Memo'}
      );
    insert CM_value;
    
    CM_joinRecord = 
      (LLC_BI__CFG_CKJ__c)newObject(
        'LLC_BI__CFG_CKJ__c',
        CONFIG_JOIN_KEYS,
        new String[]{CM_key.Id, CM_value.Id}
      );    
    insert CM_joinRecord;

      //
      // Configure Namespace Prefix
      //
     configurationReset('KY_GBL_NamespacePrefixBI');
    
    LLC_BI__CFG_ConfigKey__c key = 
      (LLC_BI__CFG_ConfigKey__c)newObject(
        CONFIG_KEY_TABLE,
        new String[]{'Name'},
        new String[]{'KY_GBL_NamespacePrefixBI'}
      );    
    insert key;
    
    LLC_BI__CFG_ConfigValue__c value = 
      (LLC_BI__CFG_ConfigValue__c)newObject(
        CONFIG_VALUE_TABLE,
        CONFIG_VALUE_KEYS,
        new String[]{'Bankr_BI_Prefix',null,null,'General'}
      );
    insert value;
    
    LLC_BI__CFG_CKJ__c joinRecord = 
      (LLC_BI__CFG_CKJ__c)newObject(
        'LLC_BI__CFG_CKJ__c',
        CONFIG_JOIN_KEYS,
        new String[]{key.Id, value.Id}
      );    
    insert joinRecord;
     
       //
       // Configure Loan Stages
       //
         configurationReset(LOAN_PRODUCT_TYPE_LOOKUPKEY);         
        configurationReset(ACCOUNT_PRODUCT_TYPE_LOOKUPKEY);         

    LLC_BI__CFG_ConfigKey__c keyLoanProductType = 
      (LLC_BI__CFG_ConfigKey__c)newObject(
        CONFIG_KEY_TABLE,
        new String[]{'Name'},
        new String[]{LOAN_PRODUCT_TYPE_LOOKUPKEY}
      );    
    insert keyLoanProductType;

    //
    // Complete Loan Stage
    //
    value = 
      (LLC_BI__CFG_ConfigValue__c)newObject(
        CONFIG_VALUE_TABLE,
        CONFIG_VALUE_KEYS,
        new String[]{'Complete','Complete','Complete','Loan Stage'}
      );
    insert value;
    
    joinRecord = 
      (LLC_BI__CFG_CKJ__c)newObject(
        'LLC_BI__CFG_CKJ__c',
        CONFIG_JOIN_KEYS,
        new String[]{keyLoanProductType.Id, value.Id}
      );    
    insert joinRecord;

    //
        // Closed Loan Stage
    //
    value = 
      (LLC_BI__CFG_ConfigValue__c)newObject(
        CONFIG_VALUE_TABLE,
        CONFIG_VALUE_KEYS,
        new String[]{'Closed','Closed Funded','Closed Funded','Loan Stage'}
      );
    insert value;
    
    joinRecord = 
      (LLC_BI__CFG_CKJ__c)newObject(
        'LLC_BI__CFG_CKJ__c',
        CONFIG_JOIN_KEYS,
        new String[]{keyLoanProductType.Id, value.Id}
      );    
    insert joinRecord;

    //
        // Configure Declined Status
    //
    value = 
      (LLC_BI__CFG_ConfigValue__c)newObject(
        CONFIG_VALUE_TABLE,
        CONFIG_VALUE_KEYS,
        new String[]{'Declined','Declined','Declined','Loan Stage'}
      );
    insert value;
    
    joinRecord = 
      (LLC_BI__CFG_CKJ__c)newObject(
        'LLC_BI__CFG_CKJ__c',
        CONFIG_JOIN_KEYS,
        new String[]{keyLoanProductType.Id, value.Id}
      );    
    insert joinRecord;

    //
        //Add Doc Manager records
    //
    List<LLC_BI__DocManager__c> docManagers = new List<LLC_BI__DocManager__c>();
    LLC_BI__DocManager__c acctDocMan = 
      (LLC_BI__DocManager__c) newObject(
        DOC_MANAGER_TABLE,
        DOCUMENT_MANAGER_KEYS,
        new String[]{'Account', ACCOUNT_DM_LOOKUPKEY}
      );
    docManagers.add(acctDocMan);  
    LLC_BI__DocManager__c loanDocMan = 
      (LLC_BI__DocManager__c) newObject(
        DOC_MANAGER_TABLE,
        DOCUMENT_MANAGER_KEYS,
        new String[]{'Loan', LOAN_DM_LOOKUPKEY}
      );
    docManagers.add(loanDocMan);
    
    insert docManagers;  
      
    List<LLC_BI__DocTab__c> tabs = new List<LLC_BI__DocTab__c>();
    LLC_BI__DocTab__c acctTabOne = 
      (LLC_BI__DocTab__c) newObject(
        DOCUMENT_TAB_TABLE,
        DOCUMENT_TAB_KEYS,
        new String[]{
          'Servicing',
          loanDocMan.Id, 
          'TAB-SERVICING',
          'statusIcon;name;docType;firstReview;status;owner;priority;date;exceptionDate;comment',
          'Closer',
          '001'
        }
      );
    tabs.add(acctTabOne);
    
    LLC_BI__DocTab__c loanTabOne = 
      (LLC_BI__DocTab__c) newObject(
        DOCUMENT_TAB_TABLE,
        DOCUMENT_TAB_KEYS,
        new String[]{
          'Credit File',
          acctDocMan.Id, 
          'TAB-CREDITFILE',
          'statusIcon;name;docType;firstReview;status;owner;priority;date;exceptionDate;comment',
          'Closer',
          '001'
        }
      );
    tabs.add(loanTabOne);
    
    insert tabs;
    
    List<LLC_BI__DocType__c> types = new List<LLC_BI__DocType__c>();
    
    LLC_BI__DocType__c acctDocTypeOne = 
      (LLC_BI__DocType__c) newObject(
        DOCUMENT_TYPE_TABLE,
        DOCUMENT_TYPE_KEYS,
        new String[]{'Folder One',acctDocMan.Id, acctTabOne.Id, 'ACCT_TYPE_ONE','001'}
      );
    types.add(acctDocTypeOne);

    LLC_BI__DocType__c loanDocTypeOne = 
      (LLC_BI__DocType__c) newObject(
        DOCUMENT_TYPE_TABLE,
        DOCUMENT_TYPE_KEYS,
        new String[]{'Folder One',loanDocMan.Id, loanTabOne.Id, 'LOAN_TYPE_ONE','001'}
      );
    types.add(loanDocTypeOne);
    
    insert types;

    List<LLC_BI__DocClass__c> classes = new List<LLC_BI__DocClass__c>();
    LLC_BI__DocClass__c acctDocClassOne = 
      (LLC_BI__DocClass__c) newObject(
        DOCUMENT_CLASS_TABLE,
        DOCUMENT_CLASS_KEYS,
        new String[]{'Account Document One',acctDocMan.Id, acctDocTypeOne.Id, 'ACCT_DOCUMENT_ONE'}
      );
    classes.add(acctDocClassOne);

    LLC_BI__DocClass__c loanDocClassOne = 
      (LLC_BI__DocClass__c) newObject(
        DOCUMENT_CLASS_TABLE,
        DOCUMENT_CLASS_KEYS,
        new String[]{'Loan Document One',loanDocMan.Id, loanDocTypeOne.Id, 'LOAN_DOCUMENT_ONE'}
      );
    classes.add(loanDocClassOne);
    
    insert classes;
    
    List<LLC_BI__ClosingChecklist__c> CCList = new List<LLC_BI__ClosingChecklist__c>();
    
    LLC_BI__ClosingChecklist__c acctCCLOne = 
      (LLC_BI__ClosingChecklist__c) newObject(
        CLOSING_CHECKLIST_TABLE,
        CLOSING_CHECKLIST_KEYS,
        new String[]{'ACCT CCL ONE', acctDocMan.Id, acctTabOne.Id, acctDocTypeOne.Id, acctDocClassOne.Id, 'ACCT_CCL_ONE','001'}
      );
    CCList.add(acctCCLOne);
    
    LLC_BI__ClosingChecklist__c loanCCLOne = 
      (LLC_BI__ClosingChecklist__c) newObject(
        CLOSING_CHECKLIST_TABLE,
        CLOSING_CHECKLIST_KEYS,
        new String[]{'LOAN CCL ONE', loanDocMan.Id, loanTabOne.Id, loanDocTypeOne.Id, loanDocClassOne.Id, 'LOAN_CCL_ONE','001'}
      );
    CCList.add(loanCCLOne);
    
    insert CCList;

    List<LLC_BI__ProductCCL__c> prodCCLs = new List<LLC_BI__ProductCCL__c>();
    LLC_BI__ProductCCL__c acctProdCCL =
      (LLC_BI__ProductCCL__c) newObject(
        PRODUCT_CCL_TABLE,
        PRODUCT_CCL_KEYS,
        new String[]{acctCCLOne.Id,accountProduct.Id}
      );
    prodCCLs.add(acctProdCCL);
          
    LLC_BI__ProductCCL__c loanProdCCL =
      (LLC_BI__ProductCCL__c) newObject(
        PRODUCT_CCL_TABLE,
        PRODUCT_CCL_KEYS,
        new String[]{loanCCLOne.Id,loanProduct.Id}
      );
    prodCCLs.add(loanProdCCL);
    
    insert(prodCCLs);
          
    List<LLC_BI__ProductDocTab__c> prodDocTabs = new List<LLC_BI__ProductDocTab__c>();
    LLC_BI__ProductDocTab__c acctProdDocTab =
      (LLC_BI__ProductDocTab__c) newObject(
        PRODUCT_DOC_TAB_TABLE,
        PRODUCT_DOC_TAB_KYES,
        new String[]{acctTabOne.Id,accountProduct.Id}
      );
    prodDocTabs.add(acctProdDocTab);
          
    LLC_BI__ProductDocTab__c loanProdDocTab =
      (LLC_BI__ProductDocTab__c) newObject(
        PRODUCT_DOC_TAB_TABLE,
        PRODUCT_DOC_TAB_KYES,
        new String[]{loanTabOne.Id,loanProduct.Id}
      );
    prodDocTabs.add(loanProdDocTab);
    
    insert(prodDocTabs);
    }
    
    /*******************************
    * private helper methods
    ********************************/
    private static void productReset(){
    List<LLC_BI__Product_Line__c> pline = 
      [SELECT 
        id 
      FROM 
        LLC_BI__Product_Line__c  
      WHERE 
        Name != null
      ];
    if (pline != null && pline.size() > 0) {
      delete pline;
    }
    List<LLC_BI__Product_Type__c> ptype = 
      [SELECT 
        id 
      FROM 
        LLC_BI__Product_Type__c 
      WHERE 
        Name != null
      ];
    if (ptype != null && ptype.size() > 0) {
      delete ptype;
    }
    List<LLC_BI__Product__c> prod = 
      [SELECT 
        id 
      FROM 
        LLC_BI__Product__c 
      WHERE 
        Name != null
      ];
    if (prod != null && prod.size() > 0) {
      delete prod;
    }      
    }

    private static void configurationReset(String configurationKey) {
        LLC_BI__CFG_ConfigKey__c confKey = null;
        try {
          confKey = 
          [SELECT
                 Id
      FROM
        LLC_BI__CFG_ConfigKey__c
          WHERE
        LLC_BI__CFG_ConfigKey__c.name = :configurationKey
          ];
          
          if (confKey != null) {
              List<LLC_BI__CFG_CKJ__c> joinValues =
                  [SELECT
                      LLC_BI__CFG_ConfigValue__c
                  FROM
                      LLC_BI__CFG_CKJ__c
                  WHERE
                      LLC_BI__CFG_ConfigKeys__c =:confKey.id
                  ];
                  
              for (LLC_BI__CFG_CKJ__c value: joinValues) {
                  List<LLC_BI__CFG_ConfigValue__c> configValues = 
                  [SELECT
                      LLC_BI__Key__c,
                      LLC_BI__Value__c,
                      LLC_BI__fieldValue__c,
                      LLC_BI__Category__c
                  FROM
                      LLC_BI__CFG_ConfigValue__c
                  WHERE
                      id =: value.LLC_BI__CFG_ConfigValue__c
                   ];
                   delete configValues;
              }
              delete confKey;
          }
        } catch (Exception e) {
            // they don't exist, do nothing
        }
    }

    public static sObject newObject(String objectTypeName, String[] fieldNames, String[] values) {
      sObject obj = Schema.getGlobalDescribe().get(objectTypeName).newSObject();
      for (Integer i = 0; i < fieldNames.size(); i++ ) {
        obj.put(fieldNames[i],values[i]);
      }
      return obj;
    }
    
  /*
  * private static constants
  */
    public static final String LOAN_PRODUCT_LINE      = 'Loan Product Line';
    public static final String ACCOUNT_PRODUCT_LINE      = 'Account Product Line';
    
    public static final String LOAN_PRODUCT_TYPE      = 'Loan Product Type';
    public static final String LOAN_PRODUCT_TYPE_LOOKUPKEY  = 'PT01';
    public static final String LOAN_PRODUCT          = 'Loan Product';
    
    public static final String ACCOUNT_PRODUCT_TYPE      = 'Account Product Type';
    public static final String ACCOUNT_PRODUCT_TYPE_LOOKUPKEY  = 'PT02';
    public static final String ACCOUNT_PRODUCT        = 'Account Product';

    private static final String PRODUCT_OBJECT_LOAN      = 'Loan__c';
    private static final String USAGE_TYPE_LOAN        = 'Loan';
    private static final String PRODUCT_OBJECT_ACCOUNT    = null;
    private static final String USAGE_TYPE_ACCOUNT      = 'BUSINESS';
    
    private static final String ACCOUNT_DM_LOOKUPKEY    = 'ACCOUNT_DM';
    private static final String LOAN_DM_LOOKUPKEY      = 'LOAN_DM';
    
    private static final String[] CONFIG_VALUE_KEYS     = new String[]{'LLC_BI__Key__c','LLC_BI__Value__c','LLC_BI__FieldValue__c','LLC_BI__Category__c'};
    private static final String[] CONFIG_JOIN_KEYS      = new String[]{'LLC_BI__CFG_ConfigKeys__c','LLC_BI__CFG_ConfigValue__c'};
    private static final String[] PRODUCT_LINE_KEYS      = new String[]{'Name','LLC_BI__Product_Object__c'};
    private static final String[] PRODUCT_TYPE_KEYS      = new String[]{'Name','LLC_BI__Usage_Type__c','LLC_BI__Product_Line__c','LLC_BI__lookupKey__c'};
    private static final String[] PRODUCT_KEYS        = new String[]{'Name','LLC_BI__Product_Type__c'};
    private static final String[] DOCUMENT_MANAGER_KEYS   = new String[]{'Name','LLC_BI__lookupKey__c'};
  private static final String[] DOCUMENT_TAB_KEYS        = new String[]{'Name','LLC_BI__DocManager__c','LLC_BI__LookupKey__c','LLC_BI__columns__c','LLC_BI__defaultOwner__c','LLC_BI__sortOrder__c'};
  private static final String[] DOCUMENT_TYPE_KEYS    = new String[]{'Name','LLC_BI__docManager__c','LLC_BI__docTab__c','LLC_BI__lookupKey__c','LLC_BI__sortOrder__c'};
  private static final String[] DOCUMENT_CLASS_KEYS    = new String[]{'Name','LLC_BI__docManager__c','LLC_BI__DocType__c','LLC_BI__lookupKey__c'};
  private static final String[] CLOSING_CHECKLIST_KEYS   = new String[]{'Name','LLC_BI__docManager__c','LLC_BI__docTab__c','LLC_BI__docType__c','LLC_BI__docClass__c','LLC_BI__lookupKey__c','LLC_BI__sortOrder__c'};
  private static final String[] PRODUCT_CCL_KEYS      = new String[]{'LLC_BI__Closing_Checklist__c','LLC_BI__Product__c'};
  private static final String[] PRODUCT_DOC_TAB_KYES    = new String[]{'LLC_BI__DocTab__c','LLC_BI__Product__c'};
    
    private static final String CONFIG_KEY_TABLE      = LLC_BI__CFG_ConfigKey__c.sObjectType.getDescribe().getName();
    private static final String CONFIG_JOIN_TABLE      = LLC_BI__CFG_CKJ__c.sObjectType.getDescribe().getName();
    private static final String CONFIG_VALUE_TABLE      = LLC_BI__CFG_ConfigValue__c.sObjectType.getDescribe().getName();
    private static final String PRODUCT_LINE_TABLE      = LLC_BI__Product_Line__c.sObjectType.getDescribe().getName();
    private static final String PRODUCT_TYPE_TABLE      = LLC_BI__Product_Type__c.sObjectType.getDescribe().getName();
    private static final String PRODUCT_TABLE        = LLC_BI__Product__c.sObjectType.getDescribe().getName();
    private static final String DOC_MANAGER_TABLE      = LLC_BI__DocManager__c.sObjectType.getDescribe().getName();
    private static final String DOCUMENT_TAB_TABLE      = LLC_BI__DocTab__c.sObjectType.getDescribe().getName();
    private static final String DOCUMENT_TYPE_TABLE      = LLC_BI__DocType__c.sObjectType.getDescribe().getName();
    private static final String DOCUMENT_CLASS_TABLE    = LLC_BI__DocClass__c.sObjectType.getDescribe().getName();
    private static final String CLOSING_CHECKLIST_TABLE    = LLC_BI__ClosingChecklist__c.sObjectType.getDescribe().getName();
    private static final String PRODUCT_CCL_TABLE      = LLC_BI__ProductCCL__c.sObjectType.getDescribe().getName();
    private static final String PRODUCT_DOC_TAB_TABLE    = LLC_BI__ProductDocTab__c.sObjectType.getDescribe().getName();
}