'use strict';

const electron = require('electron');
const ipc = electron.ipcMain;

ipc.on('request-templates', function(event) {
    event.returnValue = global.project.getTemplates();
});

ipc.on('request-template', function(event, uuid) {
    event.returnValue = global.project.getTemplate(uuid);
});

ipc.on('create-template', function(event) {
    let template = global.project.createTemplate();
    if (global.window.template) {
        global.window.template.webContents.send('template-created', template);
    }
    if (global.window.inspector) {
        global.window.inspector.webContents.send('template-created', template);
    }
});

ipc.on('delete-template', function(event, uuid) {
    global.project.deleteTemplate(uuid);
    if (global.window.template) {
        global.window.template.webContents.send('template-deleted', uuid);
    }
    if (global.window.inspector) {
        global.window.inspector.webContents.send('template-deleted', uuid);
    }
});

ipc.on('update-template', function(event, uuid, data) {
    let template = global.project.updateTemplate(uuid, data);
    if (global.window.template) {
        global.window.template.webContents.send('template-updated', template);
    }
    if (global.window.inspector) {
        global.window.inspector.webContents.send('template-updated', template);
    }
});

ipc.on('create-property', function(event, templateUUID) {
    let template = global.project.getTemplate(templateUUID);
    let property = global.project.createProperty(templateUUID);
    if (global.window.template) {
        global.window.template.webContents.send('property-created', template, property);
    }
    if (global.window.inspector) {
        global.window.inspector.webContents.send('property-created', template, property);
    }
});

ipc.on('delete-property', function(event, templateUUID, propertyUUID) {
    global.project.deleteProperty(templateUUID, propertyUUID);
    if (global.window.template) {
        global.window.template.webContents.send('property-deleted', templateUUID, propertyUUID);
    }
    if (global.window.inspector) {
        global.window.inspector.webContents.send('property-deleted', templateUUID, propertyUUID);
    }
});

ipc.on('update-property', function(event, templateUUID, propertyUUID, data) {
    let template = global.project.getTemplate(templateUUID);
    let property = global.project.updateProperty(templateUUID, propertyUUID, data);
    if (global.window.template) {
        global.window.template.webContents.send('property-updated', template, property);
    }
    if (global.window.inspector) {
        global.window.inspector.webContents.send('property-updated', template, property);
    }
});
