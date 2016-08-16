global class SortAccountsCLONE implements Comparable {
  
    // default sorting would be ascending
    public static String SortDirection = 'Ascending';
    
    // default sorting would be on Date Submitted
    public static String SortField = 'AccountName';
  
    public Boolean selectedAccount{set;get;}
    
    public Account account{set;get;}
  
    public SortAccountsCLONE (Account ac){
        account = ac;
    }
    
    global Integer compareTo(Object other){
        if (SortField == 'AccountName'){
            System.debug('IAMHERE');
            return compareToAccountName(other);
        } 
        if (SortField == 'AccountType') {
            return compareToAccountType (other);
        } 
        return -1;
    }    
           
    Integer compareToAccountName (object objAccount){
        System.debug('Lets SEE WHAT IS HEREAccount'+objAccount);
        String otherName = (((SortAccounts)objAccount).account.Name != null) ? ((SortAccountsCLONE)objAccount).account.Name : '';          
        if (SortDirection == 'Ascending')
            return this.account.Name.compareTo(otherName);
        else
            return otherName.compareTo(this.account.Name); 
                   
    }
    
    Integer compareToAccountType (object objAccount){
        System.debug('Lets SEE WHAT IS HERE:'+objAccount);
        String otherType = (((SortAccountsCLONE)objAccount).account.Type!= null) ? ((SortAccountsCLONE)objAccount).account.Type: '';          
        if (SortDirection == 'Ascending')
            return this.account.Type.compareTo(otherType);
        else
            return otherType.compareTo(this.account.Type);                    
    }
    
}