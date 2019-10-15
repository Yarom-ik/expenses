import { LightningElement, track } from 'lwc';

export default class Expenses extends LightningElement {

    @track login = true;
    @track employeePage = false;
    @track adminPage = false;

    show;
    showPage(){
        if (this.show === 1){
            this.login = false;
            this.employeePage =true;
            this.adminPage =false;
        }else if (this.show === 2){
            this.login = false;
            this.employeePage =false;
            this.adminPage =true;            
        }        
    }

    hanldeShowValueChange(event) {
        window.console.log('login = false '+ event.detail);
        this.show = event.detail;
        this.showPage();
    }

    authUser;
    hanldeSetAuthUser(event) {
        window.console.log('authUser= ' + JSON.stringify(event.detail));
        this.authUser = event.detail;
    }
}