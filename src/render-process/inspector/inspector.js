'use strict';

const ipc = require('electron').ipcRenderer;
const $ = require('jQuery');

let selectedContainer = $('#selection-container');
selectedContainer.find('#template-selection').change(function(e) {
    let templateUUID = $(this).find("option:selected").attr('uuid');
    ipc.send('change-node-template', nodeUUID, templateUUID);
})

let noSelectionMsg = $('#no-selection-msg');
let noTemplateMsg = $('#no-template-msg');
let noPropertiesMsg = $('#no-properties-msg');
let propContainer = $('#property-container');
let nodeUUID = null;

// init
noSelectionMsg.show();
noTemplateMsg.hide();
noPropertiesMsg.hide();
selectedContainer.hide();

function load(node) {
    propContainer.empty();
    if (node.template == null) {
        selectedContainer.find('#template-selection').find("#value").val('');
        noTemplateMsg.show();
        noPropertiesMsg.hide();
    } else {
        let template = ipc.sendSync('request-template', node.template);
        selectedContainer.find('#template-selection').find("#value").val(template.name);
        noTemplateMsg.hide();

        let hasProperties = false;
        for (let p in template.properties) {
            if (template.properties.hasOwnProperty(p)) {
                hasProperties = true;
                let nodeProp = node.properties[p];
                let templateProp = template.properties[p];

                let container = $('#template-' + templateProp.type).clone();
                container.show();

                container.find('#label').text(templateProp.name + ':');
                container.find('input').attr('uuid', templateProp.uuid);

                if (templateProp.type == 'string') {
                    container.find('#value').val(nodeProp.value);
                    container.find('input').change(onStringPropertyChanged);
                } else if (templateProp.type == 'integer') {
                    container.find('#value').val(nodeProp.value);
                    container.find('input').change(onIntegerPropertyChanged);
                    container.find('#increase').click(onIntegerIncrease);
                    container.find('#decrease').click(onIntegerDecrease);
                } else if (templateProp.type == 'boolean') {
                    container.find('#value').attr('checked', nodeProp.value);
                    container.find('input').change(onBooleanPropertyChanged);
                }

                propContainer.append(container);
            }
        }

        if (hasProperties) {
            noPropertiesMsg.hide();
        } else {
            noPropertiesMsg.show();
        }
    }
}

function onBooleanPropertyChanged(e) {
    let propUUID = $(this).attr('uuid');
    let value = $(this).is(":checked");
    ipc.send('property-changed', nodeUUID, propUUID, value);
}

function onIntegerPropertyChanged(e) {
    let propUUID = $(this).attr('uuid');
    let value = $(this).val();
    ipc.send('property-changed', nodeUUID, propUUID, value);
}

function onIntegerIncrease(e) {
    let input = $(this).closest('.row').find('input');
    let propUUID = input.attr('uuid');
    let value = parseInt(input.val());
    value++;
    input.val(value);
    ipc.send('property-changed', nodeUUID, propUUID, value);
}

function onIntegerDecrease(e) {
    let input = $(this).closest('.row').find('input');
    let propUUID = input.attr('uuid');
    let value = parseInt(input.val());
    value--;
    input.val(value);
    ipc.send('property-changed', nodeUUID, propUUID, value);
}

function onStringPropertyChanged(e) {
    let propUUID = $(this).attr('uuid');
    let value = $(this).val();
    ipc.send('property-changed', nodeUUID, propUUID, value);
}

ipc.on('template-created', function(event, template) {
    let templateList = selectedContainer.find('#template-selection').find('#value');
    templateList.append('<option uuid="' + template.uuid + '">' + template.name + '</p>');
});

ipc.on('template-deleted', function(event, uuid) {
    let templateList = selectedContainer.find('#template-selection').find('#value');
    let option = templateList.find('option[uuid="' + uuid + '"]');
    option.remove();
});

ipc.on('template-updated', function(event, template) {
    let templateList = selectedContainer.find('#template-selection').find('#value');
    let option = templateList.find('option[uuid="' + template.uuid + '"]');
    option.text(template.name);
    if (nodeUUID != null) {
        let node = ipc.sendSync('request-node', nodeUUID);
        load(node);
    }
});

ipc.on('property-created', function(event, template, property) {
    if (nodeUUID != null) {
        let node = ipc.sendSync('request-node', nodeUUID);
        if (node.template == template.uuid) {
             load(node);
        }
    }
});

ipc.on('property-deleted', function(event, templateUUID, propertyUUID) {
    if (nodeUUID != null) {
        let node = ipc.sendSync('request-node', nodeUUID);
        if (node.template == templateUUID) {
            load(node);
        }
    }
});

ipc.on('property-updated', function(event, template, property) {
    if (nodeUUID != null) {
        let node = ipc.sendSync('request-node', nodeUUID);
        if (node.template == template.uuid) {
            load(node);
        }
    }
});

ipc.on('selection-changed', function(event, node) {
    nodeUUID = node.uuid;
    if (node == null) {
        noSelectionMsg.show();
        selectedContainer.hide();
    } else {
        noSelectionMsg.hide();
        selectedContainer.show();
        load(node);
    }
});

ipc.on('node-template-changed', function(event, node) {
    if (nodeUUID == node.uuid) {
        load(node);
    }
});
