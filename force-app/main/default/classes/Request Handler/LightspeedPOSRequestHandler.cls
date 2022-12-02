public class LightspeedPOSRequestHandler{

    public static String insertRequest(String payload, String module){
        try {
            POS_Request_Log__c log = new POS_Request_Log__c(
                POS_Payload__c = payload,
                Module__c = module
            );
            insert log;
            return log.Id;
        } catch (Exception ex) {
            LightspeedPOSErrorHandler.insertErrorLog(ex);
            return null;
        }
    }

    @InvocableMethod(callout=true label='Reprocess Request')
    public static List<String> reprocessRequestLog(List<ID> ids) {
        try {
            POS_Request_Log__c requestLog = [SELECT Id, Module__c, POS_Payload__c FROM POS_Request_Log__c WHERE Id in :ids];
            List<String> lstResponse = new List<String>();
            String moduleName = requestLog.Module__c;
            String siteName = '';
            String endPoint = '';

            if (moduleName == 'Customer') {
                siteName = 'Vend_Customers';
                endPoint = 'lightSpeedCustomer';
            } else if (moduleName == 'Product') {
                siteName = 'Vend_Products';
                endPoint = 'lightSpeedProduct';
            } else if (moduleName == 'Sale') {
                siteName = 'Vend_Sales';
                endPoint = 'lightSpeedSale';
            }

            Id siteId = [SELECT GuestUserId, Name,MasterLabel, Subdomain, OptionsRequireHttps, UrlPathPrefix FROM Site WHERE Status = 'Active' AND Name = :siteName].Id;
            String secureURL = [SELECT SecureURL FROM SiteDetail WHERE DurableId =: siteId].SecureURL;
            String url = SecureURL + '/services/apexrest/' + endPoint;

            RestRequest request = new RestRequest();
            RestResponse res = new RestResponse();
            request.requestUri = url;
            request.httpMethod = 'POST';
            request.addHeader('Content-Type', 'application/json');
            request.addHeader('Accept', '*/*');
            request.addParameter('payload', requestLog.POS_Payload__c);

            RestContext.request = request;
            RestContext.response = res;

            if (moduleName == 'Customer') {
                LightspeedCustomerRESTService.handleHookCustomers();
            } else if (moduleName == 'Product') {
                LightspeedProductRESTService.handleHookProducts();
            } else if (moduleName == 'Sale') {
                LightspeedSaleRESTService.handleHookSales();
            }

            System.debug(request);
            System.debug(res.responseBody.toString());
            System.debug(res.statusCode);

            lstResponse.add('Reprocess ' + moduleName.toLowerCase() + ' success.');
            return lstResponse;
        } catch (Exception ex) {
            LightspeedPOSErrorHandler.insertErrorLog(ex);
            return null;
        }
    }
}