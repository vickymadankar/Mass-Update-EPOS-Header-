
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
        List<p66_EPOS__c> eposRecords = new List<p66_EPOS__c>();
        for(Integer i = 0; i < 5; i++) {
            p66_EPOS__c eposRecord = new p66_EPOS__c();
            eposRecord.Name = 'Test Epos ' + i;
            eposRecord.p66_PDL30_Flag__c=false;
            eposRecord.p66_PDL40_Flag__c=false;
            eposRecord.p66_PDL50_Flag__c=false;
            eposRecord.p66_PDL60_Flag__c=false;
            eposRecord.p66_PDL70_Flag__c=false;
            eposRecord.p66_PDL80_Flag__c=false;
            eposRecord.p66_HPS_Notification_Flag__c=false;
            eposRecord.p66_HPS_Notification_Type__c='';
            eposRecords.add(eposRecord);
        }
        insert eposRecords;
        
        String csvData = '';
        for(p66_EPOS__c eposRecord : eposRecords) {
            csvData += eposRecord.Id + ',\n';
        }
        
        Test.startTest();
        String result = EposMassUpdateController.updateEposRecords(csvData, new List<String>{'PDL_30', 'PDL_40','PDL_50','PDL_60','PDL_70','PDL_80'});
        Test.stopTest();
        
        System.assertEquals('Success', result, 'Expected the update operation to be successful');
        
        List<p66_EPOS__c>updatedEposRecords=  [SELECT Id,
                                               p66_HPS_Notification_Flag__c,
                                               p66_HPS_Notification_Type__c,
                                               p66_PDL30_Flag__c,
                                               p66_PDL40_Flag__c,
                                               p66_PDL50_Flag__c,
                                               p66_PDL60_Flag__c,
                                               p66_PDL70_Flag__c,
                                               p66_PDL80_Flag__c
                                               FROM p66_EPOS__c 
                                               WHERE Id IN :eposRecords];
        
        for(p66_EPOS__c eposRecord : updatedEposRecords) {
            System.assertEquals(true,eposRecord.p66_HPS_Notification_Flag__c, 'Expected HPS Notification checkbox to be checked');
            System.assertEquals('Modify',eposRecord.p66_HPS_Notification_Type__c, 'Expected HPS Notification type should be Modify');
            System.assertEquals(true,eposRecord.p66_PDL30_Flag__c, 'Expected PDL30 checkbox to be checked');
            System.assertEquals(true,eposRecord.p66_PDL40_Flag__c, 'Expected PDL40 checkbox to be checked');
            System.assertEquals(true,eposRecord.p66_PDL50_Flag__c, 'Expected PDL40 checkbox to be checked');
            System.assertEquals(true,eposRecord.p66_PDL60_Flag__c, 'Expected PDL40 checkbox to be checked');
            System.assertEquals(true,eposRecord.p66_PDL70_Flag__c, 'Expected PDL40 checkbox to be checked');
            System.assertEquals(true,eposRecord.p66_PDL80_Flag__c, 'Expected PDL40 checkbox to be checked');   
        }
    }
    
}
