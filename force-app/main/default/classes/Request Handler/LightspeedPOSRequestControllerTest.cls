@isTest
public class LightspeedPOSRequestControllerTest {
	@isTest
	static void testGetRequests(){
		POS_Request_Log__c requestLog = new POS_Request_Log__c(
						Name = 'Test Request Log',
						Module__c = 'Sale',
						POS_Payload__c = '{"test":"test"}'
						);
			insert requestLog;

		LightspeedPOSRequestHandlerController.getRequests();
	}
}