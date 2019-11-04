import { LightningElement, track } from 'lwc';

export default class Expenses extends LightningElement {

    @track login = false;
    @track employeePage = false;
    @track adminPage = false;

    authUser;
    show;

    connectedCallback() {
        this.authUser = JSON.parse(localStorage.getItem('authUser'));
        if (this.authUser !== null) {
            if (this.authUser.Admin__c === false) {
                this.employeePage = true;
                this.adminPage = false;
                this.login = false;
            } else if (this.authUser.Admin__c === true) {
                this.adminPage = true;
                this.employeePage = false;
                this.login = false;
            }
        } else {
            this.login = true;
            this.employeePage = false;
            this.adminPage = false;
        }
    }

    showPage() {
        if (this.show === 1) {
            this.login = false;
            this.employeePage = true;
            this.adminPage = false;
        } else if (this.show === 2) {
            this.login = false;
            this.employeePage = false;
            this.adminPage = true;
        }
        else {
            this.login = true;
            this.employeePage = false;
            this.adminPage = false;
        }
    }

    hanldeShowValueChange(event) {
        this.show = event.detail;
        this.showPage();
    }

    hanldeSetAuthUser(event) {
        this.authUser = event.detail;
    }
}