import { LightningElement, track } from 'lwc';

import getMouthlyExpense from '@salesforce/apex/AdminController.getMouthlyExpense';

export default class AdminPage extends LightningElement {

    selectedYear = 2019;
    @track monthlyExpense = [];

    connectedCallback() {
        this.loadMontlyExpense();
    }

    loadMontlyExpense() {
        getMouthlyExpense({ selectedDate: this.selectedYear })
          .then(result => {
            this.monthlyExpense = [];
            this.monthlyExpense = result;
            window.console.log('monthlyExpense ' + JSON.stringify(this.monthlyExpense));
    
          })
          .catch(error => {
            this.error = error;
            this.monthlyExpense = undefined;
          });
      }
}