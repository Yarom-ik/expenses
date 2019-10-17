global with sharing class ExpensesController {

    @AuraEnabled
    global static Contact loginUser(String login, String pass){
       Contact con = [SELECT id, Admin__c, Office__c FROM Contact WHERE Email =:login AND Password__c =:pass LIMIT 1];

        System.debug('Contact = ');

        return con;
        
    }

    @AuraEnabled
    public static MonthlyExpense__c getMouthlyExpense(String conId, String month, String year){

        Date myDate = Date.newInstance(2019, 12, 10);                
        MonthlyExpense__c monthlyExpense = [SELECT Balance__c, MonthDate__c FROM MonthlyExpense__c WHERE Keeper__c =:conId LIMIT 1];            
        System.debug(' MonthlyExpense__c ' + monthlyExpense);

        return monthlyExpense;
        
    }

    @AuraEnabled
    public static   Map<Date, List<ExpenseCard__c>> getExpenseCard(){

        Map<Date, List<ExpenseCard__c>> m1 = new Map<Date, List<ExpenseCard__c>>();

        Set<Date> dates = new Set<Date>();
        for(AggregateResult ar : [SELECT CardDate__c FROM ExpenseCard__c GROUP BY CardDate__c]){
            dates.add((Date) ar.get('CardDate__c'));    
        }
        ExpenseCard__c[] expenseCards = [SELECT CardDate__c, Description__c, Amount__c FROM ExpenseCard__c WHERE CardDate__c IN :dates];

        for (Date dd : dates){
                List<ExpenseCard__c> ex = new List<ExpenseCard__c>();
            for(ExpenseCard__c xx : expenseCards){
                if(dd == xx.CardDate__c){
                    ex.add(xx);
                }
            }
                m1.put(dd,ex);
        }

        // Map<Date, Map<Decimal, List<ExpenseCard__c>>> m1 = new Map<Date, Map<Decimal, List<ExpenseCard__c>>>();

        //     Set<Date> dates = new Set<Date>();
        //     for(AggregateResult ar : [SELECT CardDate__c FROM ExpenseCard__c GROUP BY CardDate__c]){
        //         dates.add((Date) ar.get('CardDate__c'));    
        //     }
        //     ExpenseCard__c[] expenseCards = [SELECT CardDate__c, Description__c, Amount__c FROM ExpenseCard__c WHERE CardDate__c IN :dates];

        //     for (Date dd : dates){
        //             Map<Decimal, List<ExpenseCard__c>> ex = new Map<Decimal, List<ExpenseCard__c>>();
        //             Decimal summ = 0;
        //         List<ExpenseCard__c> listEx = new List<ExpenseCard__c>();
        //         for(ExpenseCard__c xx : expenseCards){
                    
        //             if(dd == xx.CardDate__c){
        //                 listEx.add(xx);
        //                 summ = summ + xx.Amount__c;
        //             }        
        //         }
        //         ex.put(summ,listEx);
        //             m1.put(dd,ex);
        //     }

	
       System.debug('m1 ' + m1); 


        return m1;
        
    }

}