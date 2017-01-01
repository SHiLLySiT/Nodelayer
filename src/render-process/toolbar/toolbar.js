'use strict';

const ipc = require('electron').ipcRenderer;
const $ = require('jQuery');

$('#create').click(function () {
    deactivateAll();
    $(this).addClass('active');
    ipc.send('tool-changed', 'create');
});

$('#connect').click(function () {
    deactivateAll();
    $(this).addClass('active');
    ipc.send('tool-changed', 'connect');
});

init();

function init() {
    let tool = ipc.sendSync('request-tool');
    $('#' + tool).addClass('active');
}

function deactivateAll() {
    $('button').each(function() {
        $(this).removeClass('active');
    });
}
