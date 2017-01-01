'use strict';

const electron = require('electron');
const ipc = electron.ipcMain;
const remote = require('electron').remote

global.currentTool = 'create';

//---------------------------------------------------------------------- EVENTS
ipc.on('request-tool', function(event) {
    event.returnValue = global.currentTool;
});

ipc.on('tool-changed', function(event, tool) {
    global.currentTool = tool;
    global.window.canvas.webContents.send('tool-changed', tool);
});
