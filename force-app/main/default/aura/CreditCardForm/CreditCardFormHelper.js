({
    doInit : function(component, event) {
        console.log('doInit called');
        this.populatePicklists(component, event);
        this.makeApexCallout(component, event);
    },
    //TODO - Quick way to populate picklists (but long-term should be a cleaner approach)
    populatePicklists : function(component, event) {
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
        
        component.set("v.months", months);
        component.set("v.years", years);
    },
    makeApexCallout : function (component, event) {
        console.log('makeApexCallout called');
        var action = component.get("c.getComponentSetup");
        action.setCallback(this, this.makeApexCallout_Callback(component, event));
        action.setParams({ 
            cartId : component.get("v.cartId")
        });
        $A.enqueueAction(action);
    },
    makeApexCallout_Callback : function(component, event) {
        return (function(a){
            var state = a.getState(); 
            console.log('makeApexCallout_Callback called : ' + state);
            console.log(a.getReturnValue());
            if (state === "SUCCESS") {  
                this.handleResponse(component, a.getReturnValue());
            } else {
                //TODO - add error handling to display messages/etc.
                console.debug('Error occurred');
            }
        });
    },
    handleResponse : function(component, response) {
        console.log('handleResponse called');
        this.handleCardTypes(component, response.cardTypes);
        this.handleAddresses(component, response.addresses);
        this.setupForm(component, response.keyId);
    },
    handleCardTypes : function(component, cards) {
        let cardTypes = [];
        
        //TODO - CardType returned from Apex not returning detailed information - populate with dummy value for now
        cardTypes.push({"label" : "Visa", "value" : "Visa"});
        component.set("v.cardTypes", cardTypes);
    },
    handleAddresses : function(component, vals) {
        let addresses = [];

        for(let i = 0; i < vals.length; i++) {
            let currAddress = vals[i]; 
            let label = currAddress.Address.street + ", " + currAddress.Address.city + ", " + currAddress.Address.state + " " + currAddress.Address.postalCode + " " + currAddress.Address.country;
            
            addresses.push({'label' : label, 'value' : currAddress.Id})
        }

        component.set("v.addresses", addresses);
    },
    setupForm : function(component, captureContext) {
        //Sample code from Cybersource: https://developer.cybersource.com/api/developer-guides/dita-flex/SAFlexibleToken/FlexMicroform/get-started/flex-getting-started-examples.html
        var flex = new Flex(captureContext);  
        var microform = flex.microform({'input': {'line-height': '1.875rem'} });
        console.log('setupform');
        
        console.log(microform);
        component.set("v.microform", microform);
        
        var number = microform.createField('number', { placeholder: 'Enter a card number...' });
        var securityCode = microform.createField('securityCode', { placeholder: '•••' });
        number.load('#number-container');
        securityCode.load('#securityCode-container');
    },
    handlePayClick : function(component, event) {
        //Sample code from Cybersource: https://developer.cybersource.com/api/developer-guides/dita-flex/SAFlexibleToken/FlexMicroform/get-started/flex-getting-started-examples.html
        console.log('Handle Pay Click : ');
        var microform = component.get("v.microform");
        let monthVal = parseInt(component.get("v.selectedMonth"));
        
        //TODO - Need to refactor for long-term - Cybersource requires months < 10 to come through as double-digit
        if(monthVal < 10) {
            component.set("v.selectedMonth", "0" + String(monthVal));
        }
        
        var options = {    
            expirationMonth: component.get("v.selectedMonth"),  
            expirationYear: component.get("v.selectedYear")
        };     

        var self = this;
        this.component = component;
        
        microform.createToken(options, function (err, token) {
            if (err) {
                //TODO - add error handling to display messages/etc.
                console.error(err);
                errorsOutput.textContent = err.message;
            } else {    
                self.submitPayment(self.component, token);
            }
        });
    },
    submitPayment : function(component, token) {
        //TODO - add spinner to prevent form interaction while handling payment
        console.log('Submit Payment Called');
        var action = component.get("c.handlePostPayment");
        action.setCallback(this, this.submitPayment_Callback(component, event));
        action.setParams({ 
            token : token,
            cartId : component.get("v.cartId"),
            orderId : component.get("v.orderId"),
            addressId : component.get("v.selectedAddress"),
            expirationMonth : component.get("v.selectedMonth"),
            expirationYear : component.get("v.selectedYear"),
            cardholderName : component.get("v.cardholderName")
        });
        $A.enqueueAction(action);
    },
    submitPayment_Callback : function(component, event) {
        return (function(a){
            var state = a.getState(); 

            if (state === "SUCCESS") { 
                console.log('callback');
                //Likely not needed but added in the event that this value was accidentally overridden (it is needed for the Flow)
                component.set("v.selectedPaymentMethod", "CardPayment");
                
                //Move the flow forward if the response is successfully
                var navigate = component.get("v.navigateFlow");
                navigate("NEXT");
            } else {
                //TODO - add error handling to display messages/etc.
                console.debug('Error occurred');
            }
        });
    }
})