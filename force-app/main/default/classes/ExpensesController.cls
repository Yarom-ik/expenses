global with sharing class ExpensesController {

    @AuraEnabled
    global static Contact loginUser(String login, String pass){
       Contact con = [SELECT id, Admin__c, Office__c FROM Contact WHERE Email =:login AND Password__c =:pass LIMIT 1];

        System.debug('Contact = ');

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
        public List<MonthlyExpense__c> monthlyExpenseList;
    }

    @AuraEnabled
    public static MonthlyExpense getMouthlyExpense(String conId, String month, String year){

        Date myDate = Date.newInstance(2019, 01, 13);                
        List<MonthlyExpense__c> monthlylist = [SELECT Balance__c, MonthDate__c, SpentAmount__c, Reminder__c FROM MonthlyExpense__c WHERE Keeper__c =:conId LIMIT 1];            

        // List<MonthlyExpense> monthlyExpenseL = new List<MonthlyExpense>();

        MonthlyExpense monthlyExpense = new MonthlyExpense();
        monthlyExpense.Balance = monthlylist[0].Balance__c;
        
        for(MonthlyExpense__c mx: monthlylist){
            monthlyExpense.totalAmount =+ mx.SpentAmount__c; 
            monthlyExpense.totalIncome =+ mx.Reminder__c; 
            // DateTime dt = DateTime.now();
            // Date monthName = dt.format('MMMMM');
            // mx.MonthDate__c = monthName;
            
        }  
        monthlyExpense.monthlyExpenseList = monthlylist;
        // monthlyExpenseL.add(monthlyExpense);
        
        
        
        System.debug(' MonthlyExpense__c ' + monthlyExpense);

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
    public static  List<Expenses> getExpenseCard(){

        List<Expenses> m1 = new List<Expenses>();

        Set<Date> dates = new Set<Date>();
        for(AggregateResult ar : [SELECT CardDate__c FROM ExpenseCard__c GROUP BY CardDate__c]){
            dates.add((Date) ar.get('CardDate__c'));    
        }
        ExpenseCard__c[] expenseCards = [SELECT CardDate__c, Description__c, Amount__c FROM ExpenseCard__c WHERE CardDate__c IN :dates];

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
	
       System.debug('m1 ' + m1); 


        return m1;
        
    }

}