const ipc = require('electron').ipcMain;
const remote = require('electron').remote
const utils = require('../../utils');

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
    event.sender.webContents.send('template-created', template);
});

ipc.on('delete-template', function(event, uuid) {
    if (global.project.templates.hasOwnProperty(uuid)) {
        delete global.project.templates[uuid];
    }
    event.sender.webContents.send('template-deleted', uuid);
});

ipc.on('update-template', function(event, uuid, data) {
    let template = global.project.templates[uuid];
    if (template == null) {
        return;
    }
    if (data.hasOwnProperty('name')) {
        template.name = data.name;
    }
    event.sender.webContents.send('template-updated', template);
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
    event.sender.webContents.send('property-created', template, property);
});

ipc.on('delete-property', function(event, templateUUID, propertyUUID) {
    if (global.project.templates.hasOwnProperty(templateUUID)) {
        let template = global.project.templates[templateUUID];
        if (template.properties.hasOwnProperty(propertyUUID)) {
            delete template.properties[propertyUUID];
        }
    }
    event.sender.webContents.send('property-deleted', templateUUID, propertyUUID);
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
    if (data.hasOwnProperty('type')) {
        property.type = data.type;
    }
    if (data.hasOwnProperty('defaultValue')) {
        property.defaultValue = data.defaultValue;
    }
    event.sender.webContents.send('property-updated', template, property);
});
