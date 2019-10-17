import { LightningElement, track, api } from 'lwc';

import getMouthlyExpense from '@salesforce/apex/ExpensesController.getMouthlyExpense';
import getExpenseCard from '@salesforce/apex/ExpensesController.getExpenseCard';

import { updateRecord } from 'lightning/uiRecordApi';
//import { refreshApex } from '@salesforce/apex';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import DESCRIPTION_FIELD from '@salesforce/schema/ExpenseCard__c.Description__c';
import AMOUNT_FIELD from '@salesforce/schema/ExpenseCard__c.Amount__c';
import ID_FIELD from '@salesforce/schema/ExpenseCard__c.Id';

const COLS = [
  { label: 'Description', fieldName: 'Description__c', editable: true },
  { label: 'Amount', fieldName: 'Amount__c', type: 'phone', editable: true },
  { label: 'Action', type: 'button', typeAttributes: { variant: 'base', label: 'Delete', name: 'delete', onclick: 'deleteExpenseCard' } }
];

export default class EmployeePage extends LightningElement {

  @api authUser;

  @track monthlyExpense;

  loadData() {
    getMouthlyExpense({ conId: this.authUser.Id })
      .then(result => {
        this.monthlyExpense = result;

      })
      .catch(error => {
        this.error = error;
        this.monthlyExpense = undefined;
      });
  }

  connectedCallback() {
    window.console.log('run load ' + this.authUser.Id);
    this.loadData();
    for (let i = -2; i <= 1; i++) {
      this.dates4years.push(new Date().getFullYear() + i);
    }
    this.loadDataExpenseCard();
  }

  dates4years = [];

  selectMounth;
  selectedYear = new Date().getFullYear();

  showM(event) {
    window.console.log('SelectedYear = ' + this.selectedYear);
    window.console.log('selectedMounth - ' + event.target.name);
    this.selectMounth = event.target.name;
  }

  @track expensesCard = [];

  loadDataExpenseCard() {
    getExpenseCard({})
      .then(result => {
        //this.expensesCard = result;
        window.console.log('ExpensesCards=' + JSON.stringify(result));
        this.expensesCard = [];
        for (let key in result) {
          // Preventing unexcepted data
          if (result.hasOwnProperty(key)) { // Filtering the data in the loop
            this.expensesCard.push({ key: key, value: result[key] });
          }
        }
        window.console.log('ExpensesCardsRETURN=' + JSON.stringify(this.expensesCard));

      })
      .catch(error => {
        this.error = error;
        this.expensesCard = undefined;
      });
  }

  @track columns = COLS;
  @track draftValues = [];

  handleSave(event) {
    const fields = {};
    fields[ID_FIELD.fieldApiName] = event.detail.draftValues[0].Id;
    fields[DESCRIPTION_FIELD.fieldApiName] = event.detail.draftValues[0].Description__c;
    fields[AMOUNT_FIELD.fieldApiName] = event.detail.draftValues[0].Amount__c;

    const recordInput = { fields };

    updateRecord(recordInput)
      .then(() => {
        this.dispatchEvent(
          new ShowToastEvent({
            title: 'Success',
            message: 'ExpenseCard updated',
            variant: 'success'
          })
        );
        // Clear all draft values
        this.draftValues = [];
        // Display fresh data in the datatable
        this.loadDataExpenseCard();
      }).catch(error => {
        this.dispatchEvent(
          new ShowToastEvent({
            title: 'Error creating record',
            message: error.body.message,
            variant: 'error'
          })
        );
      });
  }

  deleteExpenseCard(event) {
    // eslint-disable-next-line no-alert
    alert('DELETE??' + event.detail.row.Id);
  }

  handleSum() {

    var el = this.template.querySelector('lightning-datatable');
    // eslint-disable-next-line no-console
    console.log('el = ' + el);
    let selected = el.getSelectedRows();
    // eslint-disable-next-line no-console
    console.log('selected = ' + selected);


    let table = this.template.querySelector(".sss");

    window.console.log('SUM ' + table);
  }
}