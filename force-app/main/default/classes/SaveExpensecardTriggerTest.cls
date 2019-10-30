@isTest
public class SaveExpensecardTriggerTest {
    
    @isTest
    public static void saveExpenseCardTest(){
        
        Contact con = new Contact(Admin__c = false,
                                 Office__c = 'office 1',
                                 Email = 'test@t.com',
                                 Password__c = '1',
                                 LastName = 'test');
        insert con;
        
        MonthlyExpense__c mx = new MonthlyExpense__c();
        mx.Balance__c = 100;
        mx.Keeper__c = con.Id;
        mx.MonthDate__c = Date.newInstance(2019, 1, 1);
        insert mx;
        
        Date dateExpenseCard = Date.newInstance(2019, 1, 20);
        
        ExpenseCard__c ex = new ExpenseCard__c();
        ex.CardKeeper__c = con.Id;
        ex.CardDate__c = dateExpenseCard;
        ex.MonthlyExpense__c = mx.Id;
        
        Test.startTest();
        Database.SaveResult result = Database.insert(ex, false);
        Test.stopTest();
        System.assert(result.isSuccess());
        System.assert(result.getErrors().size() == 0);
        ExpenseCard__c exResult = [SELECT CardKeeper__c, CardDate__c, MonthlyExpense__c FROM ExpenseCard__c WHERE CardDate__c =:dateExpenseCard AND CardKeeper__c =:con.Id LIMIT 1];
        System.assertEquals(ex.MonthlyExpense__c, exResult.MonthlyExpense__c);
    }
	
     @isTest
    public static void saveExpenseCardNoMonthlyExpenseTest(){
        
        Contact con = new Contact(Admin__c = false,
                                 Office__c = 'office 1',
                                 Email = 'test@t.com',
                                 Password__c = '1',
                                 LastName = 'test');
        insert con;
        
        Date dateExpenseCard = Date.newInstance(2019, 1, 20);
        
        ExpenseCard__c ex = new ExpenseCard__c();
        ex.CardKeeper__c = con.Id;
        ex.CardDate__c = dateExpenseCard;
        
        Test.startTest();
        Database.SaveResult result = Database.insert(ex, false);
        Test.stopTest();
        System.assert(result.isSuccess());
        System.assert(result.getErrors().size() == 0);
        ExpenseCard__c exResult = [SELECT CardKeeper__c, CardDate__c, MonthlyExpense__c FROM ExpenseCard__c WHERE CardDate__c =:dateExpenseCard AND CardKeeper__c =:con.Id LIMIT 1];
        System.assertNotEquals(null, exResult.MonthlyExpense__c);
    }
}