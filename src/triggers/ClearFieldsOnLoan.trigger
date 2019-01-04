trigger ClearFieldsOnLoan on LLC_BI__Loan__c (before insert) {
	//Add fields from fieldset to a set 
    set<String> CopyFieldSet = new Set<String>();
    for(Schema.FieldSetMember fields : Schema.SObjectType.LLC_BI__Loan__c.fieldsets.getMap().get('ClearFields_Copy').getFields())
    {
        CopyFieldSet.add(fields.getFieldPath());
    }
    
     set<String> RenModFieldSet = new Set<String>();
    for(Schema.FieldSetMember fields : Schema.SObjectType.LLC_BI__Loan__c.fieldsets.getMap().get('ClearFields_Renew_Mod').getFields())
    {
        RenModFieldSet.add(fields.getFieldPath());
    }
    
    for(LLC_BI__Loan__c theLoan : Trigger.new)
    {
        if(theLoan.LLC_BI__Is_Copy__c == true){
        	for(String s : CopyFieldSet)
            {
                system.debug('&&&&&' + theLoan.get(s));
                if(theLoan.get(s) == true  || theLoan.get(s) == false)
                {
					theLoan.put(s, false);
                }
                else
                {
                	theLoan.put(s, null);
                }
            }
        }
        
        else if(theLoan.LLC_BI__Is_Modification__c == true || theLoan.LLC_BI__isRenewal__c == true){
        	for(String s : RenModFieldSet)
            {
                system.debug('&&&&&' + theLoan.get(s));
                if(theLoan.get(s) == true  || theLoan.get(s) == false)
                {
					theLoan.put(s, false);
                }
                else
                {
                	theLoan.put(s, null);
                }
            }
        }
    }
}