public class riskGradeTranslation {
    public String RecordId {get; set;}    
    public String grade;
    
    public riskGradeTranslation (ApexPages.StandardController controller) {
        RecordId = controller.getId();
        grade = [SELECT Id, NFCU_Grading__c FROM LLC_BI__Annual_Review__c WHERE Id = :RecordId].NFCU_Grading__c;
    }    
               
    public PageReference refreshGrade() {
        grade = [SELECT Id, NFCU_Grading__c FROM LLC_BI__Annual_Review__c WHERE Id = :RecordId].NFCU_Grading__c;
        return null;
    }    
                
    public String getGrade() {
        return grade;
    }
}