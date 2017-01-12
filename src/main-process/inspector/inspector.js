'use strict';

const electron = require('electron');
const ipc = electron.ipcMain;
const utils = require('../../utils');

//------------------------------------------------------------------------ INIT
global.selection = null;

//---------------------------------------------------------------------- EVENTS
ipc.on('request-selection', function(event) {
    event.returnValue = global.selection;
});

ipc.on('selection-changed', function(event, uuid) {
    let node = global.project.getNode(uuid);
    global.selection = node;
    if (global.window.inspector) {
        global.window.inspector.webContents.send('selection-changed', node);
    }
});

ipc.on('change-node-template', function(event, nodeUUID, templateUUID) {
    let node = global.project.getNode(nodeUUID);
    node.template = templateUUID;
    node.properties = {};

    if (templateUUID != null) {
        let template = global.project.getTemplate(templateUUID);
        for (let p in template.properties) {
            if (template.properties.hasOwnProperty(p)) {
                let property = template.properties[p];
                node.properties[p] = {
                    value: property.defaultValue,
                }
            }
        }
    }
    if (global.window.inspector) {
        global.window.inspector.webContents.send('node-template-changed', node);
    }
});

ipc.on('property-changed', function(event, nodeUUID, propertyUUID, value) {
    let node = global.project.getNode(nodeUUID);
    let property = node.properties[propertyUUID];
    property.value = value;
    // TODO: vailidate value
});
