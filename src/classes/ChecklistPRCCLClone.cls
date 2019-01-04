public with sharing class ChecklistPRCCLClone
{    
    public String sourceCLGS {get;set;}
    public String sourceCL2GS {get;set;}  
    public String copyTargetCLGS {get;set;}
    public String clToKeepGS {get;set;}
    public String removeTargetsGS {get;set;}
    
    List<String> listCCLStrings = new List<String>();
    
    transient Savepoint sp;
    
    public void autoSetup()
    {

    }

    //CLONE TO ALL PRODUCTS USING SOURCE
    public void cloneToAll()
    {
        try
        {
            sp = Database.setSavepoint();
            
            String sourceCL = sourceCLGS;
            
            if (sourceCL.length() == 0 || sourceCL.contains(','))
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please enter a single source CCL lookupKey (without commas).'));
            }
            else
            {
                List<LLC_BI__ProductCCL__c> pr_ccl = new List<LLC_BI__ProductCCL__c>();
                List<LLC_BI__ProductCCL__c> prccl_list = [SELECT ID, LLC_BI__Closing_Checklist__c, LLC_BI__Product__c FROM 
                    LLC_BI__ProductCCL__c WHERE LLC_BI__Closing_Checklist__r.LLC_BI__lookupKey__c = :sourceCL];   
                List<LLC_BI__ClosingChecklist__c> closing_checklist = [SELECT ID, LLC_BI__lookupKey__c FROM LLC_BI__ClosingChecklist__c WHERE LLC_BI__lookupKey__c != :sourceCL];
        
                if (closing_checklist.size() > 0 && prccl_list.size() > 0) //If the ccl list is 0, then none of the lookupKeys were valid; if prccl list is 0, the source was invalid or empty
                {
                    LLC_BI__ProductCCL__c tempPSC;
                    for(LLC_BI__ClosingChecklist__c ccl : closing_checklist) //for the target product...
                    {
                        for(LLC_BI__ProductCCL__c prccl: prccl_list) //...add each prCCL
                        {
                            tempPSC = new LLC_BI__ProductCCL__c(LLC_BI__Closing_Checklist__c = ccl.ID, LLC_BI__Product__c = prccl.LLC_BI__Product__c);
                            pr_ccl.add(tempPSC);  
                        }
                    }
                    
                    insert pr_ccl;
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, 'PR-CCL inserted successfully for CCL.'));
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
            String sourceCL2 = sourceCL2GS;  //ie, CC-001
            String targetCL = copyTargetCLGS;
        
            if (sourceCL2.length() == 0 || targetCL.length() == 0 || sourceCL2.contains(','))
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please enter both a source Closing Checklist lookupKey (without commas) and target Closing Checklist lookupKey(s).'));
            }
            else
            {
                parseCCLTarget(targetCL);
                String queryWhereClause = 'LLC_BI__lookupKey__c = ';
                Integer count = 1;
                for(String target : listCCLStrings)
                {
                    queryWhereClause += '\'' + target + '\'';
                    count++;
                    if(count <= listCCLStrings.size())
                    {
                        queryWhereClause += ' OR LLC_BI__lookupKey__c = ';
                    }
                }
                System.debug('~~ Query Where Clause: ' + queryWhereClause);
             
                List<LLC_BI__ProductCCL__c> pr_ccl = new List<LLC_BI__ProductCCL__c>();
                List<LLC_BI__ProductCCL__c> prccl_list = [SELECT ID, LLC_BI__Closing_Checklist__c, LLC_BI__Product__c FROM 
                    LLC_BI__ProductCCL__c WHERE LLC_BI__Closing_Checklist__r.LLC_BI__lookupKey__c = :sourceCL2];
                //List<LLC_BI__ClosingChecklist__c> cchecklists = [SELECT ID, LLC_BI__lookupKey__c FROM LLC_BI__ClosingChecklist__c WHERE LLC_BI__lookupKey__c = :targetCL];
                String cclQuery = 'SELECT ID, LLC_BI__lookupKey__c FROM LLC_BI__ClosingChecklist__c WHERE ' + queryWhereClause;
                List<LLC_BI__ClosingChecklist__c> cchecklists = Database.query(cclQuery);

                if (cchecklists.size() > 0 && prccl_list.size() > 0) //If the product list is 0, then none of the lookupKeys were valid; if prccl list is 0, the source was invalid or empty
                {
                    LLC_BI__ProductCCL__c tempPSC;
                    for(LLC_BI__ClosingChecklist__c cc: cchecklists) //for the target ccl...
                    {
                        for(LLC_BI__ProductCCL__c prccl: prccl_list) //...add each prCCL
                        {
                            tempPSC = new LLC_BI__ProductCCL__c(LLC_BI__Closing_Checklist__c = cc.ID, LLC_BI__Product__c = prccl.LLC_BI__Product__c);
                            pr_ccl.add(tempPSC);  
                        }
                    }
                    insert pr_ccl;
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, 'PR-CCL inserted successfully for Closing Checklist.')); 
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
            String clToKeep;           
            
            if(clToKeepGS == null || clToKeepGS == '')
            {
                clToKeep = 'N/A';
            }
            else
            {
                clToKeep = clToKeepGS;
            }
                
            parseCCLTarget(clToKeep);
            String queryWhereClause = 'LLC_BI__Closing_Checklist__r.LLC_BI__lookupKey__c != ';
            Integer count = 1;
            System.debug('~~ Removal list size: ' + listCCLStrings.size());
            for(String target : listCCLStrings)
            {
                queryWhereClause += '\'' + target + '\'';
                count++;
                System.debug('~~ Removal Target & list size: ' + target + ' - ' + listCCLStrings.size());
                if(count <= listCCLStrings.size())
                {
                    queryWhereClause += ' AND LLC_BI__Closing_Checklist__r.LLC_BI__lookupKey__c != ';
                }
            }
            System.debug('~~ Removal Query Where Clause: ' + queryWhereClause);
        
            String removePrcclQuery = 'SELECT ID, LLC_BI__Closing_Checklist__r.LLC_BI__lookupKey__c FROM LLC_BI__ProductCCL__c WHERE ' + queryWhereClause;
            System.debug('~~ Full Removal Query Where Clause: ' + removePrcclQuery);
            List<LLC_BI__ProductCCL__c> productCCL = Database.query(removePrcclQuery);            
            delete(productCCL);
            
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
            
            String targetCL = removeTargetsGS;
        
            if (targetCL.length() == 0)
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please enter at least one target CLosing Checklist lookupKey, or comma-separated Closing Cheklist lookupKeys.'));
            }
            else
            {
                parseCCLTarget(targetCL);
                String queryWhereClause = 'LLC_BI__Closing_Checklist__r.LLC_BI__lookupKey__c = ';
                Integer count = 1;
                for(String target : listCCLStrings)
                {
                    queryWhereClause += '\'' + target + '\'';
                    count++;
                    if(count <= listCCLStrings.size())
                    {
                        queryWhereClause += ' OR LLC_BI__Closing_Checklist__r.LLC_BI__lookupKey__c = ';
                    }
                }
                
                String cclQuery = 'SELECT ID, LLC_BI__lookupKey__c FROM LLC_BI__ProductCCL__c WHERE ' + queryWhereClause;
                List<LLC_BI__ProductCCL__c> targetPrCCLs = Database.query(cclQuery);   

                delete(targetPrCCLs);
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, 'Targeted PSCs removed successfully.'));
            }
        }
        catch(Exception e)
        {
            Database.rollback(sp);
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'PR-CCL could not be removed from specified targets.  SF error:  ' + e));
        }   
    }
    

    //PARSE COMMA-SEPARATED STRINGS INTO SEPARATE ITEMS 
    public void parseCCLTarget(String target)
    {
        System.debug('~~Given String: ' + target);
        listCCLStrings = target.split(',', target.CountMatches(',') + 1); //looking for commas to separate strings
        System.debug('~~Number of tokenized words in the given String: ' + listCCLStrings.size());
        Integer count = 1;
        for(String strToken : listCCLStrings) //for testing in debug log
        {
            System.debug('~~Word_' + (count++) + ' : ' + strToken);
        }
    }
}