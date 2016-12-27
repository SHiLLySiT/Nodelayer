'use strict';

const ipc = require('electron').ipcRenderer;
const $ = require('jQuery');

// let properties = $('#property-container');
// let prop = $('#template-string div:first-child');
// properties.append(prop);

ipc.on('selection-changed', function(event, data) {
    console.log("selection changed");
});
