@isTest
public class LightspeedCustomerInsertQueueableTest{

    static HttpResponse response;
    static String successData= 'Success';
    static String failureData= 'Faied';

    public class MockSuccess implements HttpcalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
                    response = new HttpResponse();
                    response.setbody(successData);
                    response.setstatuscode(200);
                    return response;
            }
    }

    static testmethod void testForSuccess(){
        List<Contact> contacts = new List<Contact>();
        List<Opportunity> opportunities = new List<Opportunity>();
        for (Integer i = 0; i < 5; i++) {
            Contact con = new Contact();
            con.FirstName = 'Test ' + i;
            con.Lastname = 'Test ' + i;
            con.Email = 'Test' + i + '@gmail.com';
            con.Phone = '1234567890';
            con.MailingStreet = 'Test ' + i;
            con.MailingCity = 'Test ' + i;
            con.MailingPostalCode = '12345';
            con.MailingState = 'Test ' + i;
            contacts.add(con);
        }
        insert contacts;

        for (Integer i = 0; i < contacts.size(); i++) {
            Opportunity op = new Opportunity(
                Name = 'test' + i,
                StageName = 'Closed Won',
                Amount = 100,
                CloseDate = System.today()
            );
            opportunities.add(op);
        }
        insert opportunities;

        Test.setMock(HttpCalloutMock.class, new MockSuccess());
        Test.startTest();
        System.enqueueJob( new LightspeedCustomerInsertQueueable(contacts));
        System.debug('Response::'+response);
        Test.stopTest();
    }
}