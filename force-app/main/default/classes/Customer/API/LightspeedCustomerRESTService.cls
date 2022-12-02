/* * * * * * * * * * * * * * * * * * * * * *
Author: Axel Chaves
Description: Class to Handle weebhooks of sale from POS
Date: 2022 Sep 26
* * * * * * * * * * * * * * * * * * * * * */
@RestResource(urlMapping='/lightSpeedCustomer')
global without sharing class LightspeedCustomerRESTService{

    @HttpPost
    global static void handleHookCustomers(){
        try {
            Boolean integrationStatus = LightspeedPOSSyncSettingsController.getSyncStatusIntegration();
            String customerSetting = LightspeedPOSSyncSettingsController.getSyncCustomerSetting();
            if (integrationStatus && (customerSetting == 'Dual Sync' || customerSetting == 'Vend to Salesforce')) {
                RestRequest req = RestContext.request;
                String payload = String.valueOf(req.params.get('payload'));
                String logId = LightspeedPOSRequestHandler.insertRequest(payload, 'Customer');
                if(logId != null){
                    RestResponse res = RestContext.response;
                    res.addHeader('Content-Type', 'application/json');
                    res.statusCode = 201;
                    res.responseBody = Blob.valueOf('{ "Log Id" : "' + logId + '"}');
                }
                Customer customer = (Customer) JSON.deserialize(payload, Customer.class);
                String id = verifyCustomerInSalesforce(customer);
            }
        } catch (Exception ex) {
            LightspeedPOSErrorHandler.insertErrorLog(ex);
        }
    }

    private static String verifyCustomerInSalesforce(Customer customer){
        try {
            Contact con = new Contact();
            con.Firstname = customer.first_name;
            con.LastName = customer.last_name;
            con.Phone = customer.mobile;
            con.Email = customer.email;
            con.POS_Id__c = customer.id;
            con.MailingStreet = customer.contact.physical_address1;
            con.MailingCity = customer.contact.postal_city;
            con.MailingPostalCode = customer.contact.postal_postcode;
            con.MailingState = customer.contact.physical_state;

            String errors = validateCustomerFields(con);
            if(errors.length() > 0){
                throw new LightspeedCustomerException(errors);
            }

            List<Contact> contact = getContactByIdOrEmail(con);

            //Update or insert
            if(contact.Size() > 0){
                contact[0].POS_Id__c = customer.Id;
                update contact;
                return contact[0].Id;
            }else{
                upsert con POS_Id__c;
                return con.Id;
            }
        } catch (Exception ex) {
            throw ex;
        }
    }

    public static List<Contact> getContactByIdOrEmail(Contact con){
        //Looking dup customer
        List<Contact> contacts;
        if(con.Email == null){
            contacts= [SELECT Id, FirstName, LastName, POS_Id__c, Email, Phone,MailingStreet,MailingCity,MailingPostalCode,MailingState FROM Contact WHERE FirstName =: con.FirstName AND LastName =:con.LastName AND POS_Id__c = null LIMIT 1];

        }else{
            contacts= [SELECT Id, FirstName, LastName, POS_Id__c, Email, Phone,MailingStreet,MailingCity,MailingPostalCode,MailingState FROM Contact WHERE Email =: con.Email and POS_Id__c = null LIMIT 1];

        }
        return contacts;
    }

    //Get the contact if exists in Salesforce
    public static String getCustomer(Contact con){
        try {
            List<Contact> contact = [SELECT Id, FirstName, LastName, Phone, Email,POS_Id__c FROM Contact WHERE POS_Id__c =: con.POS_Id__c LIMIT 1];
            if(contact.Size() > 0){
                return contact[0].id;
            }
            return null;
        } catch (Exception ex) {
            throw ex;
        }
    }

    //Validate the fields of the contact
    public static String validateCustomerFields(Contact con){
        String errors = '';
        if(String.isBlank(con.Firstname)){
            errors += 'First name can not be blank \n';
        }
        if(String.isBlank(con.Lastname)){
            errors += 'Last name can not be blank \n';
        }
        if(String.isBlank(con.POS_Id__c)){
            errors += 'POS Customer Id  can not be blank \n';
        }
        return errors;
    }

    private class Customer{
        String id;
        String first_name;
        String last_name;
        String mobile;
        String email;
        cls_contact contact;
    }

    private class cls_contact{
        String physical_address1;
        String postal_city;
        String postal_postcode;
        String physical_state;
    }

    public class LightspeedCustomerException extends Exception {}
}