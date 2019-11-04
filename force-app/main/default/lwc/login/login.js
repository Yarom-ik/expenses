import { LightningElement, track } from 'lwc';

import EXPENSES_LOGO from '@salesforce/resourceUrl/Logo';

// Importing Apex Class method
import runLoginUser from '@salesforce/apex/ExpensesController.loginUser';

export default class Login extends LightningElement {
    logoUrl = EXPENSES_LOGO;

    @track error;
    @track message;

    authUser = {};
    login;
    password;

    showPageValue;
    showPage() {
        // Creates the event with the data next step.
        const selectedEvent = new CustomEvent("showvaluechange", {
            detail: this.showPageValue
        });
        // Dispatches the event.
        this.dispatchEvent(selectedEvent);
    }

    //get input login and password
    setLoginPassword(event) {
        if (event.target.name === 'login') {
            this.login = event.target.value;
        }
        else if (event.target.name === 'password') {
            this.password = event.target.value;
        }
    }

    handleLoginUser() {
        let inputLogin = this.template.querySelector(".login");
        let inputPassword = this.template.querySelector(".inpPassword");
        let valueLogin = inputLogin.value;
        let valuePassword = inputPassword.value;
        if (valueLogin === '' || valueLogin === undefined) {
            inputLogin.setCustomValidity("Please enter login");
        } else {
            inputLogin.setCustomValidity("");
        }
        inputLogin.reportValidity();
        if (valuePassword === '' || valuePassword === undefined) {
            inputPassword.setCustomValidity("Please enter password");
        } else {
            inputPassword.setCustomValidity("");
        }
        inputPassword.reportValidity();
        if ((!inputLogin.validity.valid) || (!inputPassword.validity.valid)) {
            return;
        }
        runLoginUser({ login: this.login, pass: this.password })
            .then(result => {
                if (result && result != null) {
                    this.authUser = result;
                    if (this.authUser.Admin__c === true) {
                        this.showPageValue = 2;
                    } else if (this.authUser.Admin__c === false) {
                        this.showPageValue = 1;
                    }
                    localStorage.setItem('authUser', JSON.stringify(this.authUser));
                    this.showPage();
                    this.sendContact();
                } 
            })
            .catch(error => {
                this.error = error.message;
                this.message = 'Login or password incorrect';
            });
    }

    sendContact() {
        // Creates the event with the data authUser.
        const selectedEvent = new CustomEvent("setauthuser", {
            detail: this.authUser
        });
        // Dispatches the event.
        this.dispatchEvent(selectedEvent);
    }

}