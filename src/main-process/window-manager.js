'use strict';

const electron = require('electron');
const ipc = electron.ipcMain;
const BrowserWindow = electron.BrowserWindow;
const Menu = electron.Menu;
const path = require('path');
const url = require('url');

// ----------------------------------------------------------------------- INIT
global.window = {};
showCanvas();
showToolbar();
showTemplate();
showInspector();

// -------------------------------------------------------------------- WINDOWS
function showCanvas() {
    // window
    let window = new BrowserWindow({
        width:800,
        height:600,
    });
    window.loadURL(url.format({
      pathname: path.join(__dirname, '../windows/canvas/canvas.html'),
      protocol: 'file:',
      slashes: true
    }))
    window.on('closed', function () {
      global.window.canvas = null;
    })
    //window.openDevTools({mode:'detach'});
    global.window.canvas = window;

    // menu
    let template = [
        {
            label: 'File',
            submenu: [{
                label: 'Quit',
                click () { console.log("Quit"); },
            }],
        },
        {
            label: 'Window',
            submenu: [
                {
                    label: 'Show Toolbar',
                    click () {
                        if (!global.window.toolbar) {
                            showToolbar();
                        }
                    },
                },
                {
                    label: 'Show Inspector',
                    click () {
                        if (!global.window.inspector) {
                            showInspector();
                        }
                    },
                },
                {
                    label: 'Show Template Editor',
                    click () {
                        if (!global.window.template) {
                            showTemplate();
                        }
                    },
                },
            ],
        }
    ];
    let menu = Menu.buildFromTemplate(template);
    window.setMenu(menu);
}

function showToolbar() {
    let window = new BrowserWindow({
        parent: global.window.canvas,
        x: global.window.canvas.getPosition()[0],
        y: global.window.canvas.getPosition()[1] + 50,
        width: 200,
        height: 75,
        resizable: false,
        minimizable: false,
        maximizable: false,
    });
    window.on('closed', function () {
      global.window.toolbar = null;
    });
    window.loadURL(url.format({
      pathname: path.join(__dirname, '../windows/toolbar/toolbar.html'),
      protocol: 'file:',
      slashes: true
    }));
    window.setMenu(null);
    //window.openDevTools({mode:'detach'});
    global.window.toolbar = window;
}

function showInspector() {
    let window = new BrowserWindow({
        parent: global.window.canvas,
        x: global.window.canvas.getPosition()[0],
        y: global.window.canvas.getPosition()[1] + 150,
        minWidth: 300,
        minHeight: 200,
        width: 300,
        height: 500,
        minimizable: false,
        maximizable: false,
    });
    window.on('closed', function () {
      global.window.inspector = null;
    });
    window.loadURL(url.format({
      pathname: path.join(__dirname, '../windows/inspector/inspector.html'),
      protocol: 'file:',
      slashes: true
    }));
    window.setMenu(null);
    //window.openDevTools({mode:'detach'});
    global.window.inspector = window;
}

function showTemplate() {
    let window = new BrowserWindow({
        parent: global.window.canvas,
        x: global.window.canvas.getPosition()[0] + 300,
        y: global.window.canvas.getPosition()[1] + 50,
        width: 300,
        height: 500,
        resizable: false,
        minimizable: false,
        maximizable: false,
    });
    window.on('closed', function () {
      global.window.template = null;
    });
    window.loadURL(url.format({
      pathname: path.join(__dirname, '../windows/template-editor/template-editor.html'),
      protocol: 'file:',
      slashes: true
    }));
    window.setMenu(null);
    //window.openDevTools({mode:'detach'});
    global.window.template = window;
}
