public with sharing class ProductPRCCLClone
{
    public String sourcePRGS {get; set;}
    public String sourcePR2GS {get; set;}
    public String copyTargetPRsGS {get; set;}
    public String prToKeepGS {get; set;}
    public String removeTargetsGS {get; set;}
    
    public List<LLC_BI__DocManager__c> docMansGS {get;set;}
    public List<LLC_BI__Product__c> productsGS {get;set;}

    List<String> listProductStrings = new List<String>();
    List<String> listProductRemoveStrings = new List<String>();
    
    transient Savepoint sp;
    
    public void autoSetup()
    {
        List<SObject> docMans = [SELECT ID, Name, LLC_BI__lookupKey__c, LLC_BI__namespacePrefix__c, LLC_BI__templateFileName__c, Owner.Name FROM LLC_BI__DocManager__c];
        docMansGS = docMans;
        
        List<SObject> ncinoProducts = [SELECT ID, Name, LLC_BI__lookupKey__c, LLC_BI__Product_Type__r.Name, LLC_BI__Product_Type__r.LLC_BI__Product_Line__r.Name FROM LLC_BI__Product__c
            ORDER BY LLC_BI__Product_Type__r.LLC_BI__Product_Line__r.Name, LLC_BI__Product_Type__r.Name, LLC_BI__lookupKey__c ASC];
        productsGS = ncinoProducts;
    }
    

    //CLONE TO ALL PRODUCTS USING SOURCE
    public void cloneToAll()
    {
        try
        {
            sp = Database.setSavepoint();
            
            String sourcePR = sourcePRGS;
            
            System.debug('***sourcePR***' + sourcePR);
            if (sourcePR.length() == 0 || sourcePR.contains(','))
            {
                System.debug('***ERROR***');                
                InvalidSourceCopy();
            }
            else
            {
                System.debug('***NO ERROR***');
                List<LLC_BI__ProductCCL__c> pr_ccl = new List<LLC_BI__ProductCCL__c>();
                List<LLC_BI__ProductDocTab__c> pr_doctab = new List<LLC_BI__ProductDocTab__c>();
                List<LLC_BI__ProductCCL__c> prccl_list = [SELECT ID, LLC_BI__Closing_Checklist__c, LLC_BI__Product__c FROM 
                    LLC_BI__ProductCCL__c WHERE LLC_BI__Product__r.LLC_BI__lookupKey__c = :sourcePR];
                List<LLC_BI__ProductDocTab__c> prdoctab_list = [SELECT ID, LLC_BI__Product__c, LLC_BI__DocTab__c FROM
                    LLC_BI__ProductDocTab__c WHERE LLC_BI__Product__r.LLC_BI__lookupKey__c = :sourcePR];     
                List<LLC_BI__Product__c> products = [SELECT ID, LLC_BI__lookupKey__c FROM LLC_BI__Product__c WHERE LLC_BI__lookupKey__c != :sourcePR];
        
                if (products.size() > 0 && prccl_list.size() > 0) //If the product list is 0, then none of the lookupKeys were valid; if prccl list is 0, the source was invalid or empty
                {
                    LLC_BI__ProductCCL__c tempPSC;
                    for(LLC_BI__Product__c pr: products) //for the target product...
                    {
                        for(LLC_BI__ProductCCL__c prccl: prccl_list) //...add each prCCL
                        {
                            tempPSC = new LLC_BI__ProductCCL__c(LLC_BI__Product__c = pr.ID, LLC_BI__Closing_Checklist__c = prccl.LLC_BI__Closing_Checklist__c);
                            pr_ccl.add(tempPSC);  
                        }
                    }
                    
                    LLC_BI__ProductDocTab__c tempPDT;
                    for(LLC_BI__Product__c pr: products)
                    {
                        for(LLC_BI__ProductDocTab__c pdt: prdoctab_list)
                        {
                            tempPDT = new LLC_BI__ProductDocTab__c(LLC_BI__Product__c = pr.ID, LLC_BI__DocTab__c = pdt.LLC_BI__DocTab__c);
                            pr_doctab.add(tempPDT);
                        }
                    }
                    
                    insert pr_doctab;
                    insert pr_ccl;
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, 'PR-CCL inserted successfully for Products.'));
                }
                else
                {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Error:  either the source has no CCL records, or there are no other Products configured.'));
                }            
            }
        }
        catch (Exception e)
        {
            Database.rollback(sp);
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'PR-CCL could not be inserted.  SF error:  ' + e));        
        }
    }
    
    
    //CLONE TO SPECIFIED TARGETS
    public void cloneToTargets()
    {
        try
        {
            sp = Database.setSavepoint();
            
            String sourcePR2 = sourcePR2GS;
            String targetPR = copyTargetPRsGS;
        
            if (sourcePR2.length() == 0 || targetPR.length() == 0 || sourcePR2.contains(','))
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please enter both a source Product lookupKey (without commas) and target Product lookupKey(s).'));
            }
            else
            {
                parseProductTarget(targetPR);
                String queryWhereClause = 'LLC_BI__lookupKey__c = ';
                Integer count = 1;
                for(String target : listProductStrings)
                {
                    queryWhereClause += '\'' + target + '\'';
                    count++;
                    if(count <= listProductStrings.size())
                    {
                        queryWhereClause += ' OR LLC_BI__lookupKey__c = ';
                    }
                }
        
                List<LLC_BI__ProductCCL__c> pr_ccl = new List<LLC_BI__ProductCCL__c>();
                List<LLC_BI__ProductDocTab__c> pr_doctab = new List<LLC_BI__ProductDocTab__c>();
                List<LLC_BI__ProductCCL__c> prccl_list = [SELECT ID, LLC_BI__Closing_Checklist__c, LLC_BI__Product__c FROM 
                    LLC_BI__ProductCCL__c WHERE LLC_BI__Product__r.LLC_BI__lookupKey__c = :sourcePR2];
                List<LLC_BI__ProductDocTab__c> prdoctab_list = [SELECT ID, LLC_BI__Product__c, LLC_BI__DocTab__c FROM
                    LLC_BI__ProductDocTab__c WHERE LLC_BI__Product__r.LLC_BI__lookupKey__c = :sourcePR2];
                //List<LLC_BI__Product__c> products = [SELECT ID, LLC_BI__lookupKey__c FROM LLC_BI__Product__c WHERE LLC_BI__lookupKey__c = :targetPR];       
                String prQuery = 'SELECT ID, LLC_BI__lookupKey__c FROM LLC_BI__Product__c WHERE ' + queryWhereClause;
                List<LLC_BI__Product__c> products = Database.query(prQuery);
        
                if (products.size() > 0 && prccl_list.size() > 0) //If the product list is 0, then none of the lookupKeys were valid; if prccl list is 0, the source was invalid or empty
                {
                    LLC_BI__ProductCCL__c tempPSC;
                    for(LLC_BI__Product__c pr: products) //for the target product...
                    {
                        for(LLC_BI__ProductCCL__c prccl: prccl_list) //...add each prCCL
                        {
                            tempPSC = new LLC_BI__ProductCCL__c(LLC_BI__Product__c = pr.ID, LLC_BI__Closing_Checklist__c = prccl.LLC_BI__Closing_Checklist__c);
                            pr_ccl.add(tempPSC);  
                        }
                    }
                    
                    LLC_BI__ProductDocTab__c tempPDT;
                    for(LLC_BI__Product__c pr: products)
                    {
                        for(LLC_BI__ProductDocTab__c pdt: prdoctab_list)
                        {
                            tempPDT = new LLC_BI__ProductDocTab__c(LLC_BI__Product__c = pr.ID, LLC_BI__DocTab__c = pdt.LLC_BI__DocTab__c);
                            pr_doctab.add(tempPDT);
                        }
                    }
                    
                    insert pr_doctab;
                    insert pr_ccl;
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, 'PR-CCL inserted successfully for Product.'));
                }
                else
                {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Error:  either the source has no CCL records, or the entered targets are invalid.'));
                }
            }
        }
        catch(Exception e)
        {
            Database.rollback(sp);
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'PR-CCL could not be inserted.  SF error:  ' + e));
        }   
    }
    
    
    //SPECIFY PRODUCTS TO RETAIN PRCCL, REMOVE ALL OTHERS
    public void removeAll()
    {
        try
        {
            sp = Database.setSavepoint();
            String prToKeep;           
            
            if(prToKeepGS == null || prToKeepGS == '')
            {
                prToKeep = 'N/A';
            }
            else
            {
                prToKeep = prToKeepGS;
            }
                
            parseProductRemovalSources(prToKeep);
            String queryWhereClause = 'LLC_BI__Product__r.LLC_BI__lookupKey__c != ';
            Integer count = 1;
            System.debug('~~ Removal list size: ' + listProductRemoveStrings.size());
            for(String target : listProductRemoveStrings)
            {
                queryWhereClause += '\'' + target + '\'';
                count++;
                System.debug('~~ Removal Target & list size: ' + target + ' - ' + listProductRemoveStrings.size());
                if(count <= listProductRemoveStrings.size())
                {
                    queryWhereClause += ' AND LLC_BI__Product__r.LLC_BI__lookupKey__c != ';
                }
            }
            System.debug('~~ Removal Query Where Clause: ' + queryWhereClause);
        
            String removePrcclQuery = 'SELECT ID, LLC_BI__Product__r.LLC_BI__lookupKey__c FROM LLC_BI__ProductCCL__c WHERE ' + queryWhereClause;
            System.debug('~~ Full Removal Query Where Clause: ' + removePrcclQuery);
            List<LLC_BI__ProductCCL__c> productCCL = Database.query(removePrcclQuery);            
            delete(productCCL);
            
            String removePrDoctabQuery = 'SELECT ID, LLC_BI__Product__r.LLC_BI__lookupKey__c FROM LLC_BI__ProductDocTab__c WHERE ' + queryWhereClause;
            List<LLC_BI__ProductDocTab__c> productDocTabs = Database.query(removePrDoctabQuery);  
            delete(productDocTabs);
            
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, 'PR-CCLs have been successfully removed.'));           
        }
        catch(Exception e)
        {
            Database.rollback(sp);
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'CCLs could not be removed.  SF error:  ' + e));
        }   
    }
    
    
    //SPECIY PRCCLs TO DELETE
    public void removeTargets()
    {
        try
        {
            sp = Database.setSavepoint();
            
            String targetPR = removeTargetsGS;
        
            if (targetPR.length() == 0)
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please enter at least one target Product lookupKey, or comma-separated Product lookupKeys.'));
            }
            else
            {
                parseProductRemovalSources(targetPR);
                String queryWhereClause = 'LLC_BI__Product__r.LLC_BI__lookupKey__c = ';
                Integer count = 1;
                for(String target : listProductRemoveStrings)
                {
                    queryWhereClause += '\'' + target + '\'';
                    count++;
                    if(count <= listProductRemoveStrings.size())
                    {
                        queryWhereClause += ' OR LLC_BI__Product__r.LLC_BI__lookupKey__c = ';
                    }
                }
                
                String cclQuery = 'SELECT ID FROM LLC_BI__ProductCCL__c WHERE ' + queryWhereClause;
                List<LLC_BI__ProductCCL__c> targetPrCCLs = Database.query(cclQuery);  

                String doctabQuery = 'SELECT ID FROM LLC_BI__ProductDocTab__c WHERE ' + queryWhereClause;
                List<LLC_BI__ProductDocTab__c> targetDocTabs = Database.query(doctabQuery);  

                delete(targetPrCCLs);
                delete(targetDocTabs);
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, 'Targeted PSCs removed successfully.'));
            }
        }
        catch(Exception e)
        {
            Database.rollback(sp);
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'PR-CCL could not be removed from specified targets.  SF error:  ' + e));
        }   
    }
    
    /*** METHODS TO SPLIT ALL SOURCE & TARGET PRODUCT TYPES INTO INDIVIDUAL STRINGS, BASED ON COMMAS ***/
    Public PageReference InvalidSourceCopy()
    {
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, 'Please enter a source Product lookupKey (without commas).'));
        return null;
    }

    //PARSE COMMA-SEPARATED STRINGS INTO SEPARATE ITEMS 
    public void parseProductTarget(String target)
    {
        System.debug('~~Given String: ' + target);
        listProductStrings = target.split(',', target.CountMatches(',') + 1); //looking for commas to separate strings
        System.debug('~~Number of tokenized words in the given String: ' + listProductStrings.size());
        Integer count = 1;
        for(String strToken : listProductStrings) //for testing in debug log
        {
            System.debug('~~Word_' + (count++) + ' : ' + strToken);
        }
    }
    
    public void parseProductRemovalSources(String target)
    {
        System.debug('~~Given String: ' + target);
        listProductRemoveStrings = target.split(',', target.CountMatches(',') + 1); //looking for commas to separate strings
        System.debug('~~Number of tokenized words in the given String: ' + listProductRemoveStrings.size());
        Integer count = 1;
        for(String strToken : listProductRemoveStrings) //for testing in debug log
        {
            System.debug('~~Word_' + (count++) + ' : ' + strToken);
        }
    }
}