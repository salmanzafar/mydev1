trigger AccountTrg on Account (before insert,before update) {
    if(Trigger.isInsert){
        for(Account a : Trigger.New){
            system.debug('>>>'+a.Credit_Card_Number__c);
        }
    }
    if(Trigger.isUpdate){
        for(Account a : Trigger.New){
            system.debug('>>>'+a.Credit_Card_Number__c);
            system.debug('>>>'+Trigger.oldMap.get(a.Id).Credit_Card_Number__c);
            if(a.Credit_Card_Number__c <> Trigger.oldMap.get(a.id).Credit_Card_Number__c){
                system.debug('HOOOOOOOOHAAAAAAAA');
            }
        }
    }
}