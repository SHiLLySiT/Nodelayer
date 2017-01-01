'use strict';

const electron = require('electron');
const app = electron.app;
const BrowserWindow = electron.BrowserWindow;
const path = require('path');
const glob = require('glob');
const url = require('url');

function init () {
    // session data
    global.project = {};
    global.window = {};

    // include all files in main-process dir
    var files = glob.sync(path.join(__dirname, 'src/main-process/**/*.js'));
    files.forEach(function (file) {
        require(file);
    });
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
