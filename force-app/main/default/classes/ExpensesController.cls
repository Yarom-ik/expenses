global with sharing class ExpensesController {

    @AuraEnabled
    global static Contact loginUser(String login, String pass){
       Contact con = [SELECT id, Admin__c, Office__c FROM Contact WHERE Email =:login AND Password__c =:pass LIMIT 1];

        System.debug('Contact = ');

        return con;
        
    }
}
