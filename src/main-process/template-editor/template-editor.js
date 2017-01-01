'use strict';

const electron = require('electron');
const ipc = electron.ipcMain;
const BrowserWindow = electron.BrowserWindow;
const path = require('path');
const url = require('url');
const utils = require('../../utils');

//------------------------------------------------------------------------ INIT
global.project.templates = {};

//---------------------------------------------------------------------- WINDOW
var window = new BrowserWindow({
    parent: global.window.canvas,
    x: global.window.canvas.getPosition()[0] + 300,
    y: global.window.canvas.getPosition()[1] + 50,
    width: 300,
    height: 500,
    resizable: false,
    minimizable: false,
    maximizable: false,
});
window.loadURL(url.format({
  pathname: path.join(__dirname, '../../windows/template-editor/template-editor.html'),
  protocol: 'file:',
  slashes: true
}))
window.setMenu(null);
//window.openDevTools({mode:'detach'});
global.window.template = window;

//---------------------------------------------------------------------- EVENTS
ipc.on('request-template', function(event, uuid) {
    event.returnValue = global.project.templates[uuid];
});

ipc.on('create-template', function(event) {
    let template = {
        uuid: utils.generateUUID(),
        name: "New Template",
        properties: {},
    }
    global.project.templates[template.uuid] = template;
    global.window.template.webContents.send('template-created', template);
    global.window.inspector.webContents.send('template-created', template);
});

ipc.on('delete-template', function(event, uuid) {
    if (global.project.templates.hasOwnProperty(uuid)) {
        delete global.project.templates[uuid];
    }
    global.window.template.webContents.send('template-deleted', uuid);
    global.window.inspector.webContents.send('template-deleted', uuid);
});

ipc.on('update-template', function(event, uuid, data) {
    let template = global.project.templates[uuid];
    if (template == null) {
        return;
    }
    if (data.hasOwnProperty('name')) {
        template.name = data.name;
    }
    global.window.template.webContents.send('template-updated', template);
    global.window.inspector.webContents.send('template-updated', template);
});

ipc.on('create-property', function(event, templateUUID) {
    let template = global.project.templates[templateUUID];
    if (template == null) {
        return;
    }
    let property = {
        uuid: utils.generateUUID(),
        name: "New Property",
        type: "string",
        defaultValue: "",
    };
    template.properties[property.uuid] = property;
    // add property to nodes
    for (let n in global.project.nodes) {
        let node = global.project.nodes[n];
        if (node.template == templateUUID) {
            if (!node.properties.hasOwnProperty(property.uuid)) {
                node.properties[property.uuid] = {
                    value: property.defaultValue,
                }
            }
        }
    }
    global.window.template.webContents.send('property-created', template, property);
    global.window.inspector.webContents.send('property-created', template, property);
});

ipc.on('delete-property', function(event, templateUUID, propertyUUID) {
    if (global.project.templates.hasOwnProperty(templateUUID)) {
        let template = global.project.templates[templateUUID];
        if (template.properties.hasOwnProperty(propertyUUID)) {
            delete template.properties[propertyUUID];
        }
    }
    // remove property from nodes
    for (let n in global.project.nodes) {
        let node = global.project.nodes[n];
        if (node.template == templateUUID) {
            if (node.properties.hasOwnProperty(propertyUUID)) {
                delete node.properties[propertyUUID];
            }
        }
    }
    global.window.template.webContents.send('property-deleted', templateUUID, propertyUUID);
    global.window.inspector.webContents.send('property-deleted', templateUUID, propertyUUID);
});

ipc.on('update-property', function(event, templateUUID, propertyUUID, data) {
    let template = global.project.templates[templateUUID];
    if (template == null) {
        return;
    }
    let property = template.properties[propertyUUID];
    if (property == null) {
        return;
    }
    if (data.hasOwnProperty('name')) {
        property.name = data.name;
    }
    if (data.hasOwnProperty('defaultValue')) {
        property.defaultValue = data.defaultValue;
        if (property.type == 'integer') {
            if (!utils.isInteger(property.defaultValue)) {
                property.defaultValue = 0;
            }
        }
    }
    if (data.hasOwnProperty('type')) {
        property.type = data.type;
        // update default value if type changes
        if (property.type == 'boolean') {
            property.defaultValue = false;
        } else if (property.type == 'integer') {
            property.defaultValue = 0;
        } else if (property.type == 'string') {
            property.defaultValue = "";
        }
    }
    global.window.template.webContents.send('property-updated', template, property);
    global.window.inspector.webContents.send('property-updated', template, property);
});
