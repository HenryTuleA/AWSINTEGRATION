public class DF_AWSIntegration {
    public AWS_Keys__c awsKeySet;
 
    //String keyf='fakekeyfakekeyfakekey';
    //    String secretf='fakesecretfakesecretfake+Fakesecretfak+';
         
    public void saveToS3(String docName, Blob blobFile){   
        String method = 'PUT';
        //this is needed for the PUT operation and the generation of the signature.  I use my local time zone.        
        String formattedDateString = Datetime.now().format('EEE, dd MMM yyyy HH:mm:ss z','America/Los_Angeles');    
        String filename = 'storage/'+docName;  // path to aws file location
        String region = '-us-west-2';
        String key='fakekeyfakekeyfakekey';
        String secret='fakesecretfakesecretfake+Fakesecretfak+';
        String bucketname = 'df2016' ;  //aws bucket name
        docName = docName.replace(' ', '+');
        
        HttpRequest req = new HttpRequest();
        Http http = new Http();
        req.setHeader('Content-Type', '');
        req.setHeader('Host','s3' + region + '.amazonaws.com');  //path style
        req.setHeader('Content-Disposition', 'attachment');
        req.setHeader('Content-Type', '');
        req.setHeader('Date', formattedDateString);
        //create the http Authorization header with param
        req.setHeader('Authorization',createAuthHeader(method,filename,formattedDateString,bucketname,key,secret));
        req.setEndpoint('https://s3' + region + '.amazonaws.com' + '/'+ bucketname + '/' + filename);   //path style
        req.setMethod(method);
        String binaryString=String.ValueOf(blobFile);
        if(binaryString != null && binaryString != ''){
            req.setBodyAsBlob(blobFile);
            req.setHeader('Content-Length', string.valueOf(binaryString.length()));           
            try {
                HTTPResponse res = http.send(req);    //Execute web service call           
            } catch(System.CalloutException e) {
                system.debug('MYDEBUG: AWS Service Callout Exception on ' + docName + 'ERROR: ' + e.getMessage());
            }
        }
    }
   
    //create authorization header for Amazon S3 REST API
    public string createAuthHeader(String method,String filename,String formattedDateString,
                                   String bucket,String key,String secret){
        string auth;
        String stringToSign = method+'\n\n\n'+formattedDateString+'\n/'+bucket+'/'+filename;
        //generate blog using the crytp generateMac
        Blob mac = Crypto.generateMac('HMACSHA1', blob.valueof(stringToSign),blob.valueof(secret));
        String sig = EncodingUtil.base64Encode(mac);
        auth = 'AWS' + ' ' + key + ':' + sig;
        return auth;
    }
    
    public void retrieveFromS3(String docName){   
        //String docName = 'bobby.txt';
        String key='fakekeyfakekeyfakekey';
        String secret='fakesecretfakesecretfake+Fakesecretfak+';
        String bucketname = 'bucket1';
        String formattedDateString = Datetime.now().format('EEE, dd MMM yyyy HH:mm:ss z','America/Los_Angeles');    //this is needed for the PUT operation and the generation of the signature.  I use my local time zone.        
        docName = docName.replace(' ', '+');
        String method = 'GET';
        HttpRequest req = new HttpRequest();
        Http http = new Http();
        String filename = 'storage/'+docName;
        String region = '-us-west-2';
        
        req.setHeader('Content-Type', '');
        req.setMethod(method);
        req.setHeader('Host','s3' + region + '.amazonaws.com');  //path style
        req.setEndpoint('https://s3' + region + '.amazonaws.com' + '/'+ bucketname + '/' + filename);   //path style
        req.setHeader('Content-Disposition', 'attachment');
        req.setHeader('Content-Type', '');
        req.setMethod(method);
        req.setHeader('Date', formattedDateString);
        req.setHeader('Authorization',createAuthHeader(method,filename,formattedDateString,bucketname,key,secret));
        
            //Execute web service call
            try {
                HTTPResponse res = http.send(req);
               /* if(res.getStatusCode()=200){
                     Blob resVal = res.getBodyAsBlob();
                     Attachment atVal = new Attachment();
                   //  atVal
                }
*/
               
                System.debug('MYDEBUG: ' + docName + ' RESPONSE STRING: ' + res.toString());
                System.debug('MYDEBUG: ' + docName + ' RESPONSE STATUS: '+res.getStatus());
                System.debug('MYDEBUG: ' + docName + ' STATUS_CODE:'+res.getStatusCode());
                
            } catch(System.CalloutException e) {
                system.debug('MYDEBUG: AWS Service Callout Exception on ' + docName + 'ERROR: ' + e.getMessage());
            }
     
    }

  public Integer deleteFromS3(String docName, String folderName){
         Integer intRes;   
        //String docName = 'bobby.txt';
        awsKeySet= AWS_Keys__c.getInstance('bucket1');

        String key        = awsKeySet.AWS_AccessKey_Id__c;
        String region     = awsKeySet.AWS_Region__c;
        String endpoint   = awsKeySet.AWS_Endpoint_URL__c;  
        String secret     = awsKeySet.AWS_Secret_Key__c ;
        String bucketname = awsKeySet.Name;
        
        System.debug('key = > ' + key );
        System.debug('region = > ' + region );
        System.debug('secret = > ' + secret );
        System.debug('bucketname = > ' + bucketname );
        
      /*  
        String key='fakekeyfakekeyfakekey';
        String secret='fakesecretfakesecretfake+Fakesecretfak+';
        String bucketname = 'bucket1';
      */  
        String formattedDateString = Datetime.now().format('EEE, dd MMM yyyy HH:mm:ss z','America/Los_Angeles');    //this is needed for the PUT operation and the generation of the signature.  I use my local time zone.        
        //docName = docName.replace(' ', '+');
        String method = 'DELETE';
        HttpRequest req = new HttpRequest();
        Http http = new Http();
        String filename = folderName;
        // String region = '-us-west-2';
         System.debug('MYDEBUG filename: ' + filename );
         System.debug('MYDEBUG docName: ' + docName );
        req.setHeader('Content-Type', '');
        req.setMethod(method);
       //req.setHeader('Host','s3-us-west-2.amazonaws.com');  //path style
       // req.setEndpoint('https://s3' + region + '.amazonaws.com' + '/'+ bucketname + '/'+ filename);
        req.setHeader('Host', region);  //path style
        req.setEndpoint(endpoint+ bucketname + '/'+ filename);
       
        //req.setEndpoint('https://s3' + region + '.amazonaws.com' + '/'+ bucketname + '/' + filename);   //path style
        req.setHeader('Content-Disposition', 'attachment');
        req.setHeader('Content-Type', '');
        req.setMethod(method);
        req.setHeader('Date', formattedDateString);
        req.setHeader('Authorization',createAuthHeader(method,filename,formattedDateString,bucketname,key,secret));
        
            //Execute web service call
            try {
                HTTPResponse res = http.send(req);
                System.debug('MYDEBUG: ' + docName + ' RESPONSE STRING: ' + res.toString());
                System.debug('MYDEBUG: ' + docName + ' RESPONSE STATUS: '+res.getStatus());
                System.debug('MYDEBUG: ' + docName + ' STATUS_CODE:'+res.getStatusCode());
                intRes = res.getStatusCode();
                return intRes; 
                
            } catch(System.CalloutException e) {
                system.debug('MYDEBUG: AWS Service Callout Exception on ' + docName + 'ERROR: ' + e.getMessage());
                return 400;
            }
            
    }
}