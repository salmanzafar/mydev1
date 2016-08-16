public class contSortAccountsClone {

    public contSortAccountsClone() {
        //Default Sorting Fields.
        SortFieldAccounts = 'AccountName';
        //SortOrderAccounts='';
        
        lstAccounts = [select Id,Name,Type,LastModifiedDate from Account order by Name desc];
        lstSortAccounts = new list<SortAccountsCLONE>();
        for (Account acc : lstAccounts){
            lstSortAccounts.add(new SortAccountsCLONE(acc));        
        }   
    }
    
    public String SortFieldAccounts {get;set;}
    public String SortOrderAccounts {get;set;}
    public String PreviousSortField {get;set;}
    
    public list<Account> lstAccounts{get;set;}
    public list<SortAccountsCLONE> lstSortAccounts{get;set;}
    
    public void doSortAccounts(){
        
        SortOrderAccounts = 'Ascending';
        
        /*This checks to see if the same header was click two times in a row, if so
        it switches the order.*/
        if(PreviousSortField  == SortFieldAccounts){
            SortOrderAccounts = 'Descending';
            PreviousSortField = null;
        }
        else{
            PreviousSortField = SortFieldAccounts;
        }
        System.debug('!!!Sort FIELD:::'+SortFieldAccounts);
        system.debug('@@:'+lstSortAccounts);
        SortAccountsCLONE.SortDirection = SortOrderAccounts;
        SortAccountsCLONE.SortField = SortFieldAccounts;
        lstSortAccounts.sort(); 
        system.debug('BB:'+lstSortAccounts);       
    }

}