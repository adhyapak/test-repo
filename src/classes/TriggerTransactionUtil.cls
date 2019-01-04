/*
 Manage Properties across a transaction
*/

public with sharing class TriggerTransactionUtil {

public static Set<String> TriggersToSkip = new Set<String>();
public static Map<String, Decimal> TriggerRunsMap = new Map<String, Decimal>();
private static boolean firstInstance = true;

  public TriggerTransactionUtil() {
    if (firstInstance){
      firstInstance = false;
      Map<Id,Trigger_attribute__mdt> m = new Map<Id, Trigger_attribute__mdt>([SELECT DeveloperName,skip__c,runs__c FROM Trigger_attribute__mdt]);

      for (Id key : m.keyset()) {
       Trigger_attribute__mdt a = m.get(key);
       TriggerRunsMap.put(a.DeveloperName,a.runs__c);
       if(a.skip__c){
         TriggersToSkip.add(a.DeveloperName);
       }
      }
    }      
  }
  public Decimal Runs(String TriggerName){
    return String.isBlank(String.ValueOf(TriggerRunsMap.get(TriggerName))) ? 99 : TriggerRunsMap.get(TriggerName);
  }

}