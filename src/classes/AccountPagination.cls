public with sharing class AccountPagination {
    private final Account acct;  
//Test2 3 4 5 6 7 88
    // The constructor passes in the standard controller defined 
    
    // in the markup below 
    
    public AccountPagination(ApexPages.StandardSetController controller) {
        this.acct = (Account)controller.getRecord();
		//test
    }    
    
    public ApexPages.StandardSetController accountRecords {
        get {
            if(accountRecords == null) {
                accountRecords = new ApexPages.StandardSetController(
                    Database.getQueryLocator([SELECT Name FROM Account WHERE Id NOT IN 
                        (SELECT AccountId FROM Opportunity WHERE IsClosed = true)]));
            }
            return accountRecords;
        }
        private set;
    }
    public List<Account> getAccountPagination() {
         return (List<Account>) accountRecords.getRecords();
    }  
}