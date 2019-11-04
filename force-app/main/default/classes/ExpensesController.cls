@RestResource(urlMapping='/Account/*')
global with sharing class ExpensesController {
    
    //test
    //@HttpGet
    // global static Account doGet() {
    // RestRequest req = RestContext.request;
    // RestResponse res = RestContext.response;
    //String accountId = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1);
    //  Account result = [SELECT Id, Name, Phone, Website FROM Account LIMIT 1];
    //  return result;
    //}
    
    @HttpPOST
    @AuraEnabled(cacheable=true)
    global static Contact loginUser(String login, String pass){
        Contact con = new Contact(); 
        con = [SELECT id, Admin__c, Office__c FROM Contact WHERE Email =:login AND Password__c =:pass LIMIT 1];
   
        return con;
        
    }
    
    public class MonthlyExpense{
        @AuraEnabled
        public Decimal Balance;
        @AuraEnabled
        public Decimal totalAmount;
        @AuraEnabled
        public Decimal totalIncome;
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
    public static MonthlyExpense getMouthlyExpense(String conId, Integer selectedDate){
        
        List<MonthlyExpense__c> monthlylist = [SELECT Balance__c, MonthDate__c, SpentAmount__c, Reminder__c FROM MonthlyExpense__c WHERE Keeper__c =:conId AND CALENDAR_YEAR(MonthDate__c) =: selectedDate];   
        MonthlyExpenseWrapper[] oppyList = new List<MonthlyExpenseWrapper>();         
        
        MonthlyExpense monthlyExpense = new MonthlyExpense();
        
        monthlyExpense.totalAmount = 0;
        monthlyExpense.totalIncome = 0;
        monthlyExpense.Balance = 0;
        
        List<MonthlyExpense__c> mes = new List<MonthlyExpense__c>();
        for(MonthlyExpense__c mx: monthlylist){
            monthlyExpense.totalAmount += mx.SpentAmount__c; 
            monthlyExpense.totalIncome += mx.Balance__c;
            monthlyExpense.Balance += mx.Reminder__c;
            MonthlyExpense__c m = new MonthlyExpense__c();
            m.MonthDate__c = mx.MonthDate__c;
            mes.add(m);
            oppyList.add(new MonthlyExpenseWrapper(mx));
        }        
        
        for(Integer i = 1; i<=12; i++){ 
            Date dt = Date.newInstance(selectedDate, i, 01);                
            MonthlyExpense__c monthly = new MonthlyExpense__c(); 
            monthly.MonthDate__c = dt;
            if(!mes.contains(monthly)){                                 
                oppyList.add(new MonthlyExpenseWrapper(monthly));
            }                       
        }
        oppyList.sort();
        monthlyExpense.monthlyExpenseList = oppyList; 
        return monthlyExpense;        
    }
    
    public class Expenses{
        @AuraEnabled
        public date cardDateUnique;
        @AuraEnabled
        public Decimal totalSum;
        @AuraEnabled
        public List<ExpenseCard__c> expenseCardList;
    }
    
    @AuraEnabled
    public static  List<Expenses> getExpenseCard(Date selectedDate, String conId){
        
        List<Expenses> m1 = new List<Expenses>();
        Set<Date> dates = new Set<Date>();
        for(AggregateResult ar : [SELECT CardDate__c FROM ExpenseCard__c WHERE MonthlyExpense__r.Keeper__c =:conId AND MonthlyExpense__r.MonthDate__c =: selectedDate GROUP BY CardDate__c ORDER BY CardDate__c ASC]){
            dates.add((Date) ar.get('CardDate__c'));    
        }
        if(dates == null || dates.isEmpty()){
            return null;
        }
        
        ExpenseCard__c[] expenseCards = [SELECT CardDate__c, Description__c, Amount__c FROM ExpenseCard__c WHERE CardKeeper__c =:conId AND CardDate__c IN :dates ORDER BY CardDate__c ASC];
        if(expenseCards != null){
            for (Date dd : dates){
                List<ExpenseCard__c> ex = new List<ExpenseCard__c>();
                Decimal summ = 0;
                Expenses exp = new Expenses();
                for(ExpenseCard__c xx : expenseCards){        
                    if(dd == xx.CardDate__c){
                        ex.add(xx);
                        summ = summ + xx.Amount__c;
                    }        
                }
                exp.cardDateUnique = dd;
                exp.totalSum = summ;
                exp.expenseCardList = ex;
                m1.add(exp);
            }
        } else {
            return null;
        }
        return m1;        
    }
    
    @AuraEnabled
    public static string saveExpenseCard(ExpenseCard__c expenseCard){
        try {
            insert expenseCard;
        } catch (DmlException e) {
            
        }
        return 'ok';
    }
    
    @AuraEnabled
    public static void deleteExpenseCard(String expenseCardId){
        try {
            delete [SELECT id FROM ExpenseCard__c WHERE id =: expenseCardId];
        } catch (DmlException e) {
            
        } 
    }
    
    @AuraEnabled
    public static void addBalance(Date selectedDate, String conId, Integer addBalance){
        List<MonthlyExpense__c> MXList = [SELECT Balance__c FROM MonthlyExpense__c WHERE MonthDate__c =:selectedDate AND Keeper__c =:conId LIMIT 1];
        if(MXList.size() != 0){
            MXList[0].Balance__c += addBalance;
            update MXList; 
        }
    }
    
}