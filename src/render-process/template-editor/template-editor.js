'use strict';

const electron = require('electron');
const remote = electron.remote;
const ipc = electron.ipcRenderer;
const $ = require('jQuery');

let templateList = $('#template-list');
templateList.find('#new').click(handleNewTemplateClick);

let templateEdit = $('#template-edit');
templateEdit.find('#back').click(handleTemplateBackClick);
templateEdit.find('#delete').click(handleTemplateDeleteClick);
templateEdit.find('#new').click(handleNewPropertyClick);
templateEdit.find('#name').change(function(e) {
    ipc.send('update-template', currentTemplateUUID, { name:$(this).val() });
});

let propertyEdit = $('#property-edit');
propertyEdit.find('#back').click(handlePropertyBackClick);

let currentTemplateUUID = null;
let currentPropertyUUID = null;

// values: list, template, property
let state = 'list';

// init
templateEdit.hide();
propertyEdit.hide();

function handleNewTemplateClick() {
    ipc.send('create-template');
}

ipc.on('template-created', function(event, data) {
    addTemplate(data);
});

function addTemplate(data) {
    let template = templateList.find('#template').find('div').first().clone();
    templateList.find('#list').append(template);
    template.attr('uuid', data.uuid);
    template.find('#name').text(data.name);
    template.find('#edit').click(handleEditTemplateClick);
}

function handleEditTemplateClick(e) {
    state = 'template';
    currentTemplateUUID = $(this).closest('.panel').attr('uuid');
    let template = ipc.sendSync('request-template', currentTemplateUUID)

    templateEdit.find('#name').val(template.name);

    templateEdit.find('#list').empty();
    for (let property in template.properties) {
        if (template.properties.hasOwnProperty(property)) {
            addProperty(property);
        }
    }

    templateList.hide();
    templateEdit.show();
}

ipc.on('template-updated', function(event, template) {
    let panel = templateList.find('.panel[uuid="' + template.uuid + '"]');
    let name = panel.find('#name');
    name.text(template.name);
});

function handleTemplateDeleteClick(e) {
    $(this).closest('#deleteModal').show();
}

function handleTemplateBackClick(e) {
    state = 'list';
    currentTemplateUUID = null;
    templateList.show();
    templateEdit.hide();
}

function handleNewPropertyClick() {
    ipc.send('create-property', currentTemplateUUID);
}

ipc.on('property-created', function(event, template, property) {
    if (state == 'template' && template.uuid == currentTemplateUUID) {
        addProperty(property);
    }
});

function addProperty(data) {
    let property = templateEdit.find('#template').find('div').first().clone();
    templateEdit.find('#list').append(property);
    property.attr('uuid', data.uuid);
    property.find('#name').val(data.name);
    property.find('#type').val(data.type);
    property.find('#edit').click(handleEditProperty);
}

function handlePropertyBackClick() {
    state = 'property';
    currentPropertyUUID = $(this).closest('.panel').attr('uuid');
    let template = ipc.sendSync('request-template', currentTemplateUUID)
    let property = template.properties[currentPropertyUUID];
    console.log(currentPropertyUUID);
    console.log(template);
    console.log(property);
    propertyEdit.find("#name").val(property.name);
    propertyEdit.find("#type").val(property.type);
    propertyEdit.find("#defaultValue").val(property.defaultValue);

    templateEdit.hide();
    propertyEdit.show();
}

function handlePropertyEditBack() {
    state = 'template';
    currentPropertyUUID = null;
    templateEdit.show();
    propertyEdit.hide();
}
