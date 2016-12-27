'use strict';

const ipc = require('electron').ipcRenderer;
const $ = require('jQuery');

let propContainer = $('#property-container');
let emptyMessage = $('#no-selection-message');
let loadedProperties = null;

// let prop = $('#template-string div:first-child');
// properties.append(prop);

function load(properties) {
    loadedProperties = properties;
    propContainer.empty();
    if (loadedProperties.length == 0) {
        emptyMessage.show();
        return;
    }

    emptyMessage.hide();
    for (let i = 0; i < loadedProperties.length; i++) {
        let prop = loadedProperties[i];

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
            // FIXME: if value is false, still getting flagged as true?
            template.find('#value').attr('checked', (prop.value) ? "checked" : "");
            template.find('input').change(onBooleanPropertyChanged);
        }

        propContainer.append(template);
    }
}

function onBooleanPropertyChanged(e) {
    console.log(e);
}

function isInteger(str) {
      return str.match(/[^$,.\d]/) == null;
}

function onIntegerPropertyChanged(e) {
    let index = $(e.currentTarget).attr('index');
    let value = $(e.currentTarget).val();

    if (!isInteger(value)) {
        $(e.currentTarget).val(0);
        value = 0;
    }

    ipc.send('property-changed', index, value);
}

function onIntegerIncrease(e) {
    let input = $(e.currentTarget).closest('.row').find('input');
    let index = input.attr('index');
    let value = parseInt(input.val());
    if (value < Number.MAX_SAFE_INTEGER) {
        value++;
        input.val(value);
        ipc.send('property-changed', index, value);
    }
}

function onIntegerDecrease(e) {
    let input = $(e.currentTarget).closest('.row').find('input');
    let index = input.attr('index');
    let value = parseInt(input.val());
    if (value > Number.MIN_SAFE_INTEGER) {
        value--;
        input.val(value);
        ipc.send('property-changed', index, value);
    }
}

function onStringPropertyChanged(e) {
    let index = $(e.currentTarget).attr('index');
    let value = $(e.currentTarget).val();
    ipc.send('property-changed', index, value);
}

ipc.on('selection-changed', function(event, properties) {
    load(properties);
});
