public class thecontroller {

    public thecontroller(ApexPages.StandardController controller) {

    }



    public string out{
        get {
            if(out==null){out='getter';}
            return out;
        }
        set;
    }
    public thecontroller (){
        out = 'constructor';
    }
    
    public void setOut(){
        out = 'action';
    }
           
    public PageReference redirect() {
    String userAgent =
    ApexPages.currentPage().getHeaders().get('USER-AGENT');
    
    system.debug('userAgent>>'+userAgent);
    
    Return null;
    }
    
}