/**
 * Created by jane.boles on 1/2/2018.
 */
@isTest
public with sharing class TestBLUPTMDataGenerator {
    public static Boolean orgHasTerritoryManagement {
        get{
            if(orgHasTerritoryManagement == null){
                orgHasTerritoryManagement = Account.getSobjectType().getDescribe().fields.getMap().keySet().contains('billingcountrycode');
            }
            return orgHasTerritoryManagement;
        }
        set{
            orgHasTerritoryManagement = value;
        }
    }
    public static Map<String, String> countryPicklistValues{
        get{
            if(countryPicklistValues == null){
                //disclaimer, put your OWN values here for non US data being used in test data
                countryPicklistValues = new Map<String, String>();
                countryPicklistValues.put('US', 'United States');
                countryPicklistValues.put('UK', 'United Kingdom');
            }
            return countryPicklistValues;
        }
        set{
            countryPicklistValues = value;
        }
    }
    public static Map<String, String> statePickListValues{
        get{
            if(statePickListValues == null){
                statePickListValues = new Map<String, String>();
                statePickListValues.put('AA','Armed Forces Americas');
                statePickListValues.put('AE','Armed Forces Europe');
                statePickListValues.put('AK','Alaska');
                statePickListValues.put('AL','Alabama');
                statePickListValues.put('AP','Armed Forces Pacific');
                statePickListValues.put('AR','Arkansas');
                statePickListValues.put('AS','American Samoa');
                statePickListValues.put('AZ','Arizona');
                statePickListValues.put('CA','California');
                statePickListValues.put('CO','Colorado');
                statePickListValues.put('CT','Connecticut');
                statePickListValues.put('DC','District of Columbia');
                statePickListValues.put('DE','Delaware');
                statePickListValues.put('FL','Florida');
                statePickListValues.put('FM','Federated Micronesia');
                statePickListValues.put('GA','Georgia');
                statePickListValues.put('GU','Guam');
                statePickListValues.put('HI','Hawaii');
                statePickListValues.put('IA','Iowa');
                statePickListValues.put('ID','Idaho');
                statePickListValues.put('IL','Illinois');
                statePickListValues.put('IN','Indiana');
                statePickListValues.put('KS','Kansas');
                statePickListValues.put('KY','Kentucky');
                statePickListValues.put('LA','Louisiana');
                statePickListValues.put('MA','Massachusetts');
                statePickListValues.put('MD','Maryland');
                statePickListValues.put('ME','Maine');
                statePickListValues.put('MH','Marshall Islands');
                statePickListValues.put('MI','Michigan');
                statePickListValues.put('MN','Minnesota');
                statePickListValues.put('MO','Missouri');
                statePickListValues.put('MP','Northern Mariana Islands');
                statePickListValues.put('MS','Mississippi');
                statePickListValues.put('MT','Montana');
                statePickListValues.put('NC','North Carolina');
                statePickListValues.put('ND','North Dakota');
                statePickListValues.put('NE','Nebraska');
                statePickListValues.put('NH','New Hampshire');
                statePickListValues.put('NJ','New Jersey');
                statePickListValues.put('NM','New Mexico');
                statePickListValues.put('NV','Nevada');
                statePickListValues.put('NY','New York');
                statePickListValues.put('OH','Ohio');
                statePickListValues.put('OK','Oklahoma');
                statePickListValues.put('OR','Oregon');
                statePickListValues.put('PA','Pennsylvania');
                statePickListValues.put('PR','Puerto Rico');
                statePickListValues.put('PW','Palau');
                statePickListValues.put('RI','Rhode Island');
                statePickListValues.put('SC','South Carolina');
                statePickListValues.put('SD','South Dakota');
                statePickListValues.put('TN','Tennessee');
                statePickListValues.put('TX','Texas');
                statePickListValues.put('UM','United States Minor Outlying Islands');
                statePickListValues.put('UT','Utah');
                statePickListValues.put('VA','Virginia');
                statePickListValues.put('VI','US Virgin Islands');
                statePickListValues.put('VT','Vermont');
                statePickListValues.put('WA','Washington');
                statePickListValues.put('WI','Wisconsin');
                statePickListValues.put('WV','West Virginia');
                statePickListValues.put('WY','Wyoming');
                
            }
            return statePickListValues;
        }
        set{
            statePickListValues = value;
        }
    }
    public static SObject updateForTerritoryManagement(Sobject sObj){
        Schema.sObjectType objectType = sObj.getSobjectType();
        if(String.valueOf(objectType) == 'Account'){
            Set<String> accCountryFields = new Set<String>();
            accCountryFields.add('ShippingCountry');
            accCountryFields.add('BillingCountry');
            sObj = updateCountryForTM(sObj, accCountryFields);

            Set<String> accStateFields = new Set<String>();
            accStateFields.add('ShippingState');
            accStateFields.add('BillingState');
            sObj = updateStateForTM(sObj, accStateFields);

        }
        else if(String.valueOf(objectType) == 'Contact'){
            Set<String> contactCountryFields = new Set<String>();
            contactCountryFields.add('MailingCountry');
            sObj = updateCountryForTM(sObj, contactCountryFields);

            Set<String> contactStateFields = new Set<String>();
            contactStateFields.add('MailingState');
            sObj = updateStateForTM(sObj, contactStateFields);
        }
        return sObj;
    }
    public static SObject updateCountryForTM(SObject sObj, Set<String> fields){
        for(String field : fields){
            String fieldValue = String.valueOf(sObj.get(field));
            if(!String.isBlank(fieldValue)){
                if(countryPicklistValues.containsKey(fieldValue)){
                    sObj.put(field, countryPicklistValues.get(fieldValue));
                }
            }
        }
        return sObj;
    }
    public static SObject updateStateForTM(SObject sObj, Set<String> fields){
        for(String field : fields){
            String fieldValue = String.valueOf(sObj.get(field));
            if(!String.isBlank(fieldValue)){
                if(statePickListValues.containsKey(fieldValue)){
                    sObj.put(field, statePickListValues.get(fieldValue));
                }
            }
        }
        return sObj;
    }
}