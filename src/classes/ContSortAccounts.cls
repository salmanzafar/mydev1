public class ContSortAccounts {
    public ContSortAccounts() {
        //Default Sorting Field.
        SortFieldAccounts = 'LastModifiedDate';        
        lstAccounts = [select Id,Name,Type,LastModifiedDate from Account 
        				order by LastModifiedDate desc];
        
        // list of those records that need to be sorted.
        lstSortAccounts = new list<SortAccounts>();
        for (Account acc : lstAccounts){
            lstSortAccounts.add(new SortAccounts(acc));        
        }   
    }
    // To identify which field we need to sort.
    public String SortFieldAccounts {get;set;}
    // To identify the order of sorting
    public String SortOrderAccounts {get;set;}
    // To identify that perviously sorted field was selected.
    public String PreviousSortField {get;set;}
    
    // Making this list transient as we dont need it in the view state
    public transient list<Account> lstAccounts{get;set;}
    
    public list<SortAccounts> lstSortAccounts{get;set;}
    
    public void doSortAccounts(){        
        SortOrderAccounts = 'Ascending';
        
        /*This checks to see if the same header was click two times in a row, 
        if so it switches the order.*/
        
        if(PreviousSortField  == SortFieldAccounts){
            SortOrderAccounts = 'Descending';
            PreviousSortField = null;
        }
        else
            PreviousSortField = SortFieldAccounts;
        
        SortAccounts.SortDirection = SortOrderAccounts;
        SortAccounts.SortField = SortFieldAccounts;
        lstSortAccounts.sort();    
    }
}