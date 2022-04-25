import { LightningElement , api} from 'lwc';
import getComponentSetup from '@salesforce/apex/CreditCardFormController.getComponentSetup';
import handlePostPayment from '@salesforce/apex/CreditCardFormController.handlePostPayment';
import { loadScript } from "lightning/platformResourceLoader";
import FlexMicroFormMinJS from "@salesforce/resourceUrl/FlexMicroFormMinJS";
import { FlowNavigationNextEvent } from 'lightning/flowSupport';

export default class CreditCardFormLwc extends LightningElement {


    @api microform = {};
    @api token;
    @api orderId; 
    @api cartId;
    @api cardholderName;
    @api selectedCardType;
    @api selectedMonth;
    @api selectedYear;
    @api selectedAddress;
    @api selectedPaymentMethod; 
    @api cardTypes = [];
    @api addresses = []; 
    @api months = []; 
    @api years = [];
    @api disableButton; 
    @api hideCreditCardSection;
    @api navigateFlow;

    connectedCallback() {
        console.log('doInit called');
        loadScript(this, FlexMicroFormMinJS).then(() => {
            console.log('ra');
        }); 
        this.populatePicklists();
        this.makeApexCallout().then(()=>{
       
        });
        //let callout = await this.makeApexCallout();
        // const callout = async () => {
        //     this.makeApexCallout();
        // }
        
        // callout().then(
        //         console.log('ra');
        //     });
        // this.microform = loadScript(this, FlexMicroFormMinJS).then(() => {
        //     console.log('ra');
        // });        
                
    }

    populatePicklists(){
        console.log('populatePicklists called');
        let months = [];
        let years = [];
        let currYear = new Date().getFullYear();
        
        for(let i = 0; i < 20; i++) {
            if(i < 12) {
                months.push({'label' : String(i + 1), 'value' : String(i + 1)});
            }
            years.push({'label' : String(currYear + i), 'value' : String(currYear + i)});
        }
        
        this.months = months;
        this.years = years;
        
    }

    makeApexCallout(){
        console.log('makeApexCallout called');

        return getComponentSetup({ cartId: this.cartId }) 
                .then((result) => {                      
                    this.makeApexCallout_Callback(result);        
                    this.error = undefined;
                })
                .catch((error) => {
                    this.error = error;               
                });    
    }


    makeApexCallout_Callback(calloutResult){
    
        // return (function(a){
        //     var state = a.getState(); 
            console.log('makeApexCallout_Callback called : ');
        //     if (state === "SUCCESS") {   
            try {
                return this.handleResponse(calloutResult);
            } catch(error) {
                console.debug('Error occurred'+error);
            }
                // this.handleResponse(calloutResult);
        //     } else {
        //         //TODO - add error handling to display messages/etc.
        //         console.debug('Error occurred');
        //     }
        // });
    }

    handleCardTypeChange(event){
        console.log('Card Type Dropdown Clicked');
        this.selectedCardType = event.target.value;
    }

    handleMonthChange(event){
        this.selectedMonth = event.target.value;
        console.log('Handle Month Change Clicked'+this.selectedMonth);
    }

    handleYearChange(event){
        this.selectedYear = event.target.value;
        console.log('Handle Year Change Clicked'+this.selectedYear);
    }

    handleAddressChange(event){
        this.selectedAddress = event.target.value;
        console.log('Handle Address Change Clicked'+this.selectedAddress);
    }

    handleCardTypes(){
        let cardTypes = [];        
        //TODO - CardType returned from Apex not returning detailed information - populate with dummy value for now
        cardTypes.push({"label" : "Visa", "value" : "Visa"});
        this.cardTypes = cardTypes;
    
    }

    handleAddresses(vals){
        let addresses = [];

        for(let i = 0; i < vals.length; i++) {
            let currAddress = vals[i]; 
            let label = currAddress.Address.street + ", " + currAddress.Address.city + ", " + currAddress.Address.state + " " + currAddress.Address.postalCode + " " + currAddress.Address.country;
            
            addresses.push({'label' : label, 'value' : currAddress.Id})
        }

        this.addresses = addresses;
        
    }

    handleResponse(response){
        console.log('handleResponse called'+JSON.stringify(response));
        this.handleCardTypes(response.cardTypes);
        this.handleAddresses(response.addresses);
        if(response.keyId !== undefined) {
            this.setupForm(response.keyId);
        } else {
            console.log('handleResponse does not have response key Id on it');
        }
    }

    Flex;

    setupForm(captureContext){
        //Sample code from Cybersource: https://developer.cybersource.com/api/developer-guides/dita-flex/SAFlexibleToken/FlexMicroform/get-started/flex-getting-started-examples.html
       console.log('setupForm');
       //console.log(Flex);
      // console.log(Flex(captureContext));
        var flex = new Flex(captureContext);  
        console.log('flex');
        var microform = flex.microform({'input': {'line-height': '1.875rem'} });
        this.microform = microform;
        console.log(this.microform);
        console.log(this.template.querySelector('[data-id="number-container"]'));  
        var number = microform.createField('number', { placeholder: 'Enter a card number...' });      
        var securityCode = microform.createField('securityCode', { placeholder: '•••' });
        number.load(this.template.querySelector('[data-id="number-container"]'));          
        securityCode.load(this.template.querySelector('[data-id="securityCode-container"]'));
    }

    handlePayClick(){
    
        //Sample code from Cybersource: https://developer.cybersource.com/api/developer-guides/dita-flex/SAFlexibleToken/FlexMicroform/get-started/flex-getting-started-examples.html
        console.log('Handle Pay Click : '+this.selectedMonth);   
        var microform = this.microform;
        let monthVal = parseInt(this.selectedMonth);
        console.log('monthVal : '+monthVal);  
        //TODO - Need to refactor for long-term - Cybersource requires months < 10 to come through as double-digit
        if(monthVal < 10) {
            this.selectedMonth = '0' + String(monthVal);
            console.log('this.selectedMonth : '+this.selectedMonth);  
        }
        
        var options = {    
            expirationMonth: this.selectedMonth,  
            expirationYear: this.selectedYear
        };     
        console.log('options : '+JSON.stringify(options));               
        console.log(microform);
        var self = this;
        microform.createToken(options, function (err, token) {
            console.log('microform');           
            if (err) {
                //TODO - add error handling to display messages/etc.
                console.error(err);
                errorsOutput.textContent = err.message;
            } else {   
                console.log('submit');
                console.log(token);                  
                self.submitPayment(token);                          
            }
        });      
    }
    
    submitPayment(token){
        //TODO - add spinner to prevent form interaction while handling payment
        console.log('Submit Payment Called');
        console.log(token);
        console.log(this.cartId);
        console.log(this.orderId);
        console.log(this.selectedAddress);
        console.log(this.selectedMonth);
        console.log(this.selectedYear);
        console.log(this.cardholderName);
        handlePostPayment({ 
                            token:  token, 
                            cartId : this.cartId, 
                            orderId : this.orderId,  
                            addressId : this.selectedAddress,  
                            expirationMonth : this.selectedMonth, 
                            expirationYear : this.selectedYear, 
                            cardholderName : this.cardholderName}) 
        .then((result) => {
            console.log('result line 210 >>'+result+JSON.stringify(result));
            return this.submitPayment_Callback();            
           
        })
        .catch((error) => {
            this.error = error;               
        });
        
    }

    submitPayment_Callback(){
        // return (function(a){
        //     var state = a.getState(); 
        //     if (state === "SUCCESS") { 
                //Likely not needed but added in the event that this value was accidentally overridden (it is needed for the Flow)
                // this.selectedPaymentMethod = 'CardPayment';
                
                //Move the flow forward if the response is successfully
                // var navigate = this.navigateFlow;
                // navigate("NEXT");
        //     } else {
        //         //TODO - add error handling to display messages/etc.
        //         console.debug('Error occurred');
        //     }
        // });
        console.log('submit callback');
        this.selectedPaymentMethod = "CardPayment";
        console.log(this.selectedPaymentMethod);
        const navigateNextEvent = new FlowNavigationNextEvent();
        this.dispatchEvent(navigateNextEvent);
    }

}