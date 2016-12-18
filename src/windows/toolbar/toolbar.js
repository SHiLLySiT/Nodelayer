'use strict';

const ipc = require('electron').ipcRenderer;
const $ = require('jQuery');

$('#createBtn').click(function () {
    $('button').each(function() {
        $(this).removeClass('active');
    });
    $('#createBtn').addClass('active');
})

$('#connectBtn').click(function () {
    $('button').each(function() {
        $(this).removeClass('active');
    });
    $('#connectBtn').addClass('active');
})
