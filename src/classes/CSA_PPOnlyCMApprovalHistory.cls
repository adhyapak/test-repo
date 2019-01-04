global class CSA_PPOnlyCMApprovalHistory extends nFORCE.MappedSObjectHierarchyScreenResource { 
  public Id pp_id;
  public nFORCE.SObjectScreenResourceListHelper listHelper;
  public List<nFORCE.IScreenResource> resources;
  global virtual override void load(){
      if (!Test.isRunningTest()) {
          pp_id = getSObject().Id;
      }

		Map<String, Schema.SObjectField> fieldsMap;
		fieldsMap = LLC_BI__Product_Package__c.sObjectType.getDescribe().fields.getMap();

		String fieldApiName = 'id' ;

		// Creating String of fields for all fields on Account
		for(Schema.SObjectField fieldName:fieldsMap.Values()) { 
			if(fieldname.getDescribe().getName() != 'id')
			fieldApiName += ',' +fieldname.getDescribe().getName() ;
		}	
		String ppquery = 'SELECT ' + fieldApiName + ' FROM LLC_BI__Product_Package__c WHERE Id = \'' + pp_id + '\'';
		System.debug(ppquery);
		LLC_BI__Product_Package__c product_package = Database.query(ppquery);

		System.debug('set sobject');
		setSObject(product_package);
		
		System.debug('loading');
		super.load();
		System.debug('Setting list helpler');
		nFORCE.SObjectScreenResourceListHelper listHelper = new nFORCE.SObjectScreenResourceListHelper();
		System.debug('building resources');

		resources = listHelper.buildResourceList(product_package);

		List<nFORCE.IScreenResource> childs;
				System.debug('adding resources');

		//resources.add();
		System.debug('cloning');
		//childs.add(cloneResource());
		getChildren().addAll(resources);
		System.debug('childs');
		for(nFORCE.IScreenResource child : getChildren()) {
			System.debug('inloop');
			System.debug(child);
			System.debug('seting sobject');
			sObject cObject = getSObject();
            System.debug('PPCMOnly cobject'+ cObject);
			List<ProcessInstance> processInstances =
			[SELECT
				Id,
				SystemModstamp, LastModifiedById, LastModifiedDate, CreatedById, CreatedDate, SubmittedById, ProcessDefinitionId, TargetObjectId, Status, CompletedDate, LastActorId, ElapsedTimeInDays, ElapsedTimeInHours, ElapsedTimeInMinutes, IsDeleted, 
				(SELECT
					ActorId,
					Actor.FirstName,
					Actor.LastName,
					OriginalActorId,
					OriginalActor.Name,
					IsPending,
					IsDeleted,
					StepStatus,
					Comments,
					TargetObjectId,
					SystemModstamp
				FROM
					StepsAndWorkItems
				WHERE
					Id != null
				
				ORDER BY
					SystemModstamp DESC
					)
			FROM
				ProcessInstance
			WHERE
				TargetObjectId =: cObject.Id
				
			order by SystemModstamp ASC ];
			//System.debug('PPCMOnly gObject ' + gObject);
							
			for(ProcessInstance dbRecord : processInstances){
                System.debug('PPCMOnly DB REcord' + dbRecord);
                System.debug('PPCMOnly DB REcord' + dbRecord.StepsAndWorkItems);
				for(ProcessInstanceHistory dbStep : dbRecord.StepsAndWorkItems){
                	System.debug('PPCMOnly DB ' + dbStep);
					
					sObject gObject = dbStep;
					sObject gObject1 =  dbStep.Actor;
					sObject gObject2 =  [SELECT title from User where Id = :dbStep.Actor.Id];
					System.debug(1);
					System.debug(gObject);
					System.debug(2);
					System.debug(gObject1);
					System.debug(3);
					System.debug(gObject2);
					if(gObject != null){

						nFORCE.IScreenResource grandchild = new nFORCE.SObjectScreenResource();
						grandchild.setSObject(gObject);
						grandchild.load();
						child.getChildren().add(grandchild);
						nFORCE.IScreenResource appUser = new nFORCE.SObjectScreenResource();
						grandchild.setSObject(gObject1);
						grandchild.load();
						child.getChildren().add(appUser);
						nFORCE.IScreenResource appUser2 = new nFORCE.SObjectScreenResource();
						grandchild.setSObject(gObject2);
						grandchild.load();
						child.getChildren().add(appUser2);
					}
				}
			}
		
		}
	
	}
	global virtual override String getUniqueResourceIdentifier(){
		return CSA_PPOnlyCMApprovalHistory.class.toString()
					+ '_' + getSObjectType().getDescribe().getName();
	}
	global override Type getType(){
		return CSA_PPOnlyCMApprovalHistory.class;
	}
}