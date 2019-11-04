@isTest
public class ExpensesControllerTest {
    
    @testSetup
    public static void initData(){
        Contact con = new Contact(Admin__c = false,
                                 Office__c = 'office 1',
                                 Email = 'test@t.com',
                                 Password__c = '1',
                                 LastName = 'test');
        insert con;
        
        List<MonthlyExpense__c> mxList = new List<MonthlyExpense__c>();
        for(Integer i = 2; i<=5; i++){
        	MonthlyExpense__c mx = new MonthlyExpense__c(Balance__c = 100 + i,
                                                    MonthDate__c = Date.newInstance(2019, i, 1),
                                                    Keeper__c = con.Id);
            mxList.add(mx);
        }
        insert mxList;
        
        List<ExpenseCard__c> ecList = new List<ExpenseCard__c>();
        for(Integer i = 2; i<=5; i++){
            ExpenseCard__c ec = new ExpenseCard__c(Description__c = 'testMilk' + i,
                                                  Amount__c = 5 + i,
                                                  CardDate__c = Date.newInstance(2019, 2, i),
                                                  CardKeeper__c = con.Id,
                                                  MonthlyExpense__c = mxList[0].Id);
        	ecList.add(ec);
        }
        insert ecList;
        
    }

    @isTest
    public static void loginUserTest(){     
        Test.startTest();
        Contact co = ExpensesController.loginUser('test@t.com', '1');
        Test.stopTest();        
        System.assertEquals('Office 1', co.Office__c);
        System.assertEquals(false, co.Admin__c);
    }
    
    @isTest
    public static void getMouthlyExpenseTest(){
        Contact con = [SELECT id, Admin__c, Office__c FROM Contact WHERE Email ='test@t.com' AND Password__c ='1' LIMIT 1];
        Test.startTest();
        ExpensesController.MonthlyExpense monthlyExpense = ExpensesController.getMouthlyExpense(con.Id, 2019);
        Test.stopTest();
        System.assertNotEquals(null, monthlyExpense);
        System.assertEquals(12, monthlyExpense.monthlyExpenseList.size());
        System.assertEquals(414, monthlyExpense.totalIncome);
        System.assertEquals(34, monthlyExpense.totalAmount);
    }
    
    @isTest
    public static void getExpenseCardTest(){
        Contact con = [SELECT id, Admin__c, Office__c FROM Contact WHERE Email ='test@t.com' AND Password__c ='1' LIMIT 1];
        Test.startTest();
        Date dat = date.newInstance(2019, 02, 01);
        List<ExpensesController.Expenses> resultEc = ExpensesController.getExpenseCard(dat, con.Id);
        Test.stopTest();
        System.assertEquals(4, resultEc.size());
        System.assertEquals(7, resultEc[0].totalSum);
        Date dateCart = date.newInstance(2019, 02, 02);
        System.assertEquals(dateCart, resultEc[0].cardDateUnique);
        
    }
    
    @isTest
    public static void saveExpenseCardTest(){
        Contact con = [SELECT id, Admin__c, Office__c FROM Contact WHERE Email ='test@t.com' AND Password__c ='1' LIMIT 1];
        ExpenseCard__c ec = new ExpenseCard__c(Description__c = 'testMilk',
                                                  Amount__c = 5,
                                                  CardDate__c = Date.newInstance(2019, 2, 15),
                                                  CardKeeper__c = con.Id);
        Test.startTest();
        String result = ExpensesController.saveExpenseCard(ec);
        Test.stopTest();
        System.assertEquals('ok', result);
    }
    
    @isTest
    public static void saveExpenseCardExseptionTest(){
        Contact con = [SELECT id, Admin__c, Office__c FROM Contact WHERE Email ='test@t.com' AND Password__c ='1' LIMIT 1];
        ExpenseCard__c ec = new ExpenseCard__c(Description__c = 'testMilk',
                                                  Amount__c = 5,
                                                  CardDate__c = Date.newInstance(2019, 2, 15));
        Test.startTest();
        try{
           String result = ExpensesController.saveExpenseCard(ec);
        }catch(DmlException e){
            
        }       
        Test.stopTest();
    }
    
    @isTest
    public static void deleteExpenseCard(){
        Contact con = [SELECT id, Admin__c, Office__c FROM Contact WHERE Email ='test@t.com' AND Password__c ='1' LIMIT 1];
        ExpenseCard__c ec = new ExpenseCard__c(Description__c = 'testMilk',
                                                  Amount__c = 5,
                                                  CardDate__c = Date.newInstance(2019, 2, 5),
                                                  CardKeeper__c = con.Id);
        insert ec;
        Test.startTest();
        ExpensesController.deleteExpenseCard(ec.Id);
        Test.stopTest();
        ExpenseCard__c[] ecNew = [SELECT Description__c FROM ExpenseCard__c WHERE id =: ec.Id LIMIT 1];
        System.assertEquals(0, ecNew.size());
    }
    
    @isTest
    public static void addBalanceTest(){
        Date dat = date.newInstance(2019, 02, 01);
        Contact con = [SELECT id, Admin__c, Office__c FROM Contact WHERE Email ='test@t.com' AND Password__c ='1' LIMIT 1];
        Test.startTest();
        ExpensesController.addBalance(dat, con.Id, 5);
        Test.stopTest();
        MonthlyExpense__c mx = [SELECT Balance__c FROM MonthlyExpense__c WHERE MonthDate__c =:dat AND Keeper__c =:con.Id LIMIT 1];
        System.assertEquals(107, mx.Balance__c);
    }
}