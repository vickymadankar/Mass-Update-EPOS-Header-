
/**
* @Description       : Test class for EposMassUpdateController
* @Coverage          : @CC-92%
* @Author            : Vicky Madankar
* @Created Date      : 8-05-2024
* @last modified by  : Vicky.Madankar@Perficient.com
* Modifications Log
* Ver   Date         Author                                   Modification
* 1.0   05-08-2023   Vicky.Madankar@Perficient.com            Initial Version | Story Number |37850 
**/

@isTest
public class Test_EposMassUpdateController {
    
    @isTest
    static void testUpdateEposRecords() {
        List<EPOS__c> eposRecords = new List<EPOS__c>();
        for(Integer i = 0; i < 5; i++) {
            EPOS__c eposRecord = new EPOS__c();
            eposRecord.Name = 'Test Epos ' + i;
            eposRecord.PDL30_Flag__c=false;
            eposRecord.PDL40_Flag__c=false;
            eposRecord.PDL50_Flag__c=false;
            eposRecord.PDL60_Flag__c=false;
            eposRecord.PDL70_Flag__c=false;
            eposRecord.PDL80_Flag__c=false;
            eposRecord.HPS_Notification_Flag__c=false;
            eposRecord.HPS_Notification_Type__c='';
            eposRecords.add(eposRecord);
        }
        insert eposRecords;
        
        String csvData = '';
        for(EPOS__c eposRecord : eposRecords) {
            csvData += eposRecord.Id + ',\n';
        }
        
        Test.startTest();
        String result = EposMassUpdateController.updateEposRecords(csvData, new List<String>{'PDL_30', 'PDL_40','PDL_50','PDL_60','PDL_70','PDL_80'});
        Test.stopTest();
        
        System.assertEquals('Success', result, 'Expected the update operation to be successful');
        
        List<EPOS__c>updatedEposRecords=  [SELECT Id,
                                               HPS_Notification_Flag__c,
                                               HPS_Notification_Type__c,
                                               PDL30_Flag__c,
                                               PDL40_Flag__c,
                                               PDL50_Flag__c,
                                               PDL60_Flag__c,
                                               PDL70_Flag__c,
                                               PDL80_Flag__c
                                               FROM EPOS__c 
                                               WHERE Id IN :eposRecords];
        
        for(EPOS__c eposRecord : updatedEposRecords) {
            System.assertEquals(true,eposRecord.HPS_Notification_Flag__c, 'Expected HPS Notification checkbox to be checked');
            System.assertEquals('Modify',eposRecord.HPS_Notification_Type__c, 'Expected HPS Notification type should be Modify');
            System.assertEquals(true,eposRecord.PDL30_Flag__c, 'Expected PDL30 checkbox to be checked');
            System.assertEquals(true,eposRecord.PDL40_Flag__c, 'Expected PDL40 checkbox to be checked');
            System.assertEquals(true,eposRecord.PDL50_Flag__c, 'Expected PDL40 checkbox to be checked');
            System.assertEquals(true,eposRecord.PDL60_Flag__c, 'Expected PDL40 checkbox to be checked');
            System.assertEquals(true,eposRecord.PDL70_Flag__c, 'Expected PDL40 checkbox to be checked');
            System.assertEquals(true,eposRecord.PDL80_Flag__c, 'Expected PDL40 checkbox to be checked');   
        }
    }
    
}
