public with sharing class ltm_RedirectController
{ 
  public String userRoleId{get;set;}
    public Boolean displayAllUsers{get;set;}
    public ApexPages.StandardController controller;
    public Boolean recordCreated{get;set;}
    public Boolean userName{get;set;}

    public ltm_RedirectController(ApexPages.StandardController controller)
    {
        this.controller = controller;
        recordCreated = false;



    }

  public PageReference updateUsers()
    {
        LLC_BI__LoanTeam__c ltm =(LLC_BI__LoanTeam__c) controller.getRecord();
        userRoleId = ltm.LLC_BI__Assigned_Role__c;
        getAllRoles(ltm.LLC_BI__Assigned_Role__c, displayAllUsers);
        //system.debug('LTM ' + ltm.LLC_BI__Assigned_Role__c);
        return null;
    }

    public PageReference saveAndReturn()
    {
        
        String savebutton = ApexPages.currentPage().getParameters().get('savebutton2');


        if (String.valueOf(apexPages.currentPage().getParameters()).indexOf('savebutton2') > -1) {
      		LLC_BI__LoanTeam__c existingLtm =(LLC_BI__LoanTeam__c) controller.getRecord();
            LLC_BI__LoanTeam__c ltm = new LLC_BI__LoanTeam__c();
            ltm.LLC_BI__Loan__c = existingLtm.LLC_BI__Loan__c;
            ltm.LLC_BI__Assigned_Role__c = existingLtm.LLC_BI__Assigned_Role__c;
            ltm.LLC_BI__User__c = existingLtm.LLC_BI__User__c;
            ltm.LLC_BI__Team_Role__c = ltm.LLC_BI__Team_Role__c;
            insert ltm;
            
            recordCreated = true;
          //controller.save();
            PageReference pageRef = new PageReference('/apex/ltm_RedirectPage?CF00No0000006LlBW=' + apexPages.currentPage().getParameters().get('CF00No0000006LlBW') + '&CF00No0000006LlBW_lkid');
      return pageRef;
        } else {
            PageReference cancel = controller.cancel();
            return cancel;
            
        }
            
        
    }

    public List<selectOption> getRole()
    {
        List<selectOption> options = new List<selectOption>();
        options.add(new selectOption('', '- None  -'));

        for (LLC_BI__Role__c role :[SELECT Id, Name, LLC_BI__Description__c,  LLC_BI__Type__c FROM LLC_BI__Role__c ORDER BY Name ])
        {
            options.add(new selectOption(role.Id, role.Name));
        }

        return options;
    }


    public static List<User> getAllRoles(String roleId, Boolean showAll) {
        system.debug('in role id' + roleId);
        if (!showAll && !String.isBlank(roleId))  {

      LLC_BI__Role__c role = [SELECT Id, Name, LLC_BI__Description__c,  LLC_BI__Type__c FROM LLC_BI__Role__c WHERE Id = :roleId];
            return [
                SELECT Id, Name, UserRole.Name
                FROM User WHERE IsActive = true and Is_nCino_User__c = true
                and UserRole.Name = :role.Name ORDER BY Name
            ];
        } else {
             return [
                SELECT UserRoleId, Name, UserRole.Name
                FROM User WHERE IsActive = true and Is_nCino_User__c = true
                ORDER BY Name
            ];
        }
    }

    public List<selectOption> getUser()
    {
            List<selectOption> options = new List<selectOption>();
            options.add(new selectOption('', '- None  -'));
          if (userRoleId != null) {
                for (User user :getAllRoles(userRoleId, displayAllUsers)){
                    options.add(new selectOption(user.Id, user.Name + ' - ' + user.UserRole.Name));
                }
          }
        return options;
    }
}