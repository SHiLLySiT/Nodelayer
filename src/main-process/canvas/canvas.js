'use strict';

const electron = require('electron');
const ipc = electron.ipcMain;
const utils = require('../../utils');

//---------------------------------------------------------------------- INIT
global.project.nodes = {};
global.project.connections = {};

//----------------------------------------------------------------------- UTILS
function areNodesConnected(a, b) {
    if (a.connections.length == 0 || b.connections.length == 0) {
        return false;
    }
    for (let i = 0; i < a.connections.length; i++) {
        let uuid = a.connections[i];
        let connection = global.project.connections[uuid];
        if (connection.start == b.uuid || connection.end == b.uuid) {
            return true;
        }
    }
    return false;
}

function removeConnection(node, connectionUUID) {
    let index = node.connections.indexOf(connectionUUID);
    if (index != -1) {
        node.connections.splice(index, 1);
    }
}

// ---------------------------------------------------------------------- NODES
ipc.on('request-node', function(event, uuid) {
    event.returnValue = global.project.nodes[uuid];
});

ipc.on('create-node', function(event, x, y) {
    let node = {
        uuid: utils.generateUUID(),
        template: null,
        x:x,
        y:y,
        properties: {},
        connections: [],
    }
    global.project.nodes[node.uuid] = node;
    global.window.canvas.webContents.send('node-created', node);
});

ipc.on('delete-node', function(event, uuid) {
    if (global.project.nodes.hasOwnProperty(uuid)) {
        // we must delete all connections of this node first
        let node = global.project.nodes[uuid];
        for (let i = node.connections.length - 1; i >= 0; i--) {
            let cuuid = node.connections[i];
            // delete references to connection
            let connection = global.project.connections[cuuid];
            let start = global.project.nodes[connection.start];
            removeConnection(start, cuuid);
            let end = global.project.nodes[connection.end];
            removeConnection(end, cuuid);
            // delete connection
            delete global.project.connections[cuuid];
            global.window.canvas.webContents.send('connection-deleted', cuuid);
        }
        // finally delete node
        delete global.project.nodes[uuid];
        global.window.canvas.webContents.send('node-deleted', uuid);
    }
});

ipc.on('update-node', function(event, uuid, data) {
    let node = global.project.nodes[uuid];
    if (data.hasOwnProperty('x')) {
        node.x = data.x;
    }
    if (data.hasOwnProperty('y')) {
        node.y = data.y;
    }
    global.window.canvas.webContents.send('node-updated', node);
});

// ---------------------------------------------------------------- CONNECTIONS
ipc.on('request-connection', function(event, uuid) {
    event.returnValue = global.project.connections[uuid];
});

ipc.on('create-connection', function(event, startUUID, endUUID) {
    let start = global.project.nodes[startUUID];
    let end = global.project.nodes[endUUID];
    if (areNodesConnected(start, end)) {
        return;
    }

    let connection = {
        uuid: utils.generateUUID(),
        start: startUUID,
        end: endUUID,
    }

    start.connections.push(connection.uuid);
    end.connections.push(connection.uuid);
    global.project.connections[connection.uuid] = connection;
    global.window.canvas.webContents.send('connection-created', connection, start, end);
});

ipc.on('delete-connection', function(event, uuid) {
    if (global.project.connections.hasOwnProperty(uuid)) {
        let start = global.project.nodes[connection.start];
        let end = global.project.nodes[connection.end];
        removeConnection(start, uuid);
        removeConnection(end, uuid);
        delete global.project.connections[uuid];
        global.window.canvas.webContents.send('connection-deleted', uuid);
    }
});

ipc.on('update-connection', function(event, properties) {
    // TODO: update connection - do we even need this?
    global.window.canvas.webContents.send('connection-updated');
});
