trigger UserTrigger on User (after insert) {
    set<Id> setUserId = new set<Id>();
    for(user u : trigger.new){
        if(!u.isActive){
            setUserId.add(u.Id);
        }
    }
    list<User> listUser = [select Id,isActive from user where Id IN:setUserId];
    
    for(User u : listUser ){
        u.isActive = true;
    }
    system.debug(JSON.serializePretty(listUser ));
    update listUser ;
    
}