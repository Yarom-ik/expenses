import { LightningElement, track, api } from 'lwc';

import getMouthlyExpense from '@salesforce/apex/ExpensesController.getMouthlyExpense';
import getExpenseCard from '@salesforce/apex/ExpensesController.getExpenseCard';
import saveExpenseCard from '@salesforce/apex/ExpensesController.saveExpenseCard';
import deleteExpenseCard from '@salesforce/apex/ExpensesController.deleteExpenseCard';
import addBalance from '@salesforce/apex/ExpensesController.addBalance';

import { updateRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import DESCRIPTION_FIELD from '@salesforce/schema/ExpenseCard__c.Description__c';
import AMOUNT_FIELD from '@salesforce/schema/ExpenseCard__c.Amount__c';
import ID_FIELD from '@salesforce/schema/ExpenseCard__c.Id';

const COLS = [
  { label: 'Description', fieldName: 'Description__c', fixedWidth: 180, editable: true },
  { label: 'Amount', fieldName: 'Amount__c', type: 'currency', fixedWidth: 90, editable: true },
  { label: 'Action', type: 'button', fixedWidth: 90, typeAttributes: { variant: 'base', label: 'Delete', name: 'delete', onclick: 'deleteExpenseCard' } }
];

export default class EmployeePage extends LightningElement {

  @track error;
  @track messageCard;

  @api authUser;

  @track monthlyExpense;
  @track expensesCard = [];
  newExpenseCard = { 'sobjectType': 'ExpenseCard__c' };

  @track columns = COLS;
  @track draftValues = [];

  @track openmodel = false;
  @track openmodelBalance = false;
  @track dateNow;

  dates4years = [];

  selectMounth;
  selectedYear = new Date().getFullYear();
  selectedDate;

  balanceAdd;
  runAddBalance = undefined;

  @track loadDataSpinner = false;

  openmodal() {
    this.dateNow = new Date().toISOString();
    this.openmodel = true;
  }

  closeModal() {
    this.openmodel = false;
  }

  logoutUser() {
    localStorage.removeItem('authUser');
    const selectedEvent = new CustomEvent("showvaluechange", {
      detail: 0
    });
    this.dispatchEvent(selectedEvent);
  }

  openmodalBalance() {
    if (this.selectMounth === undefined || this.runAddBalance === undefined) {
      this.dispatchEvent(
        new ShowToastEvent({
          title: 'Error',
          message: 'No selected month',
          variant: 'error'
        })
      );
    } else {
      this.openmodelBalance = true;
    }
  }

  closeModalBalance() {
    this.openmodelBalance = false;
  }

  handleSetInputModalBalance(event) {
    if (event.target.name === 'summ') {
      this.balanceAdd = event.target.value;
    }
  }

  handleAddBalance() {
    let inputSumm = this.template.querySelector(".inputSumm");
    let value = inputSumm.value;
    if (value === "") {
      inputSumm.setCustomValidity("Please enter Summ");
    } else {
      inputSumm.setCustomValidity("");
    }
    inputSumm.reportValidity();
    if (!inputSumm.checkValidity()) {
      return;
    }
    addBalance({ selectedDate: this.selectMounth, conId: this.authUser.Id, addBalance: this.balanceAdd })
      .then(() => {
        this.dispatchEvent(
          new ShowToastEvent({
            title: 'Success',
            message: 'Balance is updated',
            variant: 'success'
          })
        );
        this.balanceAdd = 0;
        this.loadMontlyExpense();
        this.closeModalBalance();
      }
      )
      .catch(error => {
        this.error = error;
      });
  }

  loadMontlyExpense() {
    getMouthlyExpense({ conId: this.authUser.Id, selectedDate: this.selectedYear })
      .then(result => {
        this.monthlyExpense = [];
        this.monthlyExpense = result;
      })
      .catch(error => {
        this.error = error;
        this.monthlyExpense = undefined;
      });
  }

  connectedCallback() {
    this.loadMontlyExpense();
    for (let i = -2; i <= 1; i++) {
      if (this.selectedYear === new Date().getFullYear() + i) {
        this.dates4years.push({
          pItem: new Date().getFullYear() + i,
          classList: 'slds-button slds-button_brand'
        });
      } else {
        this.dates4years.push({
          pItem: new Date().getFullYear() + i,
          classList: 'slds-button slds-button_neutral'
        });
      }
    }
  }

  showExpenseCard(event) {
    this.selectMounth = event.target.value;
    this.selectedDate = new Date(this.selectMounth);
    this.selectedDate.setFullYear(this.selectedYear);
    const allTabs = this.template.querySelectorAll('ul>button');
    allTabs.forEach((elm) => {
      elm.classList.remove("slds-is-active");
    })
    event.currentTarget.classList.add('slds-is-active');
    this.loadDataExpenseCard();
  }

  selectYearButton(event) {
    this.selectedYear = event.target.value;
    this.selectMounth = "";
    const allTabs = this.template.querySelectorAll('div>button');
    this.loadMontlyExpense();
    this.expensesCard = [];
    allTabs.forEach((elm) => {
      elm.classList.remove("slds-button_brand");
      elm.classList.add("slds-button_neutral");
    })
    event.currentTarget.classList.add('slds-button_brand');
    //clear select button month
    const allTabsYear = this.template.querySelectorAll('ul>button');
    allTabsYear.forEach((elm) => {
      elm.classList.remove("slds-is-active");
    })
  }

  loadDataExpenseCard() {
    this.loadDataSpinner = true;
    getExpenseCard({ selectedDate: this.selectedDate, conId: this.authUser.Id })
      .then(result => {
        if (result) {
          this.expensesCard = [];
          this.expensesCard = result;
          this.loadDataSpinner = false;
          this.messageCard = undefined;
          this.runAddBalance = true;
        } else {
          this.expensesCard = [];
          this.loadDataSpinner = false;
          this.messageCard = 'No data for selected month!';
          this.runAddBalance = undefined;
        }

      })
      .catch(error => {
        this.dispatchEvent(
          new ShowToastEvent({
            title: 'Error load card',
            message: 'error.body.message EC-' + error,
            variant: 'error'
          })
        );
        this.expensesCard = undefined;       
      });
  }

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
        // Display refresh data in the datatable
        this.loadMontlyExpense();
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
    if (window.confirm('Are you sure to DELETE?'))
      deleteExpenseCard({ expenseCardId: event.detail.row.Id })
        .then(() => {
          this.dispatchEvent(
            new ShowToastEvent({
              title: 'Success',
              message: 'Expense Card deleted',
              variant: 'success',
            }),
          );
          this.loadMontlyExpense();
          this.loadDataExpenseCard();
        })
        .catch((error) => {
          this.error = error;
          this.contacts = undefined;
          this.dispatchEvent(
            new ShowToastEvent({
              title: 'Error Delete Expense Card',
              message: error.body.message,
              variant: 'error',
            }),
          );
        });
  }

  handleSetInputModal(event) {
    if (event.target.name === 'amount') {
      this.newExpenseCard.Amount__c = event.target.value;
    }
    else if (event.target.name === 'date') {
      this.newExpenseCard.CardDate__c = event.target.value;
    }
    else if (event.target.name === 'description') {
      this.newExpenseCard.Description__c = event.target.value;
    }
  }

  handleSaveExpenseCard() {
    var inputAmount = this.template.querySelector(".inputAmount");
    var value = inputAmount.value;
    if (value === "") {
      inputAmount.setCustomValidity("Please enter Amount");
    } else {
      inputAmount.setCustomValidity("");
    }
    inputAmount.reportValidity();
    let inputDate = this.template.querySelector(".inputDate");
    if (inputDate.value === "") {
      inputDate.setCustomValidity("Please select date");
    } else {
      inputDate.setCustomValidity("");
    }
    inputDate.reportValidity();
    let inputDescription = this.template.querySelector(".inputDescription");
    if (inputDescription.value === undefined || inputDescription.value === " ") {
      inputDescription.setCustomValidity("Please enter description");
    } else {
      inputDescription.setCustomValidity("");
    }
    inputDescription.reportValidity();
    if (!inputAmount.checkValidity() || !inputDate.checkValidity() || !inputDescription.checkValidity()) {
      return;
    }
    if (this.newExpenseCard.CardDate__c === undefined) {
      this.newExpenseCard.CardDate__c = this.dateNow;
    }
    this.newExpenseCard.CardKeeper__c = this.authUser.Id;
    saveExpenseCard({ expenseCard: this.newExpenseCard })
      .then(result => {
        if (result === "ok") {
          this.newExpenseCard = {};
          this.dispatchEvent(new ShowToastEvent({
            title: 'Success!!',
            message: 'ExpenseCard Created Successfully!!',
            variant: 'success'
          }));
          this.closeModal();
          this.loadMontlyExpense();
          this.loadDataExpenseCard();
        }
      })
      .catch(error => {
        // Show error messsage
        this.dispatchEvent(new ShowToastEvent({
          title: 'Error!!',
          message: error.message,
          variant: 'error'
        }));
      });
  }
}