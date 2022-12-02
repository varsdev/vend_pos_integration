@isTest
public class LightspeedPOSErrorHandlerTest{

    @istest
    static void testInsertErrorLog(){
        LightspeedPOSErrorHandler.insertErrorLog(new LightspeedErrorException());
    }

    public class LightspeedErrorException extends Exception {}
}