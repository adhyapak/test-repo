@isTest
public class ProductPRCCLCloneTest
{
    static testMethod void controllerTestDriver()
    {
        LLC_BI__Product_Line__c test_productline = new LLC_BI__Product_Line__c(Name = 'TestProductType', LLC_BI__lookupKey__c = 'TESTPL001');
        insert test_productline;

        LLC_BI__Product_Type__c test_producttype = new LLC_BI__Product_Type__c(Name = 'TestProductType', LLC_BI__lookupKey__c = 'TESTPT001', LLC_BI__Product_Line__c = test_productline.ID);
        insert test_producttype;
        
        LLC_BI__Product__c test_product = new LLC_BI__Product__c(Name = 'TestProduct', LLC_BI__lookupKey__c = 'TESTPR001', LLC_BI__Product_Type__c = test_producttype.ID);
        insert test_product;
        
        LLC_BI__Product__c test_product2 = new LLC_BI__Product__c(Name = 'TestProduct', LLC_BI__lookupKey__c = 'TESTPR002', LLC_BI__Product_Type__c = test_producttype.ID);
        insert test_product2;
        
        LLC_BI__Product__c test_product3 = new LLC_BI__Product__c(Name = 'TestProduct', LLC_BI__lookupKey__c = 'TESTPR003', LLC_BI__Product_Type__c = test_producttype.ID);
        insert test_product3;

        //insert closing checklist
        LLC_BI__ClosingChecklist__c ccl1 = new LLC_BI__ClosingChecklist__c(Name = 'TestCCL1', LLC_BI__lookupKey__c = 'TESTCCL001');
        insert ccl1;
        LLC_BI__ClosingChecklist__c ccl2 = new LLC_BI__ClosingChecklist__c(Name = 'TestCCL2', LLC_BI__lookupKey__c = 'TESTCCL002');
        insert ccl2;
        LLC_BI__ClosingChecklist__c ccl3 = new LLC_BI__ClosingChecklist__c(Name = 'TestCCL3', LLC_BI__lookupKey__c = 'TESTCCL003');
        insert ccl3;
        
        //insert pr-ccl and prdt
        LLC_BI__ProductCCL__c prccl1 = new LLC_BI__ProductCCL__c(LLC_BI__Closing_Checklist__c = ccl1.ID, LLC_BI__Product__c = test_product.ID);
        insert prccl1;
    
        LLC_BI__DocTab__c doctab1 = new LLC_BI__DocTab__c(Name = 'TEST-TAB1');
        insert doctab1;
        LLC_BI__ProductDocTab__c prdt = new LLC_BI__ProductDocTab__c(LLC_BI__DocTab__c = doctab1.Id, LLC_BI__Product__c = test_product.Id);
        insert prdt;
    
        ProductPRCCLClone npc = new ProductPRCCLClone();        
        
        //Intended for a successful run          
        npc.autoSetup();
        npc.sourcePRGS = 'TESTPR001';
        npc.sourcePR2GS = 'TESTPR001';
        npc.copyTargetPRsGS = 'TESTPR002,TESTPR003';
        npc.prToKeepGS = 'TESTPR001,TESTPR002';
        npc.removeTargetsGS = 'TESTPR002,TESTPR003';
        npc.cloneToAll();
        npc.cloneToTargets();
        npc.removeAll();
        npc.removeTargets();
        
        /*
        //Supplying invalid target information
        npc.autoSetup();
        npc.sourcePRGS = 'TESTPR001';
        npc.sourcePR2GS = 'TESTPR001';
        npc.copyTargetPRsGS = 'INVALID1,INVALID2';
        npc.prToKeepGS = 'INVALID1,INVALID2';
        npc.removeTargetsGS = 'INVALID1,INVALID2';
        npc.cloneToAll();
        npc.cloneToTargets();
        npc.removeAll();
        npc.removeTargets();
        */
        
        //Simulating failures using attempting SOQL Injection
        npc.autoSetup();
        npc.sourcePRGS = 'x \' LIMIT invalid';
        npc.sourcePR2GS = 'x \' LIMIT invalid';
        npc.copyTargetPRsGS = 'x \' LIMIT invalid';
        npc.prToKeepGS = 'x \' LIMIT invalid';
        npc.removeTargetsGS = 'x \' LIMIT invalid';
        npc.cloneToAll();
        npc.cloneToTargets();
        npc.removeAll();
        npc.removeTargets();
        
        //Not supplying enough information
        npc.autoSetup();
        npc.sourcePRGS = '';
        npc.sourcePR2GS = '';
        npc.copyTargetPRsGS = '';
        npc.prToKeepGS = '';
        npc.removeTargetsGS = '';
        npc.cloneToAll();
        npc.cloneToTargets();
        npc.removeAll();
        npc.removeTargets();       
    }
}