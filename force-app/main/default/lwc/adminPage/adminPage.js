import { LightningElement, track } from 'lwc';

import getMouthlyExpense from '@salesforce/apex/AdminController.getMouthlyExpense';

export default class AdminPage extends LightningElement {

    // selectedYear = 2019;
    @track monthlyExpense = [];
    @track dates4years = [];

    @track selectedYear = new Date().getFullYear();

    handleChange(event) {
      this.selectedYear = Number(event.detail.value);
      window.console.log('value= ' + this.selectedYear);
      this.monthlyExpense = [];
      this.loadMontlyExpense();
    }

    connectedCallback() {
        this.loadMontlyExpense();
        for (let i = -2; i <= 1; i++) {

            this.dates4years.push({
              label: 'Regional Expenses ' + (new Date().getFullYear() + i).toString(),
              value: new Date().getFullYear() + i
            });
          
        }
        window.console.log('dates- ' + this.dates4years);
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