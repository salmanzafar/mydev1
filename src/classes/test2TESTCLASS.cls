@isTest
private class test2TESTCLASS{
    static testMethod void testAsUser() {
        system.assertEquals(test2.isRed('blue'),false);
        system.assertEquals(test2.isRed('red'),true);
        system.assertEquals(6,2+3);
    }
}