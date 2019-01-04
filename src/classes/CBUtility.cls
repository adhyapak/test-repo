public without sharing class CBUtility{
    
    @TestVisible private class UtilityException extends Exception {}
    
    public static String NormalizeKey(String input){
    	return input.toUpperCase().replace(' ','_');
    }
    
    public static String GetGuid(){
        Blob generatedBlob = Crypto.GenerateAESKey(128);
        String hex = EncodingUtil.ConvertTohex(generatedBlob);
        String guid = hex.substring(0, 8)
            + '-' + hex.substring(8, 12)
            + '-' + hex.substring(12, 16)
            + '-' + hex.substring(16, 20)
            + '-' + hex.substring(20);
        return guid.toUpperCase();
    }
    
    public static String UrlFormEncodeMap(Map<String,String> input){
        
        if(input == null) throw new UtilityException(System.Label.CBUtilitySerializeNullException);
        
        List<String> output = new List<String>();
        for (String key : input.keySet()) {
            output.add(EncodingUtil.urlEncode(key, 'UTF-8') + '=' + EncodingUtil.urlEncode(input.get(key), 'UTF-8'));
        }
        if(output.size()==0) return null;
        return String.join(output, '&');
    }
    
    public void UpdateOrAddHeader(HttpRequest httpReq, String headerKey, String newHeaderValue){
        String existingContentTypeHeaderValue = httpReq.getHeader(headerKey);
        if(String.isBlank(existingContentTypeHeaderValue) || existingContentTypeHeaderValue.toLowerCase() != newHeaderValue.toLowerCase()){
            httpReq.setHeader(headerKey, newHeaderValue);
            return;
        }else{
            // it already is set to what we want, so just continue
            return;
        }
    }
    
    
}