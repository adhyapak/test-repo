public with sharing class OverviewUpdateController {

    public String getProfileName() {
        User user = [SELECT Id, Name FROM User WHERE Id =: userInfo.getUserId()];
        String userName = user.Name;
        return userName;
    }

    public PageReference runUpdate() {

        Map<String, Commercial_Overview__c> commercialMap = new Map<String, Commercial_Overview__c>();
        List<Commercial_Overview__c> commercialList = [SELECT Id, Name, Stage__c, Link_URL__c, Active__c, Display_Order__c, Report_Name__c FROM Commercial_Overview__c WHERE Active__c = true AND Report_Name__c != null ORDER BY Active__c, Display_Order__c];
        
        if (commercialList.size() > 0) {
            for (Commercial_Overview__c p : commercialList) {
                commercialMap.put(p.Report_Name__c, p);
            }
    
            List<Report> commercialReports = [SELECT Id, Name FROM Report WHERE Name IN : commercialMap.keySet()];
    
            for (Report r : commercialReports) {
                Commercial_Overview__c config = commercialMap.get(r.Name);
                if (config != null) {
                    config.Link_URL__c = '/' + r.Id;    
                }
            }
            
            update commercialList;
        }
        
        Map<String, Consumer_Overview__c> consumerMap = new Map<String, Consumer_Overview__c>();
        List<Consumer_Overview__c> consumerList = [SELECT Id, Name, Stage__c, Link_URL__c, Active__c, Display_Order__c, Report_Name__c FROM Consumer_Overview__c WHERE Active__c = true AND Report_Name__c != null ORDER BY Active__c, Display_Order__c];
        
        if (consumerList.size() > 0) {
            for (Consumer_Overview__c p : consumerList) {
                consumerMap.put(p.Report_Name__c, p);
            }
    
            List<Report> consumerReports = [SELECT Id, Name FROM Report WHERE Name IN : consumerMap.keySet()];
    
            for (Report r : consumerReports) {
                Consumer_Overview__c config = consumerMap.get(r.Name);
                if (config != null) {
                    config.Link_URL__c = '/' + r.Id;    
                }
            }
    
            update consumerList;        
        }
        
        PageReference pageRef = new PageReference('/apex/CommercialOverviewPage');
            
        return pageRef;
    }
}