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
            width:800,
            height:600,
        },
        null,
        false
    );

    createWindow(
        'tools',
        'src/windows/toolbar/toolbar.html',
        {
            parent: global.window.canvas,
            x: global.window.canvas.getPosition()[0],
            y: global.window.canvas.getPosition()[1] + 50,
            width: 200,
            height: 75,
            resizable: false,
            minimizable: false,
            maximizable: false,
        },
        null,
        false
    );

    createWindow(
        'inspector',
        'src/windows/inspector/inspector.html',
        {
            parent: global.window.canvas,
            x: global.window.canvas.getPosition()[0],
            y: global.window.canvas.getPosition()[1] + 150,
            minWidth: 300,
            minHeight: 200,
            width: 300,
            height: 500,
            minimizable: false,
            maximizable: false,
        },
        null,
        false
    );

    createWindow(
        'template',
        'src/windows/template-editor/template-editor.html',
        {
            parent: global.window.canvas,
            x: global.window.canvas.getPosition()[0] + 300,
            y: global.window.canvas.getPosition()[1] + 50,
            width: 300,
            height: 500,
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
        window.openDevTools({mode:'detach'});
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
