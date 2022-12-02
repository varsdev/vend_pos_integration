public with sharing class LightspeedCustomerInsertQueueable implements Queueable,Database.AllowsCallouts{

    private List<Contact> contacts;
    private List<Contact> contactsToInsert;
    private String endPointPath;
    private Contact contact;

    public LightspeedCustomerInsertQueueable(List<Contact> contacts){
        this.contacts = contacts;
        this.endPointPath = 'customers';
    }

    public void execute(QueueableContext ctx){
        try {
            insertCustomer();
        } catch (Exception ex) {
            LightspeedPOSErrorHandler.insertErrorLog(ex);
        }
    }

    //Call end point and insert the customer into vend
    private void insertCustomer(){
        try {
            //Can't update records from trigger 
            this.contactsToInsert = getContactsToInsert();
            System.debug('contactsToInsert: ' + this.contactsToInsert);
            if(this.contactsToInsert.size() > 0){
                System.debug('Size:' + contactsToInsert.size());
                this.contact = this.contactsToInsert[0];
                Http http = new Http();
                HttpRequest request = new HttpRequest();
                String namedCredentials = 'Vendhq';
                request.setEndpoint('callout:' + namedCredentials + '/' + endpointPath);
                request.setMethod('POST');
                request.setHeader('Accept', '*/*');
                request.setHeader('Content-Type', 'application/json');
                String body = getBody();
                System.debug('body: ' + body);
                request.setBody(body);
                HttpResponse response = http.send(request);
                System.debug('status code: ' + response.getStatusCode());
                System.debug('response body: ' + response.getBody());

                if(response.getStatusCode() > 200 && response.getStatusCode() < 300){
                    JSONParser parser = JSON.createParser(response.getBody());
                    while (parser.nextToken() != null) {
                        if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == 'id')) {
                            parser.nextToken();
                            contact.POS_Id__c=  parser.getText();
                        }
                    }
                }
                System.debug('Contact: ' + contact);
                update contact;
                this.contactsToInsert.remove(0);
                System.debug('Customer to insert:' + this.contactsToInsert.size());
                if(contactsToInsert.size() > 0){
                    if (Limits.getQueueableJobs() < Limits.getLimitQueueableJobs() && Limits.getCallouts() < Limits.getLimitCallouts()) {
                        LightspeedCustomerInsertQueueable childQueue = new LightspeedCustomerInsertQueueable(this.contactsToInsert);
                        if(!Test.isRunningTest()){
                            System.enqueueJob(childQueue);
                        }
                    }else{
                        throw new LightspeedCustomerInsertException(' JR_POSCustomerInsertQueueable - Limits Reached. Queueable jobs: ' + Limits.getQueueableJobs() + ' of ' + Limits.getLimitQueueableJobs()
                            + '. Callouts: ' + Limits.getCallouts() + ' of ' + Limits.getLimitCallouts());
                    }
                }
            }
        } catch (Exception ex) {
            throw ex;
        }
    }

    private List<Contact> getContactsToInsert(){
        Map<String,Contact> contacts = new Map<String,Contact>();
        for (Contact con : this.contacts) {
            contacts.put(con.Id, con);
        }

        List<Contact> contactsToInsert = [SELECT Id, FirstName, LastName, POS_Id__c, Email, Phone,MailingStreet,MailingCity,MailingPostalCode,MailingState FROM Contact WHERE Id IN :contacts.keySet()];
        return contactsToInsert;
    }

    private String getBody(){
        String body = '{"do_not_email": "false" ';
        if(!String.isBlank(contact.FirstName) && contact.FirstName != null){
            body += ',"first_name":"' + contact.FirstName + '"';
        }
        if(!String.isBlank(contact.LastName) && contact.LastName != null){
            body += ',"last_name":"' + contact.LastName + '"';
        }
        if(!String.isBlank(contact.Email) && contact.Email != null){
            body += ',"email":"' + contact.Email + '"';
        }
        if(!String.isBlank(contact.Phone) && contact.Phone != null){
            body += ',"phone":"' + contact.Phone + '"';
        }
        if(!String.isBlank(contact.MailingStreet) && contact.MailingStreet != null){
            body += ',"physical_address_1":"' + contact.MailingStreet + '"';
        }
        if(!String.isBlank(contact.MailingCity) && contact.MailingCity != null){
            body += ',"postal_city":"' + contact.MailingCity + '"';
        }
        if(!String.isBlank(contact.MailingPostalCode) && contact.MailingPostalCode != null){
            body += ',"postal_postcode":"' + contact.MailingPostalCode + '"';
        }
        if(!String.isBlank(contact.MailingState) && contact.MailingState != null){
            body += ',"physical_state":"' + contact.MailingState + '"';
        }

        body += '}';
        return body;
    }

    public class LightspeedCustomerInsertException extends Exception {}
}