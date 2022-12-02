public with sharing class LightspeedPOSRequestHandlerController {

    @AuraEnabled(cacheable=true)
    public static List<DataTableWrapper> getRequests() {
        List<POS_Request_Log__c> POSRequestLogs = [SELECT id, Name, Module__c, POS_Payload__c, CreatedDate FROM POS_Request_Log__c ORDER BY CreatedDate desc];

        List<DataTableWrapper> response = new List<DataTableWrapper>();
        for(POS_Request_Log__c request : POSRequestLogs){
            DataTableWrapper obj = new DataTableWrapper();
            obj.RequestId = request.Id;
            obj.Name = request.Name;
            obj.NameUrl = System.URL.getSalesforceBaseUrl().toExternalForm() + '/' + request.Id;
            obj.Module = request.Module__c;
            obj.Payload = request.POS_Payload__c;
            obj.CreatedDate = request.CreatedDate.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ');
            response.add(obj);
        }
        return response;
    }

    private class DataTableWrapper {
        @AuraEnabled
        public Id RequestId {get;set;}
        @AuraEnabled
        public String Name {get;set;}
        @AuraEnabled
        public String NameUrl {get;set;}
        @AuraEnabled
        public String Module {get;set;}
        @AuraEnabled
        public String Payload {get;set;}
        @AuraEnabled
        public String CreatedDate {get;set;}
    }
}
