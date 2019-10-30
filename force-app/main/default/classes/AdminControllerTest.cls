@isTest
public class AdminControllerTest {
    
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
    public static void getMouthlyExpenseTest(){ 
    	
        Test.startTest();
        AdminController.MonthlyExpense monthlyExpense = AdminController.getMouthlyExpense(2019);
        Test.stopTest();
        System.assertEquals(34, monthlyExpense.summ);
        System.assertEquals(12, monthlyExpense.dataList.size());
        System.assertEquals(1, monthlyExpense.officeList.size());
        System.assertEquals('Office 1', monthlyExpense.officeList[0].officeName);
        System.assertEquals(34, monthlyExpense.officeList[0].totalAmount);
        System.assertEquals(17, monthlyExpense.officeList[0].monthlyAverage);        
    }
    
     @isTest
    public static void getMouthlyExpenseErrorYearTest(){        
    	
        Test.startTest();
        AdminController.MonthlyExpense monthlyExpense = AdminController.getMouthlyExpense(555);
        Test.stopTest();
        System.assertEquals(0, monthlyExpense.summ);
        System.assertEquals(12, monthlyExpense.dataList.size());
        System.assertEquals(1, monthlyExpense.officeList.size());
        System.assertEquals('Office 1', monthlyExpense.officeList[0].officeName);
        System.assertEquals(0, monthlyExpense.officeList[0].totalAmount);
        System.assertEquals(0, monthlyExpense.officeList[0].monthlyAverage);        
    }

}