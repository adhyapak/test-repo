public class creditMemoEditLink {
    private ApexPages.StandardController standardController;
    public Boolean shouldRedirect {public get; private set;}
    public String redirectUrl {public get; private set;}
    
    public creditMemoEditLink(ApexPages.StandardController standardController)
    {
        this.standardController = standardController;
        shouldRedirect = false;
    }
 
    public PageReference reduceAndGenerateLabels() {
        Id recordId = standardController.getId();
        nDESIGN__View__c cmView = [select nDesign__Read_Only__c from nDESIGN__View__c Where Id = :recordId];

        String origContent = cmView.nDesign__Read_Only__c.unescapeUnicode().unescapeHtml3();
        System.debug('Orig' + origContent);
        Pattern objectNameSearch = Pattern.compile('((<td|<th|<div)?.(?:data-bind.*__c_(?:LLC_BI__)?)(.*)((?=__c))(?:.*)(?:fieldLabel\"| class=\"text-label\")(.*\\w\")?(>)?(<\\/div>|<\\/th>|<\\/td>)?|(<span).(?:data-bind.*__c_(?:LLC_BI__|__c_LLC_BI__)?)(.*)(?:__c.fieldLabel)(?:.*)(fieldLabel\"| class=\"text-label\")(.*\\w\")?(>)(<\\/span>))');
        String replacementContent = origContent.replaceAll('((<td|<th|<div)?.(?:data-bind.*__c_(?:LLC_BI__)?)(.*)((?=__c))(?:.*)(?:fieldLabel\"| class=\"text-label\")(.*\\w\")?(>)?(<\\/div>|<\\/th>|<\\/td>)?|(<span).(?:data-bind.*__c_(?:LLC_BI__|__c_LLC_BI__)?)(.*)(?:__c.fieldLabel)(?:.*)(fieldLabel\"| class=\"text-label\")(.*\\w\")?(>)(<\\/span>))','$2$5$6$8$11$12$9$13');
		System.debug('REPLACEMENT' + replacementContent.escapeHtml3());
        cmView.nDesign__Read_Only__c = replacementContent.escapeHtml3();
        update cmView;
        
        redirectUrl = standardController.view().getUrl();
        shouldRedirect = true;
        return null;
    }
    public PageReference createLinks()
    {
  
        Id recordId = standardController.getId();
        nDESIGN__View__c cmView = [select nDesign__Read_Only__c from nDESIGN__View__c Where Id = :recordId];

        
		if (cmView.nDesign__Read_Only__c != null) {
            if (cmView.nDesign__Read_Only__c.indexOf('Object_Edit_Link__c') > -1) {
                String origContent = cmView.nDesign__Read_Only__c;
                Pattern objectNameSearch = Pattern.compile('([A-Z])\\w+_Object_Edit_Link__c');
                Matcher objectNameResults = objectNameSearch.matcher(origContent);
    
                String objName;
    
                System.Debug('Matches? :' + objectNameResults.matches());
                while (objectNameResults.find()) {
                    objName = objectNameResults.group().replace('_Object_Edit_Link__c','');
                    System.Debug('Object Name');
                    System.Debug(objName);
                    String originalEditLink = '<div data-bind="if: $data.' + objName + '_Object_Edit_Link__c &amp;&amp; $data.' + objName + '_Object_Edit_Link__c.fieldLabel" class="col-xs-3 text-right"><span data-bind="text: ' + objName + '_Object_Edit_Link__c.fieldLabel" class="text-label"></span></div><div data-bind="if: $data.' + objName + '_Object_Edit_Link__c &amp;&amp; $data.' + objName + '_Object_Edit_Link__c.value" class="col-xs-3"><span data-bind="text: ' + objName + '_Object_Edit_Link__c.value"></span></div>';
                    String manipulatedEditLink = '<a data-bind="text: \'\', attr: { href: $data.' + objName + '_Object_Edit_Link__c.value}" class="glyphicon glyphicon-edit" style="float:right" target="_new"></a>';
                                       
                    cmView.nDesign__Read_Only__c = origContent.replace(originalEditLink.escapeHtml3(), manipulatedEditLink.escapeHtml3());
                    System.Debug('Start Replacing Values' + originalEditLink.escapeHtml3());
                    System.Debug('Ed Replacing Values' + manipulatedEditLink.escapeHtml3());
    				update cmView;
                    System.Debug('Finished Replacing Values' + cmView.nDesign__Read_Only__c);
                    redirectUrl = standardController.view().getUrl();
                    shouldRedirect = true;
                }
            }
        }        
        return null;
    }

}