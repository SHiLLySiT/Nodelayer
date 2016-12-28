'use strict';

const ipc = require('electron').ipcRenderer;
const $ = require('jQuery');

let templateList = $('#template-list');
$('#newTemplate').click(createTemplate);

function createTemplate() {
    
}
