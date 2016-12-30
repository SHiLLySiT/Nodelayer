const ipc = require('electron').ipcMain;
const remote = require('electron').remote
const utils = require('../../utils');

global.project.templates = {};

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
    global.window.template.webContents.send('property-created', template, property);
});

ipc.on('delete-property', function(event, templateUUID, propertyUUID) {
    if (global.project.templates.hasOwnProperty(templateUUID)) {
        let template = global.project.templates[templateUUID];
        if (template.properties.hasOwnProperty(propertyUUID)) {
            delete template.properties[propertyUUID];
        }
    }
    global.window.template.webContents.send('property-deleted', templateUUID, propertyUUID);
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
});
