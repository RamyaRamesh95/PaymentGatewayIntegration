({
    doInit : function(component, event, helper) {
        console.log('doInit clicked');
        helper.doInit(component, event);
    },
    handlePayClick : function(component, event, helper) {
      //  component.set("v.disableButton", true);
        console.log('Submit clicked');
        helper.handlePayClick(component, event);
    },
    handleCardTypeChange: function (component, event) {
        console.log('Card Type Dropdown Clicked');
        component.set("v.selectedCardType", event.getParam("value"));
    },
    handleMonthChange: function (component, event) {
        console.log('Handle Month Change Clicked');
        component.set("v.selectedMonth", event.getParam("value"));
    },
    handleYearChange: function (component, event) {
        console.log('Handle Year Change Clicked');
        component.set("v.selectedYear", event.getParam("value"));
    },
    handleAddressChange: function (component, event) {
        console.log('Handle Address Change Clicked');
        component.set("v.selectedAddress", event.getParam("value"));
    }
})