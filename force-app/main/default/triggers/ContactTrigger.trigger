trigger ContactTrigger on Contact (after insert,after update) {
    Boolean integrationStatus = LightspeedPOSSyncSettingsController.getSyncStatusIntegration();
    String customerSetting = LightspeedPOSSyncSettingsController.getSyncCustomerSetting();
    if (integrationStatus && (customerSetting == 'Dual Sync' || customerSetting == 'Salesforce to Vend') ) {
        if(Trigger.isUpdate){
            System.enqueueJob(new LightspeedCustomerUpdateQueueable(Trigger.new));
        }else if(Trigger.isInsert){
            System.enqueueJob(new LightspeedCustomerInsertQueueable(Trigger.new));
        }
    }
}