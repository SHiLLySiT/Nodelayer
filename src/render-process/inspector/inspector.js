'use strict';

const ipc = require('electron').ipcRenderer;
const $ = require('jQuery');

let selectedContainer = $('#selection-container');
selectedContainer.find('#template-selection').change(function(e) {
    let uuid = $(this).find("option:selected").attr('uuid');
    // TODO: update properties on selected node
})

let noSelectionContainer = $('#no-selection-container');
let propContainer = $('#property-container');
let nodeUUID = null;

// init
noSelectionContainer.show();
selectedContainer.hide();

function load(properties) {
    propContainer.empty();
    for (let i = 0; i < node.properties.length; i++) {
        let prop = node.properties[i];

        let template = $('#template-' + prop.type).clone();
        template.show();

        template.find('#label').text(prop.label + ':');
        template.find('input').attr('index', i);

        if (prop.type == 'string') {
            template.find('#value').val(prop.value);
            template.find('input').change(onStringPropertyChanged);
        } else if (prop.type == 'integer') {
            template.find('#value').val(prop.value);
            template.find('input').change(onIntegerPropertyChanged);
            template.find('#increase').click(onIntegerIncrease);
            template.find('#decrease').click(onIntegerDecrease);
        } else if (prop.type == 'boolean') {
            template.find('#value').attr('checked', prop.value);
            template.find('input').change(onBooleanPropertyChanged);
        }

        propContainer.append(template);
    }
}

function onBooleanPropertyChanged(e) {
    let index = $(this).attr('index');
    let value = $(this).is(":checked");
    ipc.send('property-changed', index, value);
}

function onIntegerPropertyChanged(e) {
    let index = $(this).attr('index');
    let value = $(this).val();
    ipc.send('property-changed', index, value);
}

function onIntegerIncrease(e) {
    let input = $(this).closest('.row').find('input');
    let index = input.attr('index');
    let value = parseInt(input.val());
    value++;
    input.val(value);
    ipc.send('property-changed', index, value);
}

function onIntegerDecrease(e) {
    let input = $(this).closest('.row').find('input');
    let index = input.attr('index');
    let value = parseInt(input.val());
    value--;
    input.val(value);
    ipc.send('property-changed', index, value);
}

function onStringPropertyChanged(e) {
    let index = $(this).attr('index');
    let value = $(this).val();
    ipc.send('property-changed', index, value);
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
    let node = ipc.sendSync('request-node', nodeUUID);
    load(node);
});

ipc.on('selection-changed', function(event, node) {
    nodeUUID = node.uuid;
    if (node == null) {
        noSelectionContainer.show();
        selectedContainer.hide();
    } else {
        noSelectionContainer.hide();
        selectedContainer.show();
        load(node);
    }
});
