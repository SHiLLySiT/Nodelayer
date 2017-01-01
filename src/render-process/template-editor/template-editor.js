'use strict';

const electron = require('electron');
const remote = electron.remote;
const ipc = electron.ipcRenderer;
const $ = require('jQuery');

let templateList = $('#template-list');
templateList.find('#new').click(handleNewTemplateClick);

let templateEdit = $('#template-edit');
templateEdit.find('#back').click(handleTemplateBackClick);
templateEdit.find('#new').click(handleNewPropertyClick);
templateEdit.find('#delete').click(handleTemplateDeleteClick);
templateEdit.find('#delete').mouseleave(handleDeleteOut);
templateEdit.find('#delete').find('#confirm').hide();
templateEdit.find('#name').change(function(e) {
    ipc.send('update-template', currentTemplateUUID, { name:$(this).val() });
});

let propertyEdit = $('#property-edit');
propertyEdit.find('#delete').click(handlePropertyDeleteClick);
propertyEdit.find('#delete').mouseleave(handleDeleteOut);
propertyEdit.find('#delete').find('#confirm').hide();
propertyEdit.find('#back').click(handlePropertyBackClick);
propertyEdit.find("#name").change(function(e) {
    ipc.send('update-property', currentTemplateUUID, currentPropertyUUID, { name:$(this).val() });
});
propertyEdit.find("#type").change(function(e) {
    ipc.send('update-property', currentTemplateUUID, currentPropertyUUID, { type:$(this).val() });
});
propertyEdit.find("#defaultValue").change(function(e) {
    ipc.send('update-property', currentTemplateUUID, currentPropertyUUID, { defaultValue:$(this).val() });
});

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
            addProperty(template.properties[property]);
        }
    }

    templateList.hide();
    templateEdit.show();
}

ipc.on('template-updated', function(event, template) {
    let panel = templateList.find('.panel[uuid="' + template.uuid + '"]');
    panel.find('#name').text(template.name);
});

function handleDeleteOut() {
    $(this).find("#confirm").hide();
    $(this).find("#normal").show();
}

function handleTemplateDeleteClick() {
    let confirmIcon = $(this).find("#confirm");
    let normalIcon = $(this).find("#normal");
    let firstClick = normalIcon.is(":visible");
    if (firstClick) {
        normalIcon.hide();
        confirmIcon.show();
    } else {
        normalIcon.show();
        confirmIcon.hide();
        ipc.send('delete-template', currentTemplateUUID);
        handleTemplateBackClick();
    }
}

ipc.on('template-deleted', function(event, uuid) {
    let panel = templateList.find('.panel[uuid="' + uuid + '"]');
    panel.remove();
});

function handlePropertyDeleteClick() {
    let confirmIcon = $(this).find("#confirm");
    let normalIcon = $(this).find("#normal");
    let firstClick = normalIcon.is(":visible");
    if (firstClick) {
        normalIcon.hide();
        confirmIcon.show();
    } else {
        normalIcon.show();
        confirmIcon.hide();
        ipc.send('delete-property', currentTemplateUUID, currentPropertyUUID);
        handlePropertyBackClick();
    }
}

ipc.on('property-deleted', function(event, templateUUID, propertyUUID) {
    let panel = templateEdit.find('.panel[uuid="' + propertyUUID + '"]');
    panel.remove();
});

function handleTemplateBackClick() {
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
    property.find('#name').text(data.name);
    property.find('#type').text(data.type);
    property.find('#edit').click(handleEditProperty);
}

function handleEditProperty() {
    state = 'property';
    currentPropertyUUID = $(this).closest('.panel').attr('uuid');

    updateProperty();

    templateEdit.hide();
    propertyEdit.show();
}

function updateProperty() {
    let text = propertyEdit.find("#text");
    let checkbox = propertyEdit.find("#checkbox");
    let template = ipc.sendSync('request-template', currentTemplateUUID);
    let property = template.properties[currentPropertyUUID];

    propertyEdit.find("#name").val(property.name);
    propertyEdit.find("#type").val(property.type);

    if (property.type == 'boolean') {
        text.hide();
        checkbox.show();
        checkbox.find('#defaultValue').attr('checked', property.defaultValue);
    } else {
        text.show();
        checkbox.hide();
        text.find("#defaultValue").val(property.defaultValue);
    }
}

ipc.on('property-updated', function(event, template, property) {
    // update property in template edit
    let panel = templateEdit.find('.panel[uuid="' + property.uuid + '"]');
    panel.find('#name').text(property.name);
    panel.find('#type').text(property.type);
    // update property in property edit
    if (state == 'property' && property.uuid == currentPropertyUUID) {
        updateProperty();
    }
});

function handlePropertyBackClick() {
    state = 'template';
    currentPropertyUUID = null;
    templateEdit.show();
    propertyEdit.hide();
}
