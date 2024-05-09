/**
* @Description       : This class updates the specific EPOS records after accepting PDL flags and EPOS Ids 
*                      from P66MassUpdateEpos LWC component.
* @Coverage          : Test.cls | @CC-92%
* @Author            : Vicky Madankar
* @Created Date      : 30-04-2024
* @last modified by  : Vicky.Madankar@Perficient.com
* Modifications Log
* Ver   Date         Author                                   Modification
* 1.0   05-08-2023   Vicky.Madankar@Perficient.com            Initial Version | Story Number |37850 
**/

public with sharing class EposMassUpdateController {
    
    @AuraEnabled(cacheable=false)
    public static String updateEposRecords(String csvData, List<String> selectedCheckboxes) {   
        try {	
            List<String> recordIdsToUpdate = csvData.split('\n');//Apex--lwc accepts header and other columns- replaced , with \n
            
            List<EPOS__c> eposRecords = [SELECT Id,
                                             HPS_Notification_Flag__c,
                                             HPS_Notification_Type__c,
                                             PDL30_Flag__c,
                                             PDL40_Flag__c,
                                             PDL50_Flag__c,
                                             PDL60_Flag__c,
                                             PDL70_Flag__c,
                                             PDL80_Flag__c
                                             FROM EPOS__c
                                             WHERE Id 
                                             IN :recordIdsToUpdate];
            
            for (EPOS__c record : eposRecords) {
                record.HPS_Notification_Flag__c = true;
                record.HPS_Notification_Type__c='Modify';
                
                for(String checkboxValue: selectedCheckboxes){
                    if(checkboxValue=='PDL_30'){
                        record.PDL30_Flag__c=true;
                    }else if(checkboxValue=='PDL_40'){
                        record.PDL40_Flag__c=true;
                    } else if(checkboxValue=='PDL_50'){
                        record.PDL50_Flag__c=true;
                    } else if(checkboxValue=='PDL_60'){
                        record.PDL60_Flag__c=true;
                    } else if(checkboxValue=='PDL_70'){
                        record.PDL70_Flag__c=true;
                    } else if(checkboxValue=='PDL_80'){
                        record.PDL80_Flag__c=true;
                    }	
                }
            }
            
            update eposRecords;
            return 'Success';
        } catch (Exception e) {
            return 'Error: ' + e.getMessage();
        }
    }
}
