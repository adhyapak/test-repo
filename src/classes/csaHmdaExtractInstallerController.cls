public without sharing class csaHmdaExtractInstallerController {

    public class CheckInstall extends nFORCE.RemoteActionController.Endpoint {
        public override virtual Object invoke(Map<String,Object> params) {
            nFORCE.SystemProperties properties = nFORCE.SystemProperties.getInstance();
            return properties.getPropertyAsBoolean(
                nCSA_FRAME.csaConstants.CSASYSTEMPROPERTYCATEGORY,
                csaHmdaExtractConstants.PROPERTY_INSTALLEDKEY,
                false
            );
        }
    }

    public class Install extends nFORCE.RemoteActionController.Endpoint {
        public override virtual Object invoke(Map<String,Object> params) {
            List<sObject> toInsert = new List<sObject>();

            toInsert.add(nFORCE.SystemProperties.createProperty(
                nCSA_FRAME.csaConstants.CSASYSTEMPROPERTYCATEGORY,
                csaHmdaExtractConstants.PROPERTY_INSTALLEDKEY,
                csaHmdaExtractConstants.PROPERTY_INSTALLEDVALUE,
                true
            ));

            toInsert.add(nFORCE.SystemProperties.createProperty(
                csaHmdaExtractConstants.PROERPTY_CATEGORY,
                csaHmdaExtractConstants.PROPERTY_CUSTOMFIELDKEY,
                csaHmdaExtractConstants.PROPERTY_CUSTOMERFIELDVALUE,
                true
            ));

            toInsert.add(nFORCE.SystemProperties.createProperty(
                csaHmdaExtractConstants.PROERPTY_CATEGORY,
                csaHmdaExtractConstants.PROPERTY_EMAILKEY,
                csaHmdaExtractConstants.PROPERTY_EMAILVALUE,
                true
            ));

            nFORCE.DMLUtility.insertObj(toInsert);
            return null;
        }
    }

    public class Uninstall extends nFORCE.RemoteActionController.Endpoint {
        public override virtual Object invoke(Map<String,Object> params) {
            List<sObject> toDelete = new List<sObject>();

            toDelete.addAll([SELECT
                                        Id
                                FROM
                                        nFORCE__System_Properties__c
                                WHERE
                                        nFORCE__Key__c = :csaHmdaExtractConstants.PROPERTY_INSTALLEDKEY
                                OR
                                        nFORCE__Category_Name__c = :csaHmdaExtractConstants.PROERPTY_CATEGORY
                                LIMIT 100]);

            if(!toDelete.isEmpty()) {
                nFORCE.DMLUtility.deleteObj(toDelete);
            }

            return null;
        }
    }
}