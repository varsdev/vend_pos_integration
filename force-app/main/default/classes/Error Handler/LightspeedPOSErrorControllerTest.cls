@isTest
public class LightspeedPOSErrorControllerTest {
    @isTest
    static void testGetErrors(){
        POS_Error_Log__c errorLog = new POS_Error_Log__c(
					Name = 'Test Error Log',
					Exception_Type_Name__c = 'System.NullPointerException',
					StackTrace__c = 'null input to JSON parser , (System Code) Class.LightspeedSaleRESTService.handleHookSales: line 27, column 1',
                    Error_Line__c = 'Line: 15'
					);
		insert errorLog;

        LightspeedPOSErrorHandlerController.GetErrors();
    }
}