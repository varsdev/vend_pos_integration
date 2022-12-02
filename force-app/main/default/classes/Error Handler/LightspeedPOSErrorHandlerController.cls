public with sharing class LightspeedPOSErrorHandlerController {

    @AuraEnabled(cacheable=true)
    public static List<DataTableWrapper> GetErrors() {
        List<POS_Error_Log__c> POSErrorLogs = [SELECT Id, Name, Exception_Type_Name__c, StackTrace__c, CreatedDate, Error_Line__c FROM POS_Error_Log__c ORDER BY CreatedDate desc];

        List<DataTableWrapper> response = new List<DataTableWrapper>();
        for(POS_Error_Log__c error : POSErrorLogs){
            DataTableWrapper obj = new DataTableWrapper();
            obj.ErrorId = error.Id;
            obj.name = error.Name;
            obj.nameUrl = System.URL.getSalesforceBaseUrl().toExternalForm() + '/' +error.Id;
            obj.ExceptionTypeName = error.Exception_Type_Name__c;
            obj.StackTrace = error.StackTrace__c;
            obj.CreatedDate =error.CreatedDate.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ');
            obj.ErrorLine = error.Error_Line__c;
            response.add(obj);
        }
        return response;
    }

    private class DataTableWrapper {
        @AuraEnabled
        public Id ErrorId {get;set;}
        @AuraEnabled
        public String name {get;set;}
        @AuraEnabled
        public String nameUrl {get;set;}
        @AuraEnabled
        public String ExceptionTypeName {get;set;}
        @AuraEnabled
        public String StackTrace {get;set;}
        @AuraEnabled
        public String CreatedDate {get;set;}
        @AuraEnabled
        public String ErrorLine {get;set;}
    }
}