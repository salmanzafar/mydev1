/* 
 * Created By : Lister Technologies
 * Created Date : 24-Sep-2013
 * Created Purpose : To search for accounts using autocomplete feature
 */
public class SearchAccounts {
    @RemoteAction
    public static List<Account> searchFor(String searchTerm){
        // create the filter text
        String filter = ' like \'%' + String.escapeSingleQuotes(searchTerm) + '%\'';
        //begin building the dynamic soql query
        String queryStr = 'SELECT Id, Name, ShippingState, ShippingCity FROM Account WHERE Name' + filter+ ' ORDER By Name';
        List<Account> lstAccounts = new List<Account>();
        try {
            system.debug(queryStr);
            lstAccounts = Database.query(queryStr);
            system.debug(lstAccounts);
        }
        catch (QueryException e) {
            return null;
        }
        return lstAccounts;
    }
    /*
    @isTest 
    static void testSearchFor(){
        Account acc1 = new Account(Name = 'test');
        Account acc2 = new Account(Name = 'west');
        insert new List<Account>{acc1, acc2};
        
        Test.startTest();
        system.assertEquals(2,SearchAccounts.searchFor('est').size());
        Test.stopTest();
    }*/
}