global with sharing class BLUPController {

    public Boolean hasPermission {get;set;}

    public BLUPController(){

        List<PermissionSetAssignment> currentPermissions =    [SELECT Id, PermissionSet.Name,AssigneeId
        FROM PermissionSetAssignment
        WHERE AssigneeId = :Userinfo.getUserId() ];

        hasPermission = false;

        for ( PermissionSetAssignment psa : currentPermissions ) {
            if ( psa.PermissionSet.Name.equals(PERMISSION_NAME) ) {
                hasPermission = true;
            }
        }
        ApexPages.currentPage().getParameters().put('hasPermission', String.valueOf(hasPermission));

    }


    @TestVisible
    private static Boolean forceUnhandledException = false;

    public interface IBLUPRepository{
        Account getAccount(String accountId, Boolean isStandard);
        List<Attachment> getAttachments(String transactionLogId, String limitSize);
    }

    public class XBLUPException extends Exception {}

    public interface IBLUPManager{
    }

    public class BLUPRepository implements IBLUPRepository{
        public Account getAccount(String accountId, Boolean standardOnly){
            List<String> fields = getAccountFields(standardOnly);
            String accountQuery =
                    'SELECT '+
                            String.join(fields, COMMA_SPACE) +
                            ' FROM '+
                            'Account '+
                            'WHERE '+
                            'Id =: accountId limit 1';
            return Database.query(accountQuery);
        }
        public List<Attachment> getAttachments(String transactionLogId, String limitSize){
            if(String.isBlank(limitSize))
                limitSize = DEFAULT_ATT_LIMIT;
            List<String> fields = getAttachmentFields();
            String attachmentQuery =
                    'SELECT '+
                            String.join(fields, COMMA_SPACE) +
                            ' FROM '+
                            'Attachment '+
                            'WHERE '+
                            'ParentId =: transactionLogId limit ' + limitSize;
            return Database.query(attachmentQuery);
        }
    }
    public class BLUPManager implements IBLUPManager{
        private IBLUPRepository blupRepo;
        public BLUPManager(){
            this.blupRepo = new BLUPRepository();
        }
    }
    public static List<String> getAccountFields(Boolean isStandard){
        Map<String, Schema.SObjectField> fieldMap = Account.SObjectType.getDescribe().fields.getMap();
        List<String> fields = new List<String>();
        for(Schema.SObjectField sField: fieldMap.Values()) {
            schema.describefieldresult dField = sField.getDescribe();
            if(isStandard && !dField.getName().endsWith('__c') && !dField.getName().endsWith('__s')) {
                fields.add(dField.getName());
            }
            else if(dField.getName() == DUNS || dField.getName() == EXPERIAN_BIN){
                fields.add(dField.getName());
            }
        }
        if(!isStandard)
            fields.add('Id');
        return fields;
    }
    public static List<String> getAttachmentFields(){
        Map<String, Schema.SObjectField> fieldMap = Attachment.SObjectType.getDescribe().fields.getMap();
        List<String> fields = new List<String>();
        for(Schema.SObjectField sField: fieldMap.Values()) {
            schema.describefieldresult dField = sField.getDescribe();
            if(dField.isAccessible()) {
                fields.add(dField.getName());
            }
        }
        return fields;
    }

    public static nFUSE.SendService findService(BLUPPluginInfo info){
        nFUSE.SendService service = null;
        try{
            nFUSE.PackageServiceRequest request = new nFUSE.PackageServiceRequest(info.pluginName, info.pluginVersion, null);
            nFUSE.ServiceLocator locator = new nFUSE.ServiceLocator();
            service = (nFUSE.SendService)locator.locate(
                    request,
                    nFUSE.SendService.class,
                    info.sendServiceClassName
            );
        }
        catch(Exception e){
            if(!e.getMessage().toLowerCase().contains('unable to locate service for')){
                //TODO: change to using labels for the Message/Line
                throw new XBLUPException(Label.BLUP_Generic_Error_Message + ' Message: ['+ e.getMessage()+'], Line: ['+e.getLineNumber() + ']');
            }
            return service;
        }
        return service;
    }
    public static BLUPPluginInfo checkForService(BLUPPluginInfo info){
        nFUSE.SendService service = null;
        try{
            nFUSE.PackageServiceRequest request = new nFUSE.PackageServiceRequest(info.pluginName, info.pluginVersion, null);
            service = serviceFinder(info, request);
            if(service != null)
                info.infoFound = true;
            else
                    info.infoFound = false;
        }
        catch(Exception e){
            info.infoFound = false;
            if(!e.getMessage().toLowerCase().contains('unable to locate service for')){
                //TODO: change to using labels for the Message/Line
                throw new XBLUPException(Label.BLUP_Generic_Error_Message + ' Message: ['+ e.getMessage()+'], Line: ['+e.getLineNumber() + ']');
            }
        }
        return info;
    }
    public static nFUSE.SendService serviceFinder(BLUPPluginInfo info, nFUSE.PackageServiceRequest request){
        nFUSE.SendService service = null;
        try{
            nFUSE.ServiceLocator locator = new nFUSE.ServiceLocator();
            service = (nFUSE.SendService)locator.locate(
                    request,
                    nFUSE.SendService.class,
                    info.sendServiceClassName
            );
        }
        catch(Exception e){
            if(!e.getMessage().toLowerCase().contains('unable to locate service for')){
                //TODO: change to using labels for the Message/Line
                throw new XBLUPException(Label.BLUP_Generic_Error_Message + ' Message: ['+ e.getMessage()+'], Line: ['+e.getLineNumber() + ']');
            }
            else{
                service = null;
            }
            return service;
        }
        return service;
    }
    public static List<BLUPPluginInfo> getPluginInfos(){
        List<BLUPPluginInfo> pluginInfos = new List<BLUPPluginInfo>();

        BLUPPluginInfo info = new BLUPPluginInfo();
        
        info.sendServiceClassName = 'FICOBLUPSendService';
        info.pluginName = FICO_CREDIT;
        info.pluginVersion = '1.0';
        //TODO: check the configuration if this is enabled try adding it here
        pluginInfos.add(info);

        info = new BLUPPluginInfo();
        info.sendServiceClassName = 'ExperianBLUPSendService';
        info.pluginName = EXP_CREDIT;
        info.pluginVersion = '1.0';
        //TODO: check the configuration if this is enabled try adding it here
        pluginInfos.add(info);

        return pluginInfos;
    }
    @TestVisible
    public static String getProperty(nFORCE.SystemProperties configProperties, String propertyKey, String PLUGIN_CONFIG_NAME){
        String value = configProperties.getProperty(PLUGIN_CONFIG_NAME, propertyKey);
        if(String.isEmpty(value)) throw new XBLUPException(
                X_MISSING_REQUIRED_PROPERTY + ': ' + propertyKey
        );
        return value;
    }

    public static List<BLUPProductRow> getProductRows(List<BLUPPluginInfo> pluginInfos){
        nFORCE.SystemProperties configProperties = nFORCE.SystemProperties.getInstance();
        List<BLUPProductRow> rows = new List<BLUPProductRow>();
        for(BLUPPluginInfo pluginInfo : pluginInfos){
            pluginInfo = checkForService(pluginInfo);
            if(pluginInfo.infoFound){
                BLUPProductRow row = new BLUPProductRow();
                if(pluginInfo.pluginName == FICO_CREDIT){
                    String prop = getProperty(configProperties, BUREAU_NAME, pluginInfo.pluginName+NFUSE_CONFIGURATION_KEYWORD);
                    if(prop.contains(EXPERIAN_CONFIG)){
                        row.businessName = FICOEXPERIAN;
                        row.sendServiceClassName = pluginInfo.sendServiceClassName;
                        rows.add(row);
                    }
                    else if(prop.contains(DNB_CONFIG)){
                        row.businessName = FICODNB;
                        row.sendServiceClassName = pluginInfo.sendServiceClassName;
                        rows.add(row);
                    }
                    else{
                        throw new XBLUPException(Label.BLUP_Invalid_FICO_Business_Bureau_Name);
                    }
                }
                else if(pluginInfo.pluginName == EXP_CREDIT){
                    row.businessName = EXPERIAN;
                    row.sendServiceClassName = pluginInfo.sendServiceClassName;
                    rows.add(row);
                }
            }
        }




        return rows;
    }
    @RemoteAction
    global static BLUPResponse getProductRows(String accountId){
        BLUPResponse res = new BLUPResponse();
        try {
            String[] messages = new List<String>();

            Set<String> fieldNames = new Set<String>();
            fieldNames.add('Name'.toLowerCase());
            fieldNames.add('BillingStreet'.toLowerCase());
            fieldNames.add('BillingCity'.toLowerCase());
            fieldNames.add('BillingState'.toLowerCase());
            fieldNames.add('BillingPostalCode'.toLowerCase());
            fieldNames.add('BillingCountry'.toLowerCase());

            Map<String, String> schemaLabels = getSchemaLabels('Account', fieldNames);

            BLUPManager manager = new BLUPManager();

            Account account = manager.blupRepo.getAccount(accountId, true);

            checkRestrictions(messages, schemaLabels, account, 'Name', 0);
            //HOTFIX DATA-2182 - remove billing street length cap, let MW handle truncation, just make sure it has data (using zero as the validator to ensure that)
            checkRestrictions(messages, schemaLabels, account, 'BillingStreet', 0);
            checkRestrictions(messages, schemaLabels, account, 'BillingCity', 25);
            checkRestrictions(messages, schemaLabels, account, 'BillingState', 0);
            checkRestrictions(messages, schemaLabels, account, 'BillingPostalCode', 5);
            checkRestrictions(messages, schemaLabels, account, 'BillingCountry', 0);

            //TODO: change to using labels
            if(messages.size()>0)
                throw new XBLUPException('There was an error generating the Business Lookup request. ' + String.join(messages,' ') + ' Please see Relationship '+ account.Id + ' and update the Relationship record with the required data and try again or contact nCino support if the issue persists');



            List<BLUPPluginInfo> pluginInfos = getPluginInfos();

            List<BLUPProductRow> rows = getProductRows(pluginInfos);

            if(rows.size() == 0){
                res.errorMessage = Label.BLUP_No_service_found_error;
            }
            else{
                res.productRows = rows;
            }
        } catch(Exception e) {
            //TODO: change to using labels for the Message/Line
            res.errorMessage = Label.BLUP_Generic_Error_Message + ' Message: ['+ e.getMessage()+'], Line: ['+e.getLineNumber() + ']';
        }
        return res;
    }
    @RemoteAction
    global static BLUPResponse executeBlupRequest(String accountId, String selectedProduct){
        BLUPResponse res = new BLUPResponse();
        try {
            BLUPManager manager= new BLUPManager();

            Sobject acc = manager.blupRepo.getAccount(accountId, true);
            List<String> standardFields = getAccountFields(true);
            List<String> requiredFields = new List<String>();
            requiredFields.add('Name');
            requiredFields.add('BillingStreet');
            requiredFields.add('BillingCity');
            requiredFields.add('BillingState');
            requiredFields.add('BillingPostalCode');
            requiredFields.add('BillingCountry');

            List<String> missingFields = new List<String>();
            for(String fieldName : requiredFields){
                String fieldValue = String.valueOf(acc.get(fieldName));

                if(fieldValue==null || fieldValue ==''){
                    missingFields.add(fieldName);
                }
            }
            if(missingFields.size()>0){
                throw new XBLUPException(Label.BLUP_Missing_required_fields + ': ' + String.join(missingFields,', '));
            }


            BLUPRequest blupRequest = new BLUPRequest();
            blupRequest.record = new List<BLUPrecord>();

            for(String field : standardFields){
                String value = String.valueOf(acc.get(field));
                BLUPRecord entry = new BLUPRecord();
                entry.key=field;
                entry.value=value;
                blupRequest.record.add(entry);
            }

            String requestModel = JSON.serialize(acc);



            List<BLUPPluginInfo> pluginInfos = getPluginInfos();

            List<BLUPProductRow> rows = getProductRows(pluginInfos);

            BLUPPluginInfo pluginInfo = new BLUPPluginInfo();
            for(BLUPProductRow row : rows){
                if(row.businessName == selectedProduct){
                    for(BLUPPluginInfo info : pluginInfos){
                        if(row.sendServiceClassName== info.sendServiceClassName){
                            pluginInfo = info;
                        }
                    }
                }
            }



            nFUSE.PackageServiceRequest request = new nFUSE.PackageServiceRequest(pluginInfo.pluginName, pluginInfo.pluginVersion, null);
            nFUSE.SendService service = findService(pluginInfo);

            if(pluginInfo.infoFound){
                nFUSE.AMiddlewareMessage message = new nFUSE.MiddlewareMessage();
                message.messageHeader.action = ACTION;
                message.properties = new Map<String,Object>{
                        PRIMARY_OBJECT_ID => accountId,
                        SALESFORCE_SESSION_ID => UserInfo.getSessionId(),
                        RECORD => requestModel
                };
                request.primaryObjectId = accountId;
                service.send(request, message);

                res.transactionLogId = request.transactionLogId;
            }
            else{
                throw new XBLUPException(Label.BLUP_No_service_found_error);
            }


        } catch(Exception e) {
            //TODO: change to using labels for the Message/Line
            res.errorMessage = Label.BLUP_Generic_Error_Message + ' Message: ['+ e.getMessage()+'], Line: ['+e.getLineNumber() + ']';
        }
        return res;
    }
    @RemoteAction
    global static BLUPViewModel getBLUPViewModel(String transactionLogId, String accountId, String selectedProduct){
        BLUPViewModel viewModel = new BLUPViewModel();
        try{

            BLUPManager manager= new BLUPManager();
            List<Attachment> attachment = manager.blupRepo.getAttachments(transactionLogId, '1');

            Sobject accCustom = manager.blupRepo.getAccount(accountId, false);
            if(selectedProduct.contains(EXPERIAN)){
                viewModel.businessId = String.valueOf(accCustom.get(EXPERIAN_BIN));
            }
            else{
                viewModel.businessId = String.valueOf(accCustom.get(DUNS));
            }

            if(attachment.size() > 0){
                String jsonString = attachment[0].body.toString();
                RootObject root = (RootObject)JSON.deserialize(jsonString, RootObject.class);
                String listString = JSON.serialize(root.listOfSimilars);

                if(root.listOfSimilars.size() > 0){
                    for( ListOfSimilar listofSimilar  : root.listOfSimilars){
                        if(listofSimilar.listOfSimilarsError != null && listofSimilar.listOfSimilarsError != ''){
                            String infaError = listofSimilar.listOfSimilarsError;
                            if(infaError.contains('No records found')){
                                viewModel.errorMessage = Label.BLUP_No_Data;
                            }
                            else{
                                viewModel.errorMessage = Label.BLUP_Infa_Error;
                                viewModel.errorMessage = viewModel.errorMessage.replace('{MESSAGE}', infaError);
                            }
                            break;
                        }
                        else{
                            BLUPBusiness business = new BLUPBusiness();

                            business.businessID = listofSimilar.bin;
                            business.address = listofSimilar.companyInfo.address;
                            business.city = listofSimilar.companyInfo.city;
                            business.name = listofSimilar.companyInfo.name;
                            business.state = listofSimilar.companyInfo.state;
                            business.zip = listofSimilar.companyInfo.zip;
                            business.confidenceStr = listofSimilar.confidence;

                            if(business.confidenceStr!= null && business.confidenceStr!=''){
                                Decimal temp = Decimal.valueOf(business.confidenceStr);

                                temp = temp.divide(100, 2);
                                business.confidence = temp;
                                business.confidenceStr = String.valueOf(temp);
                            }

                            viewModel.rowCollection.add(business);
                            viewModel.rowCollection.sort();
                        }

                    }
                }
                //handled by ICRT, no need to bubble up error
//                else{
//                    //Treating empty listofSimilars as no attachment
//
//                    //viewModel.errorMessage = Label.BLUP_No_Attachment_Found;
//                }
                Database.delete(attachment);
                Database.emptyRecycleBin(attachment);
            }
            else{
                viewModel.errorMessage = Label.BLUP_No_Attachment_Found;
            }
        }catch(Exception e){
            //TODO: change to using labels for the Message/Line
            viewModel.errorMessage = Label.BLUP_Generic_Error_Message + ' Message: ['+ e.getMessage()+'], Line: ['+e.getLineNumber() + ']';
        }
        return viewModel;
    }
    @RemoteAction
    global static BLUPResponse updateAccount(String accountId, String bizID, String productName){
        BLUPResponse res = new BLUPResponse();
        try{

            BLUPManager manager= new BLUPManager();

            SObject acc = manager.blupRepo.getAccount(accountId, true);

            if(productName.contains(EXPERIAN)){
                acc.put(EXPERIAN_BIN, bizID);
            }
            else{
                acc.put(DUNS, bizID);
            }
            update acc;
        }catch(Exception e){
            //TODO: change to using labels for the Message/Line
            res.errorMessage =  Label.BLUP_Generic_Error_Message + ' Message: ['+ e.getMessage()+'], Line: ['+e.getLineNumber() + ']';
        }
        return res;
    }
    global with sharing class BLUPViewModel{
        public BLUPViewModel(){
            this.rowCollection = new List<BLUPBusiness>();
        }
        public String businessId{get;set;}
        public List<BLUPBusiness> rowCollection {get;set;}
        public String errorMessage{get;set;}
    }

    public class BLUPBusiness implements Comparable{

        public String name { get; set; }
        public String address { get; set; }
        public String city { get; set; }
        public String state { get; set; }
        public String zip { get; set; }
        public String businessID { get; set; }
        public String confidenceStr { get; set; }
        public Decimal confidence { get; set; }

        // Compare opportunities based on the opportunity amount.
        public Integer compareTo(Object compareTo) {
            // Cast argument to BLUPBusinessWrapper
            BLUPBusiness compareToblupBiz = (BLUPBusiness)compareTo;
            BLUPBusiness blupBiz = this;
            // The return value of 0 indicates that both elements are equal.
            Integer returnValue = 0;
            if (confidence < compareToblupBiz.confidence) {
                // Set return value to a positive value.
                returnValue = 1;
            } else if (confidence > compareToblupBiz.confidence) {
                // Set return value to a negative value.
                returnValue = -1;
            }

            return returnValue;
        }

    }
    public class BureauData
    {
        public string value { get; set; }
        public string key { get; set; }
    }
    public class CompanyInfo
    {
        public string zip { get; set; }
        public string address { get; set; }
        public string city { get; set; }
        public string name { get; set; }
        public string state { get; set; }
    }
    public class ListOfSimilar
    {
        public string sequenceNumber { get; set; }
        public string product { get; set; }
        public List<BureauData> bureauData { get; set; }
        public string bin { get; set; }
        public CompanyInfo companyInfo { get; set; }
        public string transactionNumber { get; set; }
        public string confidence { get; set; }
        public string bureau { get; set; }
        public string listOfSimilarsError { get; set; }
    }
    public class RootObject
    {
        public List<ListOfSimilar> listOfSimilars { get; set; }
    }
    public class BLUPRequest{
        public List<BLUPrecord> record{get;set;}
    }
    public class BLUPRecord{
        public string key{get;set;}
        public string value{get;set;}
    }
    public class BLUPPluginInfo{

        public BLUPPluginInfo(){
            infoFound = false;
            selected = false;
        }
        public Boolean selected{get;set;}
        public String sendServiceClassName{get;set;}
        public String pluginName{get;set;}
        public String pluginVersion{get;set;}
        public Boolean infoFound{get;set;}
    }
    public class BLUPProductRow{
        public BLUPProductRow(){
            selected = false;
        }
        public String businessName{get;set;}
        public String sendServiceClassName{get;set;}
        public Boolean selected{get;set;}

    }
    global with sharing class BLUPResponse{
        public String transactionLogId {get;set;}
        public String errorMessage {get;set;}
        public List<BLUPProductRow> productRows{get;set;}

    }
    public static void checkRestrictions(String[] messages, Map<String, String> schemaLabels, SObject obj, String fieldName, integer restriction){
        String fieldValue = (string)obj.get(fieldName);
        String fieldLabel = schemaLabels.get(fieldName.toLowerCase());
        if(fieldName != 'Sic' && (fieldValue == null || String.isBlank(fieldValue))){
            //TODO: change to using labels
            messages.add(fieldLabel + ' is required.');
        }
        else if((fieldName == 'BillingPostalCode' || fieldName == 'MailingPostalCode') && fieldValue.length()< restriction){
            //TODO: change to using labels
            messages.add('The field ' + fieldLabel + ' is expected to be at least ' + String.valueOf(restriction) + ' in length.');
        }
        else if(!(fieldName == 'BillingPostalCode' || fieldName == 'MailingPostalCode') && fieldValue != null  && restriction > 0 && fieldValue.length() > restriction){
            //TODO: change to using labels
            messages.add('The field ' + fieldLabel + ' is restricted to a length of ' + String.valueOf(restriction) + '.');
        }
    }
    public static Map<String, String> getSchemaLabels(String sObjType, Set<String> fieldNames){

        Map<String, String> schemaLabels = new Map<String, String>();

        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Schema.SObjectType objSchema = schemaMap.get(sObjType);
        Map<String, Schema.SObjectField> fieldMap = objSchema.getDescribe().fields.getMap();

        for (String fieldName: fieldMap.keySet()) {
            if(fieldNames.contains(fieldName)){
                schemaLabels.put(fieldName, fieldMap.get(fieldName).getDescribe().getLabel());
            }
        }
        return schemaLabels;
    }
    @TestVisible
    private static final String
            NFUSE_CONFIGURATION_KEYWORD = 'Configuration',
            ACTION='businesslookup',
            PERMISSION_NAME ='Business_Lookup',
            COMMA_SPACE = ', ',
            SALESFORCE_SESSION_ID = 'salesforce_session_id',
            PRIMARY_OBJECT_ID = 'primary_object_id',
            FICO_CREDIT= 'FairIsaac_Credit',
            EXP_CREDIT = 'Experian_Credit',
            EXPERIAN = 'Experian',
            FICODNB = 'Fair Isaac D&B',
            FICOEXPERIAN = 'Fair Isaac Experian',
            EXPERIAN_BIN = 'Experian_BIN__c',
            DUNS = 'LLC_BI__Duns_Number__c',
            BUREAU_NAME = 'FICO Business Bureau Name',
            EXPERIAN_CONFIG = 'EXPERIAN',
            DNB_CONFIG = 'DnB',
            X_MISSING_REQUIRED_PROPERTY = 'Missing BLUP configured property',
            RECORD = 'record',
            DEFAULT_ATT_LIMIT = '1';
}