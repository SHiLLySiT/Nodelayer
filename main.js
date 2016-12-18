'use strict';

const electron = require('electron');
const app = electron.app;
const BrowserWindow = electron.BrowserWindow;
const path = require('path');
const url = require('url');
const ipc = require('electron').ipcMain;

let mainWindow;

function init () {
    createCanvas();
    createToolbar();
}

function createCanvas() {
    var mainWindow = new BrowserWindow({
        width: 800,
        height: 600,
    });
    mainWindow.loadURL(url.format({
      pathname: path.join(__dirname, 'src/windows/canvas/canvas.html'),
      protocol: 'file:',
      slashes: true
    }))
    mainWindow.webContents.openDevTools();
    mainWindow.on('closed', function () {
      mainWindow = null;
    })
}

function createToolbar() {
    var toolBar = new BrowserWindow({
        parent: mainWindow,
        width: 200,
        height: 75,
        resizable: false,
        minimizable: false,
        maximizable: false,
    });
    toolBar.loadURL(url.format({
      pathname: path.join(__dirname, 'src/windows/toolbar/toolbar.html'),
      protocol: 'file:',
      slashes: true
    }))
    toolBar.setMenu(null);
    toolBar.isResizable(false);
}

app.on('ready', init);

app.on('window-all-closed', function () {
  if (process.platform !== 'darwin') {
    app.quit();
  }
})

app.on('activate', function () {
  if (mainWindow === null) {
    createWindow();
  }
})
