public with sharing class LightspeedCustomerUpdateQueueable implements Queueable,Database.AllowsCallouts{

    private List<Contact> contactsTrigger;
    private List<Contact> contactsToUpdate;
    private Contact contact;

    public LightspeedCustomerUpdateQueueable(List<Contact> contactsTrigger){
        this.contactsTrigger = contactsTrigger;
    }

    public void execute(QueueableContext ctx){
        try {
            updateCustomer();
        } catch (Exception ex) {
            LightspeedPOSErrorHandler.insertErrorLog(ex);
        }
    }

    //Call end point and update the customer into vend
    private void updateCustomer(){
        try {
            this.contactsToUpdate = getContactsToUpdate();
            System.debug('contactsToUpdate: ' + this.contactsToUpdate);
            if(this.contactsToUpdate.size() > 0){
                this.contact = this.contactsToUpdate[0];
                Http http = new Http();
                HttpRequest request = new HttpRequest();
                String namedCredentials = 'Vendhq';
                String endpointPath = 'customers/' + contact.POS_Id__c;
                request.setEndpoint('callout:' + namedCredentials + '/' + endpointPath);
                request.setMethod('PUT');
                request.setHeader('Accept', '*/*');
                request.setHeader('Content-Type', 'application/json');
                String body = getBody();
                System.debug('body: ' + body);
                request.setBody(body);
                HttpResponse response = http.send(request);
                System.debug('status code: ' + response.getStatusCode());
                System.debug('response body: ' + response.getBody());
                this.contactsToUpdate.remove(0);
                System.debug('size: ' +  this.contactsToUpdate.size());

                if(this.contactsToUpdate.size() > 0){
                    if (Limits.getQueueableJobs() < Limits.getLimitQueueableJobs() && Limits.getCallouts() < Limits.getLimitCallouts()) {
                        LightspeedCustomerUpdateQueueable childQueue = new LightspeedCustomerUpdateQueueable(this.contactsToUpdate);
                        if(!Test.isRunningTest()){
                            System.enqueueJob(childQueue);
                        }
                    }else{
                        throw new LightspeedCustomerUpdateException(' JR_POSCustomerInsertQueueable - Limits Reached. Queueable jobs: ' + Limits.getQueueableJobs() + ' of ' + Limits.getLimitQueueableJobs()
                            + '. Callouts: ' + Limits.getCallouts() + ' of ' + Limits.getLimitCallouts());
                    }
                }
            }
        } catch (Exception ex) {
            System.debug('error: ' +ex.getStackTraceString());
            throw ex;
        }
    }

    private List<Contact> getContactsToUpdate(){
        Map<String,Contact> contacts = new Map<String,Contact>();
        for (Contact con : this.contactsTrigger) {
            contacts.put(con.Id, con);
        }

        List<Contact> contactsToUpdate = [SELECT Id, FirstName, LastName, POS_Id__c, Email, Phone,MailingStreet,MailingCity,MailingPostalCode,MailingState FROM Contact WHERE Id IN :contacts.keySet()];
        return contactsToUpdate;
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

    public class LightspeedCustomerUpdateException extends Exception {}
}