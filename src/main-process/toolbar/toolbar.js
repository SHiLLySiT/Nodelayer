'use strict';

const electron = require('electron');
const ipc = electron.ipcMain;
const remote = require('electron').remote

//---------------------------------------------------------------------- EVENTS
ipc.on('tool-changed', function(event, tool) {
    global.window.canvas.webContents.send('tool-changed', tool);
});
