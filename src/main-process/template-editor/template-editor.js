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

ipc.on('update-template', function(event, uuid, data) {
    let template = global.project.templates[uuid];
    if (template == null) {
        return;
    }
    template.name = data.name;
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
        value: "",
    };
    template.properties[property.uuid] = property;
    event.sender.webContents.send('property-created', template, property);
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
    property.name = data.name;
    property.type = data.type;
    property.value = data.value;
    event.sender.webContents.send('property-updated', template, property);
});
