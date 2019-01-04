@IsTest
private class TestBLUPDataInstaller {
    static testMethod void testInstall() {
        BLUPDataInstaller postInstall = new BLUPDataInstaller();
        postInstall.PUSH_TOPIC_NAME = 'testBLUPName';
        Test.testInstall(postInstall, null);
    }

    static testMethod void testUninstall() {
        BLUPDataInstaller postInstall = new BLUPDataInstaller();
        postInstall.PUSH_TOPIC_NAME = 'testBLUPName';
        Test.testInstall(postInstall, null);
        Test.testUninstall(new BLUPDataInstaller());
    }
}