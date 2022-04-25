public class CybersourceUtility {
    //TODO - move these values to a more secure method (ex: Protected Custom Settings or Metadata Types)
    public static final String HOST = 'apitest.cybersource.com';
    public static final String MERCHANT_ID = 'epamb2b_22';
    public static final String KEY_ID = '880595b3-178a-4021-859c-8f9d7d0241ac';  
    public static final String PRIVATE_KEY = 'JSiAOLUETt0do+Uicpwgdv8rGcDJ1Cuch2qKZCE6pGk=';
    
    //Origin of the B2B Storefront
    //public static final String ORIGIN = 'https://jd-b2b-sandbox.force.com';
    //public static final String ORIGIN = 'https://tjain-customerportal.cs59.force.com';
    public static final String ORIGIN = 'https://rramesh-b2b.cs124.force.com';    
    public static String DATETIME_STRING, DIGEST_STRING;
    
    //Generates a temporary Key for the Microflex Form
    public static String generateKey() {
        try {
            String reqTarget = '/flex/v1/keys?format=JWT';
            String reqBody = '{"encryptionType":"RsaOaep256", "targetOrigin":"' + ORIGIN + '"}';
            HttpRequest req = generatePostRequest(reqTarget, reqBody);
            
            Http http = new Http();
            HttpResponse res = http.send(req);
            
            Map<String, Object> resMap = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());
            System.debug('Generated Key : ' + String.valueOf(resMap.get('keyId')));
            return String.valueOf(resMap.get('keyId'));
        } catch(Exception e) {
            System.debug('Exception Generate Key : ' + e.getMessage());
            return e.getMessage();
        }
    }
    
    //Generates the POST /payments request for Cybersource
    public static HttpRequest buildPaymentRequest(commercepayments.AuthorizationRequest authReq) {
        String reqTarget = '/pts/v2/payments';
        
        CommercePayments.AuthApiPaymentMethodRequest authPaymentRequest = authReq.paymentMethod;
        String token = combineToken(authReq.additionalData);

        String reqBody = generateRequestBody(authReq, authPaymentRequest, token);
        HttpRequest req = generatePostRequest(reqTarget, reqBody);
        
        //Have to overwrite the endpoint as this class adds a Named Credential to the beginning (which will fail in the context of checkout/PaymentGatewayAdapter)
        req.setEndpoint(reqTarget);

        return req;
    }

    // --- HTTP Request Helper Methods ---
    //    
    //Generates a POST request to the specified endpoint and sets the body
    private static HttpRequest generatePostRequest(String reqTarget, String reqBody) {
        HttpRequest req = generateRequestBase(reqTarget, 'POST');
        
        //POST requests
        String digestString = generateDigest(reqBody);
        String signatureString = generateSignature('post', reqTarget, digestString);
        
        req.setHeader('Digest', digestString);
        req.setHeader('Signature', signatureString);
        req.setBody(reqBody);
        
        return req;
    }
    
    //Generates a base HTTP Request with common headers set (basic structure for GET and POST methods)
    private static HttpRequest generateRequestBase(String reqTarget, String reqMethod) {
        HttpRequest req = new HttpRequest();
        req.setMethod(reqMethod);
        req.setEndpoint('callout:Cybersource_Credential' + reqTarget);
        
        req.setHeader('Host', HOST);
        req.setHeader('v-c-merchant-id', MERCHANT_ID);
        req.setHeader('Content-Type', 'application/json');
        
        setDateTimeString();
        req.setHeader('Date', DATETIME_STRING);
        
        return req;
    }
    
    //Generates the body for the request
    private static String generateRequestBody(CommercePayments.AuthorizationRequest authReq, CommercePayments.AuthApiPaymentMethodRequest authPaymentRequest, String token) {
        System.debug('Generate Request Body Called : ' + JSON.serialize(authReq));
        System.debug('Auth Payment Request and Token');
        System.debug(JSON.serialize(authPaymentRequest) + ' - '+  token);
        JSONGenerator jsGen = JSON.createGenerator(true);
        jsGen.writeStartObject();
                    
        jsGen.writeFieldName('clientReferenceInformation');
        jsGen.writeStartObject();
        //TODO - Need to add condition for when month is 10 or greater, don't add 0
        jsGen.writeStringField('code', 'TC50171_3');
        jsGen.writeEndObject();

        jsGen.writeFieldName('paymentInformation');
        jsGen.writeStartObject();
        jsGen.writeFieldName('card');
        jsGen.writeStartObject();
        //TODO - Need to add condition for when month is 10 or greater, don't add 0
        jsGen.writeStringField('expirationMonth', '0' + String.valueOf(authPaymentRequest.cardPaymentMethod.expiryMonth));
        jsGen.writeStringField('expirationYear', String.valueOf(authPaymentRequest.cardPaymentMethod.expiryYear));
        jsGen.writeEndObject();
        jsGen.writeEndObject();

        jsGen.writeFieldName('orderInformation');
                    
        jsGen.writeStartObject();
        jsGen.writeFieldName('amountDetails');
        jsGen.writeStartObject();
        jsGen.writeStringField('totalAmount', String.valueOf(authReq.amount));
        jsGen.writeStringField('currency', authReq.currencyIsoCode);        
        jsGen.writeEndObject();

        jsGen.writeFieldName('billTo');
        jsGen.writeStartObject();
        //TODO - Update Contact fields to be pulled from request
        List<String> nameList = authPaymentRequest.cardPaymentMethod.cardHolderName.split(' ');
        jsGen.writeStringField('firstName', nameList != null && nameList.get(0) != null ? nameList.get(0) : String.valueOf(authPaymentRequest.cardPaymentMethod.cardHolderName));
        jsGen.writeStringField('lastName', nameList != null && nameList.get(1) != null ? nameList.get(1) : ' ' );     
        jsGen.writeStringField('address1', authPaymentRequest.address.street);
        jsGen.writeStringField('locality', authPaymentRequest.address.city); 
        jsGen.writeStringField('administrativeArea', authPaymentRequest.address.state);
        jsGen.writeStringField('postalCode', authPaymentRequest.address.postalcode); 
        jsGen.writeStringField('country', authPaymentRequest.address.country);
        jsGen.writeStringField('email', 'test@cybs.com');
        jsGen.writeStringField('phoneNumber', '4158880000'); 
        jsGen.writeEndObject();
        jsGen.writeEndObject();
        
        jsGen.writeFieldName('tokenInformation');
        jsGen.writeStartObject();
        jsGen.writeStringField('transientTokenJwt', token);
        jsGen.writeEndObject();
 
        jsGen.writeEndObject();  
        System.debug('Request Body : ' + jsGen.getAsString());    
        return jsGen.getAsString();
    }
        
    //Sets the DATETIME_STRING to the current time in RCF format
    private static void setDateTimeString() {
        DATETIME_STRING = String.valueOf(DateTime.now().formatGmt('EEE, dd MMM yyyy HH:mm:ss z'));
    }
    
    //Generates a Hash of the request body (Digest header)
    private static String generateDigest(String reqBody) {
        Blob digestHash = Crypto.generateDigest('SHA-256', Blob.valueOf(reqBody)); 
        String digestString = 'SHA-256=' + EncodingUtil.base64Encode(digestHash);
        
        return digestString;
    }
    
    //JD 05/26: Combine the transient token back into one value
    private static String combineToken(Map<String, String> additionalData) {
        Integer keyCount = additionalData.keySet().size();
        
        String finalToken = '';
        for(Integer i = 0 ; i < keyCount ; i++) {
            finalToken += additionalData.get(String.valueOf(i));
        }
        
        return finalToken;
    }
    //
    // --- HTTP Request Helper Methods ---
    
    
    // --- Signature Helper Methods ---
    //
    //Method wrapping helper methods to create and return the string that will be set for the Signature header
    private static String generateSignature(String reqType, String reqTarget, String digestString) {  
        String signatureHeaders = generateSignatureHeaders(reqType, reqTarget, digestString);
        String signatureHash = generateSignatureHash(signatureHeaders);

        return generateSignatureString(reqType, signatureHash);
    }
    
    //Generates the (host date (request-target) digest v-c-merchant-id) string
    private static String generateSignatureHeaders(String reqType, String reqTarget, String digestString) {
        String headerFields = '';
        
        //Add host
        headerFields += ('host: ' + HOST + '\n');
        
        //Add date (for POST requests only)
        if(reqType == 'post') {
            headerFields += 'date: ' + DATETIME_STRING + '\n';
        }
        
        //Add (request-target)
        headerFields += ('(request-target): ' + reqType + ' ' + reqTarget + '\n');
        
        //Add digest (for POST requests only)
        if(reqType == 'post') {
            headerFields += ('digest: ' + digestString + '\n');
        } 
        
        //Add v-c-merchant-id
        headerFields += ('v-c-merchant-id: ' + MERCHANT_ID);
        
        return headerFields;
    }
    
    //Creates a HmacSHA256 hash of the Signature Header/Value String
    private static String generateSignatureHash(String data) {        
        Blob hash = Crypto.generateMac('HmacSHA256', Blob.valueOf(data), EncodingUtil.base64Decode(PRIVATE_KEY));

        return EncodingUtil.base64Encode(hash);
    }
    
    //Creates the value to be attached to the Signature on the POST request
    private static String generateSignatureString(String reqType, String signatureHash) {
        String signatureString = '';
        
        signatureString += 'keyid="' + KEY_ID + '", ';
        signatureString += 'algorithm="HmacSHA256", ';
        signatureString += 'headers="host';
            
        //Add in 'date' for POST requests (seems to break GET requests)
        if(reqType == 'post') {
            signatureString += ' date';
        }
        
        signatureString += ' (request-target)';

        //Add in 'digest' for POST requests        
        if(reqType == 'post') {
            signatureString += ' digest';
        }
        
        signatureString += ' v-c-merchant-id", ';
        signatureString += 'signature="' + signatureHash + '"';
        
        return signatureString;
    }    
    //
    // --- End of Signature Helper Methods ---
}