'use strict';

const electron = require('electron');
const ipc = electron.ipcMain;
const BrowserWindow = electron.BrowserWindow;
const path = require('path');
const url = require('url');
const remote = require('electron').remote

//---------------------------------------------------------------------- WINDOW
var window = new BrowserWindow({
    parent: global.window.canvas,
    x: global.window.canvas.getPosition()[0],
    y: global.window.canvas.getPosition()[1] + 50,
    width: 200,
    height: 75,
    resizable: false,
    minimizable: false,
    maximizable: false,
});
window.loadURL(url.format({
  pathname: path.join(__dirname, '../../windows/toolbar/toolbar.html'),
  protocol: 'file:',
  slashes: true
}))
window.setMenu(null);
//window.openDevTools({mode:'detach'});
global.window.toolbar = window;

//---------------------------------------------------------------------- EVENTS
ipc.on('tool-changed', function(event, tool) {
    global.window.canvas.webContents.send('tool-changed', tool);
});
