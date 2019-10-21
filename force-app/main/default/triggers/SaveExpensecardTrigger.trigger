trigger SaveExpensecardTrigger on ExpenseCard__c (before insert) {
  
    ExpenseCard__c exD = Trigger.New[0];
    Date dateMow = (Date.newInstance(exD.CardDate__c.year(), exD.CardDate__c.month(), 1));

    MonthlyExpense__c[] mx = [SELECT Id, MonthDate__c FROM MonthlyExpense__c WHERE Keeper__c =:exD.CardKeeper__c AND MonthDate__c =:dateMow LIMIT 1];

    if(mx.size() > 0){
        if(dateMow == mx[0].MonthDate__c){
            exD.MonthlyExpense__c = mx[0].Id;
        }
    } else{
        MonthlyExpense__c newMx = new MonthlyExpense__c();                
        newMx.MonthDate__c = dateMow;
        newMx.Keeper__c = exD.CardKeeper__c;
        insert newMx;   
        exD.MonthlyExpense__c = newMx.Id;    
    }  
}