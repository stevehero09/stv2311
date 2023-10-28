// accountAFIInfo.js
import { LightningElement, api, wire } from 'lwc';
import getMostRecentAFI from '@salesforce/apex/AFIController.getMostRecentAFI';

export default class AccountAFIInfo extends LightningElement {
    @api recordId;
    afiRecord;
    error;

    @wire(getMostRecentAFI, { accountId: '$recordId' })
    wiredAFI({ error, data }) {
        if (data) {
            this.afiRecord = data;
            this.error = undefined;
        } else if (error) {
            this.error = error;
            this.afiRecord = undefined;
        }
    }
}