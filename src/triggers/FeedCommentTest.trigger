trigger FeedCommentTest on FeedComment (before insert) {
    for(FeedComment f : trigger.new){
        f.addError('FeedComment error');
    }
}