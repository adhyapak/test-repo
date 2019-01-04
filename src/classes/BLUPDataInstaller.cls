public with sharing class BLUPDataInstaller extends nFORCE.AUIDataProvider implements InstallHandler, UninstallHandler {
    public String PUSH_TOPIC_NAME {get;set;}

    public BLUPDataInstaller(){
        this.PUSH_TOPIC_NAME = 'TransactionLogChanges';
    }
    public void onInstall(InstallContext context){
        installPushTopic();
    }

    public void onUninstall(UninstallContext context){
        removePushTopic();
    }

    private void installPushTopic() {
        PushTopic pushTopic = new PushTopic();
        pushTopic.Name = this.PUSH_TOPIC_NAME;
        pushTopic.Query = 'SELECT Id, nFUSE__External_Id__c, nFUSE__Transaction_Status__c FROM nFUSE__Transaction_Log__c';
        pushTopic.ApiVersion = 40.0;
        pushTopic.NotifyForOperationCreate = true;
        pushTopic.NotifyForOperationUpdate = true;
        pushTopic.NotifyForOperationUndelete = false;
        pushTopic.NotifyForOperationDelete = false;
        pushTopic.NotifyForFields = 'Referenced';
        insert pushTopic;
    }

    private void removePushTopic() {
        List<PushTopic> pushTopic =  [select id from PushTopic where name =: this.PUSH_TOPIC_NAME];
        Database.delete(pushTopic);
    }


}