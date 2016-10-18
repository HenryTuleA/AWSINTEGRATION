public with sharing class CustomObjectAccountController {
/*
Class that allows you to select one or more records and delete from salesforce
and should also call AWSIntegration to delete from AWS S2

*/  public Id caseId ;
    private ApexPages.StandardController standardController;
 
    private ApexPages.StandardSetController standardSetController;
 
    public CustomObjectAccountController(ApexPages.StandardController standardController)
    {
        this.standardController = standardController;
    }
    
    public CustomObjectAccountController(ApexPages.StandardSetController standardSetController)
    {
        this.standardSetController = standardSetController;
    }
 

    public PageReference doDeleteListDocuments()
    {
      
        // Apex code for handling records from a List View goes here
        List<Document__c> listViewRecords = (List<Document__c>) standardSetController.getRecords();
        List<Document__c> selectedListViewRecords = (List<Document__c>) standardSetController.getSelected();
        List<Document__c> selectedListViewDetailRecords = [Select Document_URL__c,  Account__c, Document_Name__c, Type__c from Document__c Where Id=: selectedListViewRecords];
        Id acctId ;
        for(Document__c x : selectedListViewDetailRecords){
            System.debug('SELECTEDREC: ' + x.id + '  ' + x.Name);
            
            acctId = x.Account__c;
        }
        
       // Boolean hasMore = standardSetController.getHasNext();
        PageReference pageRef = new PageReference('/' + acctId);
        pageRef.setRedirect(true);       
        return pageRef;
    }
    
   
   
    
    public PageReference doDeleteDocument()
    {
        // Apex code for handling record from a Detail page goes here
        Id recordId = standardController.getId();
        System.debug('CASE_ONERECrecordId : ' + recordId);
        Document__c record = (Document__c) standardController.getRecord();
        record = [Select Document_URL__c, Account__c, Document_FilePath__c,  Document_Name__c, Type__c from Document__c Where Id=: recordId];
        
        System.debug('CASE_ONEREC: ' + record.Account__c);
        AWSIntegration awsX = new AWSIntegration();
        
        Integer intRes = awsX.deleteFromS3(record.Document_Name__c ,record.Document_FilePath__c );
        if(intRes == 204){
            delete record;
        }
        PageReference pageRef = new PageReference('/' + record.Account__c);
        pageRef.setRedirect(true);
        return pageRef;
    }
}