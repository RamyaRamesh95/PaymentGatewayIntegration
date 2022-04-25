global class CybersourceRestAdapter implements commercepayments.PaymentGatewayAdapter {
    private static final commercepayments.SalesforceResultCodeInfo SUCCESS_SALESFORCE_RESULT_CODE_INFO =
    new commercepayments.SalesforceResultCodeInfo(commercepayments.SalesforceResultCode.Success);
    private static final commercepayments.SalesforceResultCodeInfo DECLINE_SALESFORCE_RESULT_CODE_INFO =
    new commercepayments.SalesforceResultCodeInfo(commercepayments.SalesforceResultCode.Decline);
    global CybersourceRestAdapter() {
    } global commercepayments.GatewayResponse processRequest(commercepayments.paymentGatewayContext gatewayContext) {
    commercepayments.RequestType requestType = gatewayContext.getPaymentRequestType();
    commercepayments.PaymentsHttp http = new commercepayments.PaymentsHttp();
    commercepayments.GatewayResponse response;
    try
    {
    System.debug('Request Type: ' + requestType);
    if (requestType == commercepayments.RequestType.Authorize) {
    System.debug('Create Auth Payment');
    // response = createAuthResponse((commercepayments.AuthorizationRequest)gatewayContext.getPaymentRequest());
    HttpRequest request = CybersourceUtility.buildPaymentRequest((commercepayments.AuthorizationRequest)gatewayContext.getPaymentRequest());
    HttpResponse paymentResponse = http.send(request);
    // response = (commercepayments.GatewayResponse) ;
    System.debug('Payment Response : ');
    System.debug(paymentResponse.getBody());
    CybersourceAuthResponse resp = null;
    try{
    // String res = '{"_links":{"authReversal":{"method":"POST","href":"/pts/v2/payments/6487962374846838704001/reversals"},"self":{"method":"GET","href":"/pts/v2/payments/6487962374846838704001"},"capture":{"method":"POST","href":"/pts/v2/payments/6487962374846838704001/captures"}},"clientReferenceInformation":{"code":"TC50171_3"},"id":"6487962374846838704001","orderInformation":{"amountDetails":{"authorizedAmount":"551.87","currency":"USD"}},"paymentAccountInformation":{"card":{"type":"001"}},"paymentInformation":{"tokenizedCard":{"type":"001"},"card":{"type":"001"}},"pointOfSaleInformation":{"terminalId":"111111"},"processorInformation":{"approvalCode":"888888","cardVerification":{"resultCode":""},"networkTransactionId":"123456789619999","transactionId":"123456789619999","responseCode":"100","avs":{"code":"X","codeRaw":"I1"}},"reconciliationId":"7688958211D5J5M7","status":"AUTHORIZED","submitTimeUtc":"2022-04-01T06:57:17Z"}';
    resp = (CybersourceAuthResponse)JSON.deserialize(paymentResponse.getBody(), CybersourceAuthResponse.class);
    System.debug(resp.status);
    }catch(Exception e){
    System.debug('Error in parsing Response');
    }
    response = createAuthResponseCyberSource(resp);
    // Http http = new Http();
    // response = (commercepayments.GatewayResponse)http.send(request);
    }
    else if ( requestType == commercepayments.RequestType.Capture)
    {
    response = createCaptureResponse((commercepayments.CaptureRequest)gatewayContext.getPaymentRequest()) ;
    }
    else if ( requestType == commercepayments.RequestType.Sale)
    {
    response = createSaleResponse((commercepayments.SaleRequest)gatewayContext.getPaymentRequest()) ;
    }
    else if (requestType == commercepayments.RequestType.ReferencedRefund) {
    response = createRefundResponse((commercepayments.ReferencedRefundRequest)gatewayContext.getPaymentRequest());
    }
    else if (requestType == commercepayments.RequestType.Tokenize) {
    response = createTokenizeResponse((commercepayments.PaymentMethodTokenizationRequest)gatewayContext.getPaymentRequest());
    }
    return response;
    }
    catch(SalesforceValidationException e)
    {
    commercepayments.GatewayErrorResponse error = new commercepayments.GatewayErrorResponse('400', e.getMessage());
    System.debug('Process Request Exception : ' + e.getLineNumber() + ' ' + e.getMessage());
    return error;
    }
    catch(Exception exp){
    System.debug('Process Request Exception : ' + exp.getLineNumber() + ' ' + exp.getMessage());
    return null;
    }
    } public commercepayments.GatewayResponse createAuthResponseCyberSource(CybersourceAuthResponse cbResponse) {
    commercepayments.AuthorizationResponse authResponse = new commercepayments.AuthorizationResponse();
    commercepayments.PaymentMethodTokenizationResponse paymentMethodTokenizationResponse = new commercepayments.PaymentMethodTokenizationResponse();
    if(cbResponse.orderInformation.amountDetails.authorizedAmount !=null )
    {
    authResponse.setAmount(double.valueOf(cbResponse.orderInformation.amountDetails.authorizedAmount));
    }
    else
    {
    throw new SalesforceValidationException('Required Field Missing : Amount');
    }
    authResponse.setGatewayResultCode(cbResponse.processorInformation.responseCode);
    authResponse.setGatewayResultCodeDescription('Transaction Status : ' + cbResponse.status);
    authResponse.setGatewayAuthCode(cbResponse.processorInformation.approvalCode);
    authResponse.setGatewayReferenceNumber(cbResponse.processorInformation.transactionId);
    authResponse.setSalesforceResultCodeInfo(SUCCESS_SALESFORCE_RESULT_CODE_INFO);
    authResponse.setGatewayDate(system.now());
    paymentMethodTokenizationResponse.setGatewayToken(cbResponse.id);
    authResponse.setPaymentMethodTokenizationResponse(paymentMethodTokenizationResponse);
    return authResponse;
    } public commercepayments.GatewayResponse createTokenizeResponse(commercepayments.PaymentMethodTokenizationRequest tokenizeRequest) {
    commercepayments.PaymentMethodTokenizationResponse tokenizeResponse = new commercepayments.PaymentMethodTokenizationResponse();
    tokenizeResponse.setGatewayToken(getRandomNumber(8)+getRandomNumber(8));
    tokenizeResponse.setGatewayTokenDetails(getRandomNumber(8)+getRandomNumber(8));
    tokenizeResponse.setGatewayAvsCode(getRandomNumber(8)+getRandomNumber(8));
    tokenizeResponse.setGatewayMessage(getRandomNumber(8)+getRandomNumber(8));
    tokenizeResponse.setGatewayResultCode(getRandomNumber(8)+getRandomNumber(8));
    tokenizeResponse.setGatewayResultCodeDescription(getRandomNumber(8)+getRandomNumber(8));
    tokenizeResponse.setSalesforceResultCodeInfo(SUCCESS_SALESFORCE_RESULT_CODE_INFO);
    tokenizeResponse.setGatewayToken(getRandomNumber(8)+getRandomNumber(8));
    tokenizeResponse.setGatewayDate(system.now());
    return tokenizeResponse;
    } public commercepayments.GatewayResponse createAuthResponse(commercepayments.AuthorizationRequest authRequest) {
    commercepayments.AuthorizationResponse authResponse = new commercepayments.AuthorizationResponse();
    commercepayments.PaymentMethodTokenizationResponse paymentMethodTokenizationResponse = new commercepayments.PaymentMethodTokenizationResponse();
    if(authRequest.amount!=null )
    {
    authResponse.setAmount(authRequest.amount);
    }
    else
    {
    throw new SalesforceValidationException('Required Field Missing : Amount');
    }
    authResponse.setGatewayResultCode('00');
    authResponse.setGatewayResultCodeDescription('Transaction Normal');
    authResponse.setGatewayAuthCode('SF'+getRandomNumber(6));
    authResponse.setGatewayReferenceNumber(getRandomNumber(10));
    authResponse.setSalesforceResultCodeInfo(SUCCESS_SALESFORCE_RESULT_CODE_INFO);
    authResponse.setGatewayDate(system.now());
    paymentMethodTokenizationResponse.setGatewayToken(getRandomNumber(8)+getRandomNumber(8));
    authResponse.setPaymentMethodTokenizationResponse(paymentMethodTokenizationResponse);
    return authResponse;
    }
    public commercepayments.GatewayResponse createCaptureResponse(commercepayments.CaptureRequest captureRequest) {
    commercepayments.CaptureResponse captureResponse = new commercepayments.CaptureResponse();
    if(captureRequest.amount!=null )
    {
    captureResponse.setAmount(captureRequest.amount);
    }
    else
    {
    throw new SalesforceValidationException('Required Field Missing : Amount');
    }
    system.debug('Response - success');
    captureResponse.setGatewayDate(system.now());
    captureResponse.setGatewayResultCode('00');
    captureResponse.setGatewayResultCodeDescription('Transaction Normal');
    captureResponse.setGatewayReferenceNumber('SF'+getRandomNumber(6));
    captureResponse.setSalesforceResultCodeInfo(SUCCESS_SALESFORCE_RESULT_CODE_INFO);
    return captureResponse;
    }
    public commercepayments.GatewayResponse createSaleResponse(commercepayments.SaleRequest saleRequest) {
    commercepayments.SaleResponse saleResponse = new commercepayments.SaleResponse();
    commercepayments.PaymentMethodTokenizationResponse paymentMethodTokenizationResponse = new commercepayments.PaymentMethodTokenizationResponse();
    if(saleRequest.amount!=null )
    {
    saleResponse.setAmount(saleRequest.amount);
    }
    else
    {
    throw new SalesforceValidationException('Required Field Missing : Amount');
    }
    system.debug('Response - success');
    saleResponse.setGatewayDate(system.now());
    saleResponse.setGatewayResultCode('00');
    saleResponse.setGatewayResultCodeDescription('Transaction Normal');
    saleResponse.setGatewayReferenceNumber('SF'+getRandomNumber(6));
    saleResponse.setSalesforceResultCodeInfo(SUCCESS_SALESFORCE_RESULT_CODE_INFO);
    paymentMethodTokenizationResponse.setGatewayToken(getRandomNumber(8)+getRandomNumber(8));
    saleResponse.setPaymentMethodTokenizationResponse(paymentMethodTokenizationResponse);
    return saleResponse;
    }
    public commercepayments.GatewayResponse createRefundResponse(commercepayments.ReferencedRefundRequest refundRequest) {
    commercepayments.ReferencedRefundResponse refundResponse = new commercepayments.ReferencedRefundResponse();
    if (refundRequest.amount != null) {
    refundResponse.setAmount(refundRequest.amount);
    } else {
    throw new SalesforceValidationException('Required Field Missing : Amount');
    }
    refundResponse.setGatewayResultCode('00');
    refundResponse.setGatewayDate(system.now());
    refundResponse.setGatewayResultCodeDescription('Transaction Normal');
    refundResponse.setGatewayReferenceNumber('SF'+getRandomNumber(6));
    refundResponse.setSalesforceResultCodeInfo(SUCCESS_SALESFORCE_RESULT_CODE_INFO);
    return refundResponse;
    }
    private String getRandomNumber(integer stringLength){
    final integer MAX = integer.valueOf(Math.pow(10,stringLength) - 1);
    return String.valueOf(Math.Round(Math.Random() * MAX)).leftPad(stringLength,'0');
    }
    }