public with sharing class AdminController {

     public class MonthlyExpense{       
        @AuraEnabled
        public String office;   
        @AuraEnabled
        public Decimal balanceNow;
        @AuraEnabled
        public Decimal monthlyAverage;   
        @AuraEnabled
        public Decimal totalAmount;  
        @AuraEnabled
        public Decimal summ;      
        @AuraEnabled
        public List<MonthlyExpenseWrapper> monthlyExpenseList;
    }

    public class MonthlyExpenseWrapper implements Comparable {

        @AuraEnabled
        public MonthlyExpense__c oppy;    
        // Constructor
        public MonthlyExpenseWrapper(MonthlyExpense__c op) {
            oppy = op;
        }    
        // Compare opportunities based on the opportunity amount.
        public Integer compareTo(Object compareTo) {
            // Cast argument to OpportunityWrapper
            MonthlyExpenseWrapper compareToOppy = (MonthlyExpenseWrapper)compareTo;        
            // The return value of 0 indicates that both elements are equal.
            Integer returnValue = 0;
            if (oppy.MonthDate__c > compareToOppy.oppy.MonthDate__c) {
                // Set return value to a positive value.
                returnValue = 1;
            } else if (oppy.MonthDate__c < compareToOppy.oppy.MonthDate__c) {
                // Set return value to a negative value.
                returnValue = -1;
            }        
            return returnValue;       
        }
}

    @AuraEnabled
    public static List<MonthlyExpense> getMouthlyExpense(Integer selectedDate){

        System.debug('getMouthlyExpenseDATEadmin= ' + selectedDate);

        List<String> contactOfficeList = new List<String>();
        for(AggregateResult ar : [SELECT Office__c FROM Contact WHERE admin__c = false AND Office__c != null GROUP BY Office__c ORDER BY Office__c ASC]){
            contactOfficeList.add((String) ar.get('Office__c'));    
        }
        System.debug('contactOfficeList ' + contactOfficeList);    

        List<Contact> monthlylist = [SELECT id, office__c, (SELECT id, balance__c, MonthDate__c, SpentAmount__c, Reminder__c FROM MonthlyExpenses__r WHERE CALENDAR_YEAR(MonthDate__c) =:selectedDate) FROM Contact WHERE admin__c = false AND office__c IN :contactOfficeList];   
        System.debug('monthlylist= ' + monthlylist);
        System.debug('monthlylist[0]= ' + monthlylist[0].MonthlyExpenses__r[0].balance__c);
        

        List<MonthlyExpense> monthlyExpenseOfficeList = new List<MonthlyExpense>();

        

        for (Contact c:monthlylist ){
            MonthlyExpenseWrapper[] oppyList = new List<MonthlyExpenseWrapper>(); 
            MonthlyExpense monthlyExpense = new MonthlyExpense();
            monthlyExpense.balanceNow = 0;
            monthlyExpense.totalAmount = 0; 
            monthlyExpense.monthlyAverage = 0;
                        
            System.debug('office= ' + c.Office__c);
            monthlyExpense.office = c.Office__c;
            for(MonthlyExpense__c details:c.MonthlyExpenses__r){
                System.debug('mas= ' + details.balance__c);
                System.debug('MonthDate__c= ' + details.MonthDate__c);
                monthlyExpense.balanceNow += details.Reminder__c;
                monthlyExpense.totalAmount += details.SpentAmount__c;
                oppyList.add(new MonthlyExpenseWrapper(details));
            }
            monthlyExpense.monthlyExpenseList = oppyList;  
            monthlyExpenseOfficeList.add(monthlyExpense);
        }

          
        System.debug('monthlyExpenseList= ' + monthlyExpenseOfficeList);

        return monthlyExpenseOfficeList;        
    }
    
}