/* 
    @@ Created Date: 9/8/2013
    @@ Last Revision Date: 9/10/2013
    @@ Developer: Salman Zafar
    @@ Version 1.1
    @@ Purpose: To receive a csv file from email service and insert those records
               into Movie object. Also, check duplicate movie titles and send them
               back to sender in error file.    
*/

global class EmailProcessMovieRecords implements Messaging.InboundEmailHandler {
    global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email,Messaging.InboundEnvelope envelope){
         
            Messaging.InboundEmailResult result = new Messaging.InboundEmailresult();
            system.debug('MESSAGE DOT INBOUND EMAIL RESULT - '+result);
            system.debug('MESSAGE DOT INBOUND EMAIL - '+email);
           
            // Captures the sender's email address   
            String emailAddress = envelope.fromAddress;
            system.debug('The From Email address is: ['+emailAddress+']');           
                                  
            String[] emailAddresses = new String[]{};
            emailAddresses.add(emailAddress);
           
            // Retrieves content from the email body. 
            // Splits each line by the terminating newline character       
            String[] emailBody = email.plainTextBody.split('\n', 0);           
           
            Wealth_X_Settings__c WXsettings = Wealth_X_Settings__c.getValues('Movie Email Service Template');
           
            string filename = WXsettings.Value__c;  
           
            // Used to store Movies records until they can be inserted in Movie object
            list<Movie__c> lstMoviesToInsert = new list<Movie__c>();
            
            // PRROCESSING TEXT ATTACHMENTS.
            if (email.textAttachments != null && email.textAttachments.size() > 0) {
                for (Messaging.Inboundemail.TextAttachment tAttachment : email.textAttachments) {
              
                    String csvBody = tAttachment.toString();  // Pull attachment contents into a large string
                    map<Movie__c,String> mapMovieWithError = new map<Movie__c,String>();
                   
                    String userLoginId = null;
                    Boolean errorFound = false;
                    Boolean sendTemplate = false;
                    String errorMessage = '';
                   
                    List<List<String>> parsedCSV = EmailProcessMovieRecords.parseCSV(csvBody ,true,true);
                    system.debug('PARSED CSV'+parsedCSV);
                   
                    set<String> setMoviesTitle = new set<String>();
                   
                    for(List<String> record : parsedCSV){
                        setMoviesTitle.add(record[1].replace('"',''));                               
                    }
                   
                    system.debug('SET MOVIE TITLES-'+setMoviesTitle);
                   
                    set<String> setExistingTitles = new set<String>();
                   
                    //Querying existing movies and putting their titles in set.
                    if(!setMoviesTitle.isEmpty()){
                        for(Movie__c existingTitles : [select Id, Name from Movie__c where Name IN:setMoviesTitle]){
                            setExistingTitles.add(existingTitles.Name);       
                        }
                    }
                   
                    system.debug('SET EXISTING TITLES - '+setExistingTitles);
                   
                    for(List<String> record : parsedCSV){
                        system.debug('Record['+parsedCSV+']');
                       
                        // Checking if current record doesnt exist already.
                        if(!setExistingTitles.contains(record[1].replace('"',''))){
                           
                            system.debug('I AM HERE');
                            lstMoviesToInsert.add(new Movie__c(Id__c = record[0],
                                                               Name = record[1].replace('"',''),
                                                               Director__c = record[2].replace('"',''),
                                                               Year__c = record[3],
                                                               Genre__c = record[4]
                                                               ));
                        }
                       
                        // Checking if current record already exists.
                        else if(setExistingTitles.contains(record[1].replace('"',''))){
                            system.debug('I AM IN DUP');
                            mapMovieWithError.put(new Movie__c(Id__c = record[0],
                                                               Name = record[1].replace('"',''),
                                                               Director__c = record[2].replace('"',''),
                                                               Year__c = record[3],
                                                               Genre__c = record[4]),
                                                               'Movie with same title already exists. '+
                                                               'Contact your Admin for further details.');
                        }
                    }
                   
                    system.debug('MOVIES TO INSERT - '+lstMoviesToInsert);
                    system.debug('MAP MOVIE WITH ERRORS - '+mapMovieWithError);
                   
                    Database.SaveResult[] Results = database.insert(lstMoviesToInsert,false);
                   
                    integer i =0;
                   
                    for (Database.SaveResult res : Results){
                       
                        if (res.getErrors().size() > 0) {
                            System.debug('Error Message'+res.getErrors()[0].getMessage());
                            mapMovieWithError.put(lstMoviesToInsert[i],res.getErrors()[0].getMessage());
                        }
                        i++;  
                    }
                    system.debug('THESE MOVIE RECORDS HAVE ERRORS - '+mapMovieWithError);
                   
                    if(!mapMovieWithError.keySet().isEmpty()){
                   
                        string header = 'ID,Title,Director,Year,Genre,Error Message \n';
                        string finalstr = header ;
                       
                        for (Movie__c movie : mapMovieWithError.keySet()){
                            string recordString = CreateTextForCSV(movie.Id__c)       +','+
                                                  CreateTextForCSV(movie.Name)        +','+
                                                  CreateTextForCSV(movie.Director__c) +','+
                                                  CreateTextForCSV(movie.Year__c)     +','+
                                                  CreateTextForCSV(movie.Genre__c)    +','+
                                                  CreateTextForCSV(mapMovieWithError.get(movie))+'\n';
                            finalstr = finalstr +recordString;
                        }
                        system.debug('ERROR CSV TO SEND'+finalstr);
                       
                        blob csvBlob = Blob.valueOf(finalstr);
                        string csvName= 'Errors.csv';
                       
                        Messaging.EmailFileAttachment csvAttachment = new Messaging.EmailFileAttachment();                       
                        csvAttachment.setFileName(csvName);
                        csvAttachment.setBody(csvBlob);
                       
                        Messaging.SingleEmailMessage mail =new Messaging.SingleEmailMessage();
                        mail.setFileAttachments(new Messaging.EmailFileAttachment[]{csvAttachment});
                        mail.setToAddresses(emailAddresses);
                        mail.setsubject('Errors found while processing movie records.');
                        mail.setPlainTextBody('Please find attachment for reviewing error records.');
                       
                        Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});                       
                    }
                }
            }
            
            // PROCESSING BINARY ATTACHMENTS                        
            else if (email.binaryAttachments != null && email.binaryAttachments.size() > 0) {
                for (Messaging.Inboundemail.BinaryAttachment bAttachment : email.binaryAttachments) {
                    String csvBody = NULL;
                    Boolean correctCSVformat = false;
                    
                    try{
                        csvBody = bAttachment.body.toString();  // Pull attachment contents into a large string
                        correctCSVformat = True;
                    }
                    catch(System.StringException e){
                        Messaging.SingleEmailMessage mail =new Messaging.SingleEmailMessage(); 
                        mail.setToAddresses(emailAddresses);
                        mail.setsubject('Incorrect CSV file format.');
                        mail.setPlainTextBody('CSV file encoding is not correct. '+
                                              'Please send file in UTF-8 encoding. Message:'+e.getMessage());
                        
                        Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});      
                    }
                    
                    if(correctCSVformat){
                        map<Movie__c,String> mapMovieWithError = new map<Movie__c,String>();                    
                        
                        List<List<String>> parsedCSV = EmailProcessMovieRecords.parseCSV(csvBody ,true, false);
                        system.debug('PARSED CSV'+parsedCSV);
                        
                        set<String> setMoviesTitle = new set<String>();
                        
                        for(List<String> record : parsedCSV){
                            setMoviesTitle.add(record[1].replace('"',''));                                
                        }
                        
                        system.debug('SET MOVIE TITLES-'+setMoviesTitle);
                        
                        set<String> setExistingTitles = new set<String>();
                        
                        //Querying existing movies and putting their titles in set.
                        if(!setMoviesTitle.isEmpty()){
                            for(Movie__c existingTitles : [select Id, Name from Movie__c where Name IN:setMoviesTitle]){
                                setExistingTitles.add(existingTitles.Name);        
                            }
                        }
                        
                        system.debug('SET EXISTING TITLES - '+setExistingTitles);
                        
                        for(List<String> record : parsedCSV){
                            system.debug('Record['+parsedCSV+']');
                            
                            // Checking if current record doesnt exist already.
                            if(!setExistingTitles.contains(record[1].replace('"',''))){
                                
                                system.debug('I AM HERE');
                                lstMoviesToInsert.add(new Movie__c(Id__c = record[0],
                                                                   Name = record[1].replace('"',''),
                                                                   Director__c = record[2].replace('"',''),
                                                                   Year__c = record[3],
                                                                   Genre__c = record[4]
                                                                   )); 
                            }
                            
                            // Checking if current record already exists.
                            else if(setExistingTitles.contains(record[1].replace('"',''))){
                                system.debug('I AM IN DUP');
                                mapMovieWithError.put(new Movie__c(Id__c = record[0],
                                                                   Name = record[1].replace('"',''),
                                                                   Director__c = record[2].replace('"',''),
                                                                   Year__c = record[3],
                                                                   Genre__c = record[4].replace('\r','')),
                                                                   'Movie with same title already exists. '+
                                                                   'Contact your Admin for further details.'); 
                            }
                        }
                        
                        system.debug('MOVIES TO INSERT - '+lstMoviesToInsert);
                        system.debug('MAP MOVIE WITH ERRORS - '+mapMovieWithError);
                        
                        Database.SaveResult[] Results = database.insert(lstMoviesToInsert,false);
                        
                        integer i =0;
                        
                        for (Database.SaveResult res : Results){
                            
                            if (res.getErrors().size() > 0) {
                                System.debug('Error Message'+res.getErrors()[0].getMessage());
                                mapMovieWithError.put(lstMoviesToInsert[i],res.getErrors()[0].getMessage());
                            } 
                            i++;   
                        }
                        system.debug('THESE MOVIE RECORDS HAVE ERRORS - '+mapMovieWithError);
                        
                        if(!mapMovieWithError.keySet().isEmpty()){
                        
                            string header = 'ID,Title,Director,Year,Genre,Error Message \n';
                            string finalstr = header ;
                            
                            for (Movie__c movie : mapMovieWithError.keySet()){
                                string recordString = CreateTextForCSV(movie.Id__c)       +','+
                                                      CreateTextForCSV(movie.Name)        +','+
                                                      CreateTextForCSV(movie.Director__c) +','+
                                                      CreateTextForCSV(movie.Year__c)     +','+
                                                      CreateTextForCSV(movie.Genre__c)    +','+
                                                      CreateTextForCSV(mapMovieWithError.get(movie))+'\n';
                            finalstr = finalstr +recordString;                                
                            }
                            system.debug('ERROR CSV TO SEND'+finalstr);
                            
                            blob csvBlob = Blob.valueOf(finalstr);
                            string csvName= 'Errors.csv';
                            
                            Messaging.EmailFileAttachment csvAttachment = new Messaging.EmailFileAttachment();                        
                            csvAttachment.setFileName(csvName);
                            csvAttachment.setBody(csvBlob);
                            
                            
                            Messaging.SingleEmailMessage mail =new Messaging.SingleEmailMessage();
                            mail.setFileAttachments(new Messaging.EmailFileAttachment[]{csvAttachment}); 
                            mail.setToAddresses(emailAddresses);
                            mail.setsubject('Errors found while processing movie records.');
                            mail.setPlainTextBody('Please find attachment for reviewing error records.');
                            
                            Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});                        
                        }
                    }
                }
            }
            
            
           
            else{
           
                // Received an email without an attachment.  Send template to the requester.
               
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();  
                mail.setToAddresses(emailAddresses);
                mail.setsubject('Missing File Attahment - Most recent template attached.');
                mail.setPlainTextBody('Your Email request did not contain an attachment.  Perhaps you need the latest template.  If so, you will find it attached to this email.');
                mail.setHTMLBody('Your Email request did not contain an attachment.  Perhaps you need the latest template.  If so, you will find it attached to this email.');
                   
                system.debug('The Filename is: ' + filename);
                   
                Document doc = [select id, name, body, contenttype, developername, type from Document where developerName = :filename];
    
                Messaging.EmailFileAttachment attach = new Messaging.EmailFileAttachment();
                attach.setContentType(doc.contentType);
                attach.setFileName(doc.name+'.'+doc.type);
                attach.setInline(false);
                attach.Body = doc.Body;            
                mail.setFileAttachments(new Messaging.EmailFileAttachment[] { attach });           
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
                result.success = true;    
            }
         
        return result;
    }
    
    public static List<List<String>> parseCSV(String contents,Boolean skipHeaders, Boolean skipFooters){
    
        List<List<String>> allFields = new List<List<String>>();
    
        // replace instances where a double quote begins a field containing a comma
        // in this case you get a double quote followed by a doubled double quote
        // do this for beginning and end of a field
        contents = contents.replaceAll(',"""',',"DBLQT').replaceall('""",','DBLQT",');
        // now replace all remaining double quotes - we do this so that we can reconstruct
        // fields with commas inside assuming they begin and end with a double quote
        contents = contents.replaceAll('""','DBLQT');
        // we are not attempting to handle fields with a newline inside of them
        // so, split on newline to get the spreadsheet rows
        List<String> lines = new List<String>();
        try {
            lines = contents.split('\n');
        } catch (System.ListException e) {
            System.debug('Limits exceeded?' + e.getMessage());
        }
        Integer num = 0;
        for(String line : lines) {
            // check for blank CSV lines (only commas)
            if (line.replaceAll(',','').trim().length() == 0) break;
            
            List<String> fields = line.split(',');  
            List<String> cleanFields = new List<String>();
            String compositeField;
            Boolean makeCompositeField = false;
            for(String field : fields) {
                if (field.startsWith('"') && field.endsWith('"')) {
                    cleanFields.add(field.replaceAll('DBLQT','"'));
                } else if (field.startsWith('"')) {
                    makeCompositeField = true;
                    compositeField = field;
                } else if (field.endsWith('"')) {
                    compositeField += ',' + field;
                    cleanFields.add(compositeField.replaceAll('DBLQT','"'));
                    makeCompositeField = false;
                } else if (makeCompositeField) {
                    compositeField +=  ',' + field;
                } else {
                    cleanFields.add(field.replaceAll('DBLQT','"'));
                }
            }            
            allFields.add(cleanFields);
        }
        if (skipHeaders) allFields.remove(0);
        
        if (skipFooters) allFields.remove(allFields.size()-1);
        
        system.debug('THESE ARE ALL FIELDS 11--'+allFields);
        
        return allFields;       
    }
    
    private String CreateTextForCSV(String text){
        if(text.contains(',')){
            text = '"'+text+'"';
            return text;
        }   
        else 
            return text;
    }
}