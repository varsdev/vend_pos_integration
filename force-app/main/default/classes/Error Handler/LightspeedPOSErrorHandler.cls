public class LightspeedPOSErrorHandler{

	public static void insertErrorLog(Exception ex) {
		try {
			String userId = UserInfo.getUserId();
			POS_Error_Log__c error = new POS_Error_Log__c(
				User_Id__c = userId,
				name = ex.getMessage().left(80),
				Exception_Type_Name__c = ex.getTypeName(),
				Error_Line__c = 'Line: ' + ex.getLineNumber(),
				StackTrace__c = ex.getMessage() + ' , ' + ex.getStackTraceString()
			);
			insert error;
		} catch(Exception e) {
			insertErrorLog(e);
		}
	}
}