trigger FeedItemTest on FeedItem (after insert) {
    for(FeedItem fi : Trigger.new){
        //Id relContVerId = [select Id,RelatedRecordId from FeedItem where Id=:fi.Id limit 1].RelatedRecordId;
        
        ContentVersion conV = [select Id, ContentSize from ContentVersion where Id =:fi.RelatedRecordId];
        
        if(conV.ContentSize >5)
        fi.addError(conV.ContentSize + '<<<FEED ITEM ERROR'+[select Id,RelatedRecordId from FeedItem where Id=:fi.Id]);
    }
}