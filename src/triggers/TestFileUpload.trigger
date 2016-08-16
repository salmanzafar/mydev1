trigger TestFileUpload on ContentVersion (before insert) {
    for(ContentVersion c : trigger.new){
        c.addError('!!@!@');
    }
}