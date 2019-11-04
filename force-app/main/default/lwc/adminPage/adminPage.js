import { LightningElement, track } from 'lwc';

import getMouthlyExpense from '@salesforce/apex/AdminController.getMouthlyExpense';

export default class AdminPage extends LightningElement {

  @track monthlyExpense = [];
  @track dates4years = [];

  @track selectedYear = new Date().getFullYear();

  handleChange(event) {
    this.selectedYear = Number(event.detail.value);
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
  }

  logoutUser() {
    localStorage.removeItem('authUser');
    // Creates the event with the data next step.
    const selectedEvent = new CustomEvent("showvaluechange", {
      detail: 0
    });
    // Dispatches the event.
    this.dispatchEvent(selectedEvent);
  }

  loadMontlyExpense() {
    getMouthlyExpense({ selectedDate: this.selectedYear })
      .then(result => {
        this.monthlyExpense = [];
        this.monthlyExpense = result;
      })
      .catch(error => {
        this.error = error;
        this.monthlyExpense = undefined;
      });
  }
}