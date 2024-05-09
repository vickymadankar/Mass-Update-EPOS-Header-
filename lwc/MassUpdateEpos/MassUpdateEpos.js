/**
 * @Description       : This lwc accepts a CSV file with a header containing EPOS Ids only. 
 *                    : Up to 10,000 record updates can be supported by this component in a single transaction.
 *                    : If there are any invalid, incorrect Ids, the component will generate an excel file 
 *                    : containing the invalid, incorrect Ids.
 * @Created Date      : 30-4-2024
 * @Author            : Vicky Madankar             
 * @last modified by  : Vicky.Madankar@Perficient.com
 * Modifications Log 
 * Ver   Date         Author                              Modification
 * 1.0   05-6-2023   Vicky.Madankar@Perficient.com     Initial Version
**/

import { LightningElement, track } from 'lwc';
import { loadScript } from 'lightning/platformResourceLoader';
import updateEposRecords from '@salesforce/apex/EposMassUpdateController.updateEposRecords';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import sheetjs from '@salesforce/resourceUrl/sheetjs';

export default class MassUpdateEpos extends LightningElement {

    isFileUploaded = false;
    @track data;
    @track fileName = '';
    @track showSpinner = false;
    selectedCheckboxes = [];
    filesUploaded = [];
    file;
    fileContents;
    fileReader;
    MAX_FILE_SIZE = 1500000;

    connectedCallback() {
        loadScript(this, sheetjs).then(() => {
            console.log('Script Loaded Successfully');
        }).catch(error => {
            console.error('Error loading static resource', error);
        })
    }

    handleCheckboxChange(event) {
        const { name, checked } = event.target;
        if (checked) {
            this.selectedCheckboxes.push(name);
            console.log('CHECKED name', this.name);
            console.log('selected ', this.selectedCheckboxes);
        } else {
            const index = this.selectedCheckboxes.indexOf(name);
            if (index !== -1) {
                this.selectedCheckboxes.splice(index, 1);
            }
        }
    }

    handleFilesChange(event) {
        if (event.target.files.length > 0) {
            this.filesUploaded = event.target.files;
            this.fileName = event.target.files[0].name;
            this.isFileUploaded = true;
        }
    }

    handleSave() {
        if (this.filesUploaded.length > 0) {
            this.uploadHelper();
        } else {
            this.fileName = 'Please select a CSV file to upload!!';
        }

    }

    uploadHelper() {
        this.file = this.filesUploaded[0];
        if (this.file.size > this.MAX_FILE_SIZE) {
            console.alert('File Size is too large');
            return;
        }
        this.showSpinner = true;
        this.fileReader = new FileReader();
        this.fileReader.onloadend = (() => {
            this.fileContents =this.modifyCSVData(this.fileReader.result);
            console.log('Modified CSV BULK== ',this.fileContents);
            this.saveToFile();
        });
        this.fileReader.readAsText(this.file);
    }

    saveToFile() {
        var csvDataWithCommas = this.fileContents.replaceAll("\r\n", ",").slice(0, -1);
        updateEposRecords({ csvData: csvDataWithCommas, selectedCheckboxes: this.selectedCheckboxes })
            .then(result => {
                console.log('CSV===', csvDataWithCommas);
                this.data = result;
                this.fileName = this.fileName + ' - Consumed Successfully';
                this.showSpinner = false;
                this.showToast('Success',' Updated Successfully!!!', 'success', 'dismissable');
                this.isFileUploaded = false;
                this.parseValidateAndExportToExcel(csvDataWithCommas);
            })
            .catch(error => {
                console.error('Error updating EPOS records', error);
                this.showToast('Error', 'Failed to update EPOS records', 'error', 'sticky');
                this.showSpinner = false;
            });
    }

    // Function to parse CSV data and validate IDs
    parseAndValidateCSV(csvData) {
        const rows = csvData.split('\n');
        console.log('Rows in PARSE= ',rows);
        const invalidIds = [];
        // Iterate over each row of the CSV data
        rows.forEach(row => {
            const id = row.trim();
            console.log('Id in PARSE= ', id);
            if (id) {
                if (!this.isValidId(id)) {
                    invalidIds.push(id);
                    console.log('Invalid Ids', invalidIds);
                }
            }
        });
        return {
            invalidIds: invalidIds,
        };
    }

    // Function to validate if ID is alphanumeric and 18 characters long
    isValidId(id) {
        return /^[a-zA-Z0-9]{18}$/.test(id);

    }

    modifyCSVData(csvData) {
        const rows = csvData.split('\n');
        rows.shift();
        const modifiedRows= rows.map(row=>{
            const columns= row.split(',');
            return columns[0];
        });
        console.log('In Modified CSV== ',modifiedRows);
        return modifiedRows.join('\n');
    }


    // Function to parse CSV data, validate IDs, and export to Excel if needed
    parseValidateAndExportToExcel(csvData) {
        // Parse CSV data and validate IDs
        const { invalidIds} = this.parseAndValidateCSV(csvData);
        console.log('CSV data==', csvData);
        console.log('Exported Invalid Ids', invalidIds);
       
        // Check if there are any invalid, incomplete, or duplicate IDs
        const hasIssues = invalidIds.length > 0 ;

        if (hasIssues) {
            // Prepare data for export to Excel
            console.log('Exporting issues to excel');
            const exportData = [];
            if (invalidIds.length > 0) {
                exportData.push(['Invalid IDs'].concat(invalidIds));
            }
            
            // Create Excel file
            const wb = XLSX.utils.book_new();
            const ws = XLSX.utils.aoa_to_sheet(exportData);
            XLSX.utils.book_append_sheet(wb, ws, 'Issues');
            try {
                XLSX.writeFile(wb, 'EPOS_Invalid_IDs_Report.xlsx');
            } catch (error) {
                console.error('Error in Exporting file', error);
            }
        }
    }


    showToast(title, message, variant, mode) {
        const toastEvent = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
            mode: mode
        });
        this.dispatchEvent(toastEvent);
    }
}
