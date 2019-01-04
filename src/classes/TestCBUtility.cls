@isTest
private class TestCBUtility{
    
    
	
	@isTest
	private static void TestGetGuid() {
	    
	    String guid = CBUtility.GetGuid();
		
		System.assertEquals(true, !String.isBlank(guid));

	}
	
    @isTest
	private static void TestNormalizeKey() {
	    
	    String keyToNormalize = 'This is not normal';
		String expectedKeyAfterNormalization = 'THIS_IS_NOT_NORMAL';
		
		String normalized = CBUtility.NormalizeKey(keyToNormalize);
		
		System.assertEquals(expectedKeyAfterNormalization, normalized);

	}
	
	@isTest
	private static void TestHeadersUpdatesExisting() {
	    
	    HttpRequest httpReq = new HttpRequest();
	    httpReq.setHeader('Cheese','Provolone');
	    
	    CBUtility util = new CBUtility();
	    
	    util.UpdateOrAddHeader(httpReq, 'Cheese', 'Gouda');
	    
	    System.assertEquals('Gouda', httpReq.getHeader('Cheese'));

	}
	
	@isTest
	private static void TestHeadersAddsNew() {
	    
	    HttpRequest httpReq = new HttpRequest();
	    
	    CBUtility util = new CBUtility();
	    
	    util.UpdateOrAddHeader(httpReq, 'Cheese', 'Gouda');
	    
	    System.assertEquals('Gouda', httpReq.getHeader('Cheese'));

	}
	@isTest
	private static void TestHeaderNotBlankAndExists() {
	    
	    HttpRequest httpReq = new HttpRequest();
	    httpReq.setHeader('Cheese','Provolone');
	    CBUtility util = new CBUtility();
	    
	    util.UpdateOrAddHeader(httpReq, 'Cheese', 'Provolone');
	    
	    System.assertEquals('Provolone', httpReq.getHeader('Cheese'));

	}
	
	@isTest
	private static void TestUrlEncoding() {
		Map<String, String> m = new Map<String, String>();
		
		m.put('Red', 'FF0000');
		m.put('Blue', '0000A0');
		
		String encoded = CBUtility.UrlFormEncodeMap(m);
	    
	    System.assertEquals('Red=FF0000&Blue=0000A0', encoded);

	}
	
	@isTest
	private static void TestUrlEncoding2() {
		Map<String, String> m = new Map<String, String>();
		
		m.put('Red', 'FF0000 AND IS COOL');
		m.put('Blue', '0000A0 AND IS NOT COOL');
		
		String encoded = CBUtility.UrlFormEncodeMap(m);
	    
	    System.assertEquals('Red=FF0000+AND+IS+COOL&Blue=0000A0+AND+IS+NOT+COOL', encoded);

	}
}