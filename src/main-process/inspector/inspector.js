'use strict';

const electron = require('electron');
const ipc = electron.ipcMain;
const BrowserWindow = electron.BrowserWindow;
const path = require('path');
const url = require('url');
const utils = require('../../utils');

//---------------------------------------------------------------------- WINDOW
var window = new BrowserWindow({
    parent: global.window.canvas,
    x: global.window.canvas.getPosition()[0],
    y: global.window.canvas.getPosition()[1] + 150,
    minWidth: 300,
    minHeight: 200,
    width: 300,
    height: 500,
    minimizable: false,
    maximizable: false,
});
window.loadURL(url.format({
  pathname: path.join(__dirname, '../../windows/inspector/inspector.html'),
  protocol: 'file:',
  slashes: true
}))
window.setMenu(null);
//window.openDevTools({mode:'detach'});
global.window.inspector = window;

//---------------------------------------------------------------------- EVENTS
ipc.on('selection-changed', function(event, uuid) {
    let node = global.project.nodes[uuid];
    global.window.inspector.webContents.send('selection-changed', node);
});

ipc.on('change-node-template', function(event, nodeUUID, templateUUID) {
    let node = global.project.nodes[nodeUUID];
    node.template = templateUUID;
    node.properties = {};

    if (templateUUID != null) {
        let template = global.project.templates[templateUUID];
        for (let p in template.properties) {
            if (template.properties.hasOwnProperty(p)) {
                let property = template.properties[p];
                node.properties[p] = {
                    value: property.defaultValue,
                }
            }
        }
    }
    global.window.inspector.webContents.send('node-template-changed', node);
});

ipc.on('property-changed', function(event, nodeUUID, propertyUUID, value) {
    let node = global.project.nodes[nodeUUID];
    let property = node.properties[propertyUUID];
    property.value = value;
    // TODO: vailidate value
});
