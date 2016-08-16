global class SortAccounts implements Comparable {
      
    // Default sorting order --> Descending
    public static String SortDirection = 'Descending';
    
    // Default sorting field --> LastModifiedDate
    public static String SortField = 'LastModifiedDate';
    
    public Account account {set;get;}
  
    public SortAccounts (Account a){
        account = a;
    }
    
    /* CompareTo implementation for comparing
       Account Name, Type and LastModifiedDate
    */
    
    global Integer compareTo(Object other){
        // Sort on Name
        if (SortField == 'AccountName'){
            return compareToAccountName(other);
        } 
        // Sort on Type
        if (SortField == 'AccountType'){
            return compareToAccountType (other);
        } 
        // Sort on Field
        if (SortField == 'LastModifiedDate'){
            return compareToAccountLastModifiedDate (other);
        }        
        return -1;
    }    
    
    // compare Account --> Name       
    Integer compareToAccountName (object objAccount){
        String otherName = (((SortAccounts)objAccount).account.Name != null) ? 
        					((SortAccounts)objAccount).account.Name : '';          
        // For Ascending
        if (SortDirection == 'Ascending')
            return this.account.Name.compareTo(otherName);
        // For Descending
        else
            return otherName.compareTo(this.account.Name);
    }
    
    // Compare Account --> Type
    Integer compareToAccountType (object objAccount){
        String otherType = (((SortAccounts)objAccount).account.Type!= null) ? 
        					((SortAccounts)objAccount).account.Type: '';
        // For Ascending
        if (SortDirection == 'Ascending')
            // Check if account type is not Null, if its Null return -1
            return this.account.Type != Null ? this.account.Type.compareTo(otherType) : -1;
        // For Descending
        else
            // Check if account type is not Null, if its Null return 1
            return this.account.Type != Null ? otherType.compareTo(this.account.Type) :  1;
    }
    
    // Compare Account --> Last Modified Date
    Integer compareToAccountLastModifiedDate(Object objAccount) {
        DateTime otherLastModifiedDate = ((SortAccounts)objAccount).account.LastModifiedDate != null ? 
    									  ((SortAccounts)objAccount).account.LastModifiedDate : System.today();  
        // For Ascending
        if (SortDirection == 'Ascending') 
            return (this.account.LastModifiedDate.getTime() - otherLastModifiedDate.getTime()).intValue();
        // For Descending
        else
            return (otherLastModifiedDate.getTime() - this.account.LastModifiedDate.getTime()).intValue(); 
    }
}