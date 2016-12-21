'use strict';

const electron = require('electron');
const app = electron.app;
const BrowserWindow = electron.BrowserWindow;
const path = require('path');
const glob = require('glob');
const url = require('url');

function init () {
    // include all files in main-process dir
    var files = glob.sync(path.join(__dirname, 'src/main-process/**/*.js'));
    files.forEach(function (file) {
        require(file);
    });

    // create windows
    global.window = {};
    createWindow(
        'canvas',
        'src/windows/canvas/canvas.html',
        {
            width:800, height:600
        },
        null,
        true
    );

    createWindow(
        'tools',
        'src/windows/toolbar/toolbar.html',
        {
            parent: global.window.canvas,
            width: 200,
            height: 75,
            resizable: false,
            minimizable: false,
            maximizable: false,
        },
        null,
        false
    );
}

function createWindow (id, pathStr, options, menu, showDevTools) {
    var window = new BrowserWindow(options);
    window.loadURL(url.format({
      pathname: path.join(__dirname, pathStr),
      protocol: 'file:',
      slashes: true
    }))
    window.on('closed', function () {
      global.window[id] = null;
    })
    window.setMenu(menu);
    if (showDevTools) {
        window.openDevTools();
    }
    global.window[id] = window;
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
