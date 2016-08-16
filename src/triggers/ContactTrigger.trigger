trigger ContactTrigger on Contact (after update) {
    Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        User u = new User(Alias = 'standt', Email='standarduser@'+UserInfo.getOrganizationId()+'.com', EmailEncodingKey='UTF-8', LastName='Testing', 
                        LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId = p.Id, 
                        TimeZoneSidKey='America/Los_Angeles', UserName='standarduser@'+UserInfo.getOrganizationId()+'.com');
        insert u;
}