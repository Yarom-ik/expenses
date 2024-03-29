public with sharing class AdminController {

    public class MonthlyExpense{       
        @AuraEnabled
        public List<cls_office> officeList; 
        @AuraEnabled
        public Decimal summ;     
        @AuraEnabled
        public List<List<String>> dataList;
    } 

    public class cls_office{
        @AuraEnabled
        public String officeName;
        @AuraEnabled
        public String id;
        @AuraEnabled
        public Decimal totalAmount;
        @AuraEnabled
        public Decimal monthlyAverage;
        @AuraEnabled
        public Decimal balanceNow;
        @AuraEnabled
        public Decimal totalSumm;
    }

    @AuraEnabled
    public static MonthlyExpense getMouthlyExpense(Integer selectedDate){

        List<String> contactOfficeList = new List<String>();
        for(AggregateResult ar : [SELECT Office__c 
                                    FROM Contact 
                                    WHERE admin__c = false AND Office__c != null 
                                    GROUP BY Office__c 
                                    ORDER BY Office__c ASC]){
            contactOfficeList.add((String) ar.get('Office__c'));    
        }

        List<Contact> monthlylist = [SELECT id, office__c, 
                                    (SELECT id, balance__c, MonthDate__c, SpentAmount__c, Reminder__c 
                                    FROM MonthlyExpenses__r 
                                    WHERE CALENDAR_YEAR(MonthDate__c) =:selectedDate) 
                                    FROM Contact 
                                    WHERE admin__c = false AND office__c IN :contactOfficeList 
                                    ORDER BY office__c ASC];   
        MonthlyExpense monthlyExpenseOfficeList = new MonthlyExpense();
        List<List<String>> dataList = new List<List<String>>();

        for(Integer i = 1; i<=12; i++){ 
            DateTime dt = DateTime.newInstance(selectedDate, i, 01);                                
            dataList.add(new List<String>());
            dataList.get(i-1).add(string.valueof(dt.format('MMMM')));                      
        }    
        
        MonthlyExpense monthlyExpense = new MonthlyExpense();
        Integer y = 0;
        List<cls_office> officeList = new List<cls_office>();
        Decimal totalSumm = 0;
        for (Contact c:monthlylist ){                   
            cls_office cls = new cls_office();
            cls.officeName = c.Office__c;
            cls.id = c.Id;
            cls.totalAmount = 0;
            cls.balanceNow = 0;
            for(Integer i = 0; i<12; i++){ 
                for(MonthlyExpense__c details:c.MonthlyExpenses__r){                 
                    if(Date.newInstance(selectedDate, i + 1, 01) == details.MonthDate__c){
                        cls.balanceNow += details.Reminder__c;
                        cls.totalAmount += details.SpentAmount__c;
                        dataList.get(i).add(string.valueof(details.SpentAmount__c));
                    }
                }
                if(dataList[i].size() == y+1){
                    dataList.get(i).add('0');
                }
            }
            y++;
            cls.monthlyAverage = cls.totalAmount/2;
            totalSumm += cls.totalAmount;
            officeList.add(cls);
        }

        for(Integer i = 0; i < 12; i++){
            Decimal summ = 0;
            for(Integer n = 1; n <= monthlylist.size(); n++){
                summ += decimal.valueOf(dataList[i][n]);                
            }
            dataList[i].add(string.valueof(summ));
        }

        //load data previous year
        Integer selectedDatePr = selectedDate - 1;
        List<Contact> monthlylistPrevousYear = [SELECT id, office__c, (SELECT id, balance__c, MonthDate__c, SpentAmount__c, Reminder__c FROM MonthlyExpenses__r WHERE CALENDAR_YEAR(MonthDate__c) =:selectedDatePr) FROM Contact WHERE admin__c = false AND office__c IN :contactOfficeList ORDER BY office__c ASC];   
        Integer i = 0; 
        for (Contact c:monthlylistPrevousYear){                          
            Decimal balansePrevious = 0;
            for(MonthlyExpense__c details:c.MonthlyExpenses__r){   
                balansePrevious += details.Reminder__c;                
            }           
            officeList[i].balanceNow += balansePrevious;
            i++;                        
        }
        monthlyExpense.dataList = dataList;
        monthlyExpense.officeList = officeList;
        monthlyExpense.summ = totalSumm;      

        return monthlyExpense;      
    }
    
}