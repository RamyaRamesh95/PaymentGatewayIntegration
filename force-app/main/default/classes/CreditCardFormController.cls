public class CreditCardFormController {
    
    @AuraEnabled
    public static Map<String, Object> getComponentSetup(String cartId) {
        Map<String, Object> returnData = new Map<String, Object>();
        System.debug('Get Component SetUp called');
        try {
            
            System.debug('Cart Id : ' + cartId);
            WebCart wc = [SELECT AccountId FROM WebCart WHERE Id = :cartId];

            System.debug('Web Cart  : ' + JSON.serialize(wc));
            
            returnData.put('addresses', [SELECT Address FROM ContactPointAddress WHERE ParentId = :wc.AccountId AND AddressType = 'Billing']);   
            
            //TODO - the data for the CardType values are not accessible/displayed in the Lightning Component so need a different approach here
            returnData.put('cardTypes', ConnectApi.CardType.values());
            returnData.put('keyId', CybersourceUtility.generateKey());
        } catch(Exception e) {
            System.debug(e.getMessage());
            returnData.put('error', e.getMessage());
        }
        System.debug('Get Component SetUp Returning : ' + returnData);
        return returnData;
    }
    
    @AuraEnabled
    public static String handlePostPayment(String token, String cartId, String orderId, String addressId, String expirationMonth, String expirationYear, String cardholderName) {
        System.debug('Handle Post Payment Called');
        try {
            ContactPointAddress cpa = [SELECT Address FROM ContactPointAddress WHERE Id = :addressId];
            WebCart currCart = [SELECT CurrencyIsoCode, GrandTotalAmount  FROM WebCart WHERE Id = :cartId];
    
            //Set Amount Information
            ConnectApi.AuthorizationRequest request = new ConnectApi.AuthorizationRequest();
            
            //TODO - currently hardcoded for testing but need a more dynamic approach to retrieve this value
            request.paymentGatewayId = '0b03J0000004C9IQAU'; // Cybersource
            //request.paymentGatewayId = '0b07h000000KyjLAAS'; // Stripe
            
            //NOTE - may need to include rounding here as if more than 2 decimals, Order Summary vs. Order Payment Summary may differ here
            request.amount = currCart.GrandTotalAmount;
            request.currencyIsoCode = currCart.CurrencyIsoCode;
            
            //Set Payment Group Information
            ConnectApi.PaymentGroupRequest pgr = new ConnectApi.PaymentGroupRequest();
            pgr.sourceObjectId = orderId;
            pgr.currencyIsoCode = currCart.CurrencyIsoCode;
            pgr.createPaymentGroup = true;
            request.paymentGroup = pgr;
            
            //Set Address Info
            ConnectApi.AuthApiPaymentMethodRequest authApiPMRequest = new ConnectApi.AuthApiPaymentMethodRequest();
            authApiPMRequest.address = new ConnectApi.AddressRequest();
            authApiPMrequest.address.street = cpa.Address.getStreet();
            authApiPMrequest.address.city = cpa.Address.getCity();
            authApiPMrequest.address.state = cpa.Address.getState();
            authApiPMrequest.address.postalCode = cpa.Address.getPostalCode();
            authApiPMrequest.address.country = cpa.Address.getCountry();
    
            //Set Payment Information
            ConnectApi.CardPaymentMethodRequest cpmRequest = new ConnectApi.CardPaymentMethodRequest();
            
            //Dummy Card Number value to bypass required field
            cpmRequest.cardNumber = '00000000';
            
            cpmRequest.expiryYear = Integer.valueOf(expirationYear);
            cpmRequest.expiryMonth = Integer.valueOf(expirationMonth);
            cpmRequest.cardHolderName = cardHolderName;
            cpmRequest.cardType = ConnectApi.CardType.Visa.name();
            cpmRequest.cardCategory = ConnectApi.CardCategory.CreditCard;
            authApiPMRequest.cardPaymentMethod = cpmRequest;
            
            request.paymentMethod = authApiPMRequest;
                                            
            //Add Transient Token to additionalData
            request.additionalData = new Map<String, String>();
            splitToken(request, token);

            ConnectApi.AuthorizationResponse response = ConnectApi.Payments.authorize(request);
            return JSON.serialize(response);
        } catch(Exception e) {
            return e.getMessage();
        }
    }
    
    //JD 05/26: Split the Transient Token into smaller chunks due to a character limit on additionalData values
    private static void splitToken (ConnectApi.AuthorizationRequest request, String token) {
        Decimal VALUE_LIMIT = 1000.00;

        //Number of Chunks that the Token will be split into
        Integer numOfChunks = Integer.valueOf(Math.ceil(token.length()/VALUE_LIMIT));
        
        for(Integer i = 0 ; i < numOfChunks ; i++) {
            Integer lowerLimit = Integer.valueOf(i * VALUE_LIMIT);
            Integer upperLimit = Integer.valueOf((i + 1) * VALUE_LIMIT);
            
            //If upperLimit is out of bounds, limit it to the total length of the Token
            if(upperLimit > token.length()) {
                upperLimit = token.length();
            }
            
            String tokenChunk = token.substring(lowerLimit, upperLimit);
            request.additionalData.put(String.valueOf(i), tokenChunk);
        }
    }
}