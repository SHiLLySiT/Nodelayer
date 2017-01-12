'use strict';

const electron = require('electron');
const ipc = electron.ipcMain;

ipc.on('request-node', function(event, uuid) {
    event.returnValue = global.project.getNode(uuid);
});

ipc.on('create-node', function(event, x, y) {
    let node = global.project.createNode(x, y);
    global.window.canvas.webContents.send('node-created', node);
});

ipc.on('delete-node', function(event, uuid) {
    // we must delete all connections of this node first
    let node = global.project.getNode(uuid);
    for (let i = node.connections.length - 1; i >= 0; i--) {
        let cuuid = node.connections[i];
        global.project.deleteConnection(uuid);
        global.window.canvas.webContents.send('connection-deleted', uuid);
    }
    // finally delete node
    global.project.deleteNode(uuid);
    global.window.canvas.webContents.send('node-deleted', uuid);
});

ipc.on('update-node', function(event, uuid, data) {
    let node = global.project.updateNode(uuid, data);
    global.window.canvas.webContents.send('node-updated', node);
});

// ---------------------------------------------------------------- CONNECTIONS
ipc.on('request-connection', function(event, uuid) {
    event.returnValue = global.project.getConnection(uuid);
});

ipc.on('create-connection', function(event, startUUID, endUUID) {
    let start = global.project.getNode(startUUID);
    let end = global.project.getNode(endUUID);
    let connection = global.project.createConnection(startUUID, endUUID);
    global.window.canvas.webContents.send('connection-created', connection, start, end);
});

ipc.on('delete-connection', function(event, uuid) {
    global.project.deleteConnection(uuid);
    global.window.canvas.webContents.send('connection-deleted', uuid);
});

ipc.on('update-connection', function(event, uuid, data) {
    let connection = global.project.updateConnection(uuid, data);
    global.window.canvas.webContents.send('connection-updated', connection);
});
