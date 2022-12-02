@isTest
public class LightspeedCustomerRESTServiceTest{

    @TestSetup
    static void makeData(){
        POS_APP_Setting__c posAppSetting = new POS_APP_Setting__c();
        posAppSetting.Integration_Status__c = TRUE;
        posAppSetting.Contact_Sync__c = 'Dual Sync';
        insert posAppSetting;
    }

    @istest
    static void testHandleHookCustomer(){
        String json = '{"balance":"0","company_name":null,"contact":{"company_name":null,"email":"test1@gmail.com","fax":null,"first_name":"Customer","last_name":"test","mobile":"11111111","phone":null,"physical_address1":"street","physical_address2":null,"physical_city":"city","physical_country_id":"US","physical_postcode":"11111","physical_state":"state","physical_suburb":null,"postal_address1":"street","postal_address2":null,"postal_city":"city","postal_country_id":"US","postal_postcode":"11111","postal_state":"state","postal_suburb":null,"twitter":null,"website":null},"contact_first_name":"Customer","contact_last_name":"test","created_at":"2022-08-02T17:25:37Z","custom_field_1":null,"custom_field_2":null,"custom_field_3":null,"custom_field_4":null,"customer_code":"Customer-7RC4","customer_group_id":"06326976-9d65-11ed-fa40-0f5187f9f67b","date_of_birth":null,"deleted_at":null,"do_not_email":true,"email":"test1@gmail.com","enable_loyalty":true,"fax":null,"first_name":"Customer","id":"06326976-9dcb-11ed-fa40-12881f93edd5","last_name":"test","loyalty_balance":"0","mobile":"11111111","note":null,"phone":null,"retailer_id":"06326976-9d65-11ed-fa40-0f5187f82e49","sex":"M","updated_at":"2022-08-02T18:04:36Z","version":23759051889,"year_to_date":"0"}';

        RestRequest request = new RestRequest();
        RestResponse res = new RestResponse();

        // Id siteId = [SELECT GuestUserId, Name,MasterLabel, Subdomain, OptionsRequireHttps, UrlPathPrefix FROM Site WHERE Status = 'Active' AND Name = 'Vend_Customers'].Id;
        // String secureURL = [SELECT SecureURL FROM SiteDetail WHERE DurableId =: siteId].SecureURL;
        // String url = SecureURL + '/services/apexrest/lightSpeedCustomer';
        String url = '/services/apexrest/lightSpeedCustomer';
        System.debug('url: ' + url);

        request.requestUri = url;
        request.httpMethod = 'POST';
        request.addHeader('Content-Type', 'application/json');
        request.addParameter('payload', json);
        RestContext.request = request;
        RestContext.response = res;

        Test.startTest();

        LightspeedCustomerRESTService.handleHookCustomers();

        Test.stopTest();
        System.debug(res);
    }

    @istest
    static void testCustomerMethods(){
        String payload = '{"balance":"0","company_name":null,"contact":{"company_name":null,"email":"test1@gmail.com","fax":null,"first_name":"Customer","last_name":"test","mobile":"11111111","phone":null,"physical_address1":"street","physical_address2":null,"physical_city":"city","physical_country_id":"US","physical_postcode":"11111","physical_state":"state","physical_suburb":null,"postal_address1":"street","postal_address2":null,"postal_city":"city","postal_country_id":"US","postal_postcode":"11111","postal_state":"state","postal_suburb":null,"twitter":null,"website":null},"contact_first_name":"Customer","contact_last_name":"test","created_at":"2022-08-02T17:25:37Z","custom_field_1":null,"custom_field_2":null,"custom_field_3":null,"custom_field_4":null,"customer_code":"Customer-7RC4","customer_group_id":"06326976-9d65-11ed-fa40-0f5187f9f67b","date_of_birth":null,"deleted_at":null,"do_not_email":true,"email":"test1@gmail.com","enable_loyalty":true,"fax":null,"first_name":"Customer","id":"06326976-9dcb-11ed-fa40-12881f93edd5","last_name":"test","loyalty_balance":"0","mobile":"11111111","note":null,"phone":null,"retailer_id":"06326976-9d65-11ed-fa40-0f5187f82e49","sex":"M","updated_at":"2022-08-02T18:04:36Z","version":23759051889,"year_to_date":"0"}';
        Customer customer =  (Customer) JSON.deserialize(payload, Customer.class);
        Contact con = new Contact(POS_Id__c = customer.Id);
        String erros = LightspeedCustomerRESTService.validateCustomerFields(con);
        Test.startTest();
        LightspeedCustomerRESTService.getCustomer(con);
        Test.stopTest();
    }

    @istest
    static void testCatchMethods(){
        Test.startTest();
        String json = '';
        RestRequest request = new RestRequest();

        // Id siteId = [SELECT GuestUserId, Name,MasterLabel, Subdomain, OptionsRequireHttps, UrlPathPrefix FROM Site WHERE Status = 'Active' AND Name = 'Vend_Customers'].Id;
        // String secureURL = [SELECT SecureURL FROM SiteDetail WHERE DurableId =: siteId].SecureURL;
        // String url = SecureURL + '/services/apexrest/lightSpeedCustomer';
        String url = '/services/apexrest/lightSpeedCustomer';
        System.debug('url: ' + url);

        request.requestUri = url;
        request.httpMethod = 'POST';
        request.addHeader('Content-Type', 'application/json');
        request.addParameter('payload', json);
        RestContext.request = request;

        String id = '';
        LightspeedCustomerRESTService.handleHookCustomers();

        id = LightspeedCustomerRESTService.getCustomer(new Contact(POS_Id__c = '/+]\\'));
        id = LightspeedCustomerRESTService.validateCustomerFields(new Contact());
    }

    private class Customer{
        String id;
        String first_name;
        String last_name;
        String mobile;
        String email;
    }
}