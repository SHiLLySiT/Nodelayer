'use strict';

const ipc = require('electron').ipcRenderer;
const paper = require('paper');

// ----------------------------------------------------------------------- INIT
window.addEventListener('resize', function() {
    resizeCanvas();
});

function resizeCanvas() {
    paper.view.viewSize = new paper.Size(
        window.innerWidth - 20,
        window.innerHeight - 20
    );
}

paper.setup(document.getElementById('canvas'));
paper.view.onClick = onCanvasClick;
paper.view.onMouseDown = onCanvasDown;
paper.view.onMouseUp = onCanvasUp;

let layers = {
    connection: paper.project.activeLayer,
    node: new paper.Layer(),
};

resizeCanvas();

// ---------------------------------------------------------------------- UTILS
function getNode(uuid) {
    for (let i = 0; i < layers.node.children.length; i++) {
        let child = layers.node.children[i];
        if (child.data.uuid == uuid) {
            return child;
        }
    }
    return null;
}

function getConnection(uuid) {
    for (let i = 0; i < layers.connection.children.length; i++) {
        let child = layers.connection.children[i];
        if (child.data.uuid == uuid) {
            return child;
        }
    }
    return null;
}

// ---------------------------------------------------------------- SETUP TOOLS
let tools = {};
// create tools
tools.create = {
    activate: function() {
        this.dragging = {
            uuid: null,
            segments: [],
        }
    },

    deactivate: function() {

    },

    onNodeClick: function (e) {
        e.stopPropagation();
        let uuid = e.currentTarget.data.uuid;
        if (e.event.button == 0) {
            ipc.send('selection-changed', uuid);
        } else if (e.event.button == 2) {
            ipc.send('delete-node', uuid);
        }
    },

    onNodeDown: function(e) {
        if (e.event.button == 0) {
            this.dragging.uuid = e.target.data.uuid;
            // get all connections points so we dont have to constantly retrieve them
            let node = ipc.sendSync('request-node', this.dragging.uuid);
            for (let i = 0; i < node.connections.length; i++) {
                let cuuid = node.connections[i];
                let connection = ipc.sendSync('request-connection', cuuid);
                let paperConnection = getConnection(cuuid);
                // only move the end thats connected to the node being dragged
                let index = (connection.start == node.uuid) ? 0 : 1;
                let segment = paperConnection.segments[index];
                this.dragging.segments.push(segment);
            }
        }
    },

    onNodeDrag: function (e) {
        if (this.dragging.uuid) {
            let paperNode = e.target;
            paperNode.position.x = e.event.clientX;
            paperNode.position.y = e.event.clientY;
            for (let i = 0; i < this.dragging.segments.length; i++) {
                let segment = this.dragging.segments[i];
                segment.point.x = e.event.clientX;
                segment.point.y = e.event.clientY;
            }
        }
    },

    onNodeUp: function (e) {
        if (this.dragging.uuid) {
            ipc.send('update-node', this.dragging.uuid, { x:e.event.clientX, y:e.event.clientY });
            this.dragging.uuid = null;
            this.dragging.segments = [];
        }
    },

    onCanvasClick: function (e) {
        ipc.send('create-node', e.event.clientX, e.event.clientY);
    },
}

// connect tool
tools.connect = {
    activate: function() {
        this.startNode = null;
        this.tempLine = null;
    },

    deactivate: function() {

    },

    onNodeDown: function (e) {
        e.stopPropagation();
        let startX = e.currentTarget.position.x;
        let startY = e.currentTarget.position.y;
        this.startNode = e.currentTarget;
        layers.connection.activate();
        this.tempLine = new paper.Path();
        this.tempLine.strokeColor = 'red';
        this.tempLine.add(new paper.Point(startX, startY));
        this.tempLine.add(new paper.Point(e.event.clientX, e.event.clientY));
    },

    onNodeDrag: function (e) {
        let segment = this.tempLine.lastSegment.point;
        segment.x = e.event.clientX;
        segment.y = e.event.clientY;
        paper.view.update();
    },

    onNodeUp: function (e) {
        if (this.startNode != e.currentTarget) {
            let start = this.startNode.data.uuid;
            let end = e.currentTarget.data.uuid;
            ipc.send('create-connection', start, end);
            this.startNode = null;
        }
    },

    onCanvasUp: function (e) {
        if (this.tempLine) {
            this.tempLine.remove();
            this.tempLine = null;
        }
    },
}
// set current tool
tools.current = tools.create;
tools.current.activate();

// --------------------------------------------------------------------- EVENTS
function onNodeClick(e) {
    if (tools.current.onNodeClick) {
        tools.current.onNodeClick(e);
    }
}

function onNodeUp(e) {
    if (tools.current.onNodeUp) {
        tools.current.onNodeUp(e);
    }
}

function onNodeDown(e) {
    if (tools.current.onNodeDown) {
        tools.current.onNodeDown(e);
    }
}

function onNodeDrag(e) {
    if (tools.current.onNodeDrag) {
        tools.current.onNodeDrag(e);
    }
}

function onCanvasClick(e) {
    if (tools.current.onCanvasClick) {
        tools.current.onCanvasClick(e);
    }
}

function onCanvasUp(e) {
    if (tools.current.onCanvasUp) {
        tools.current.onCanvasUp(e);
    }
}

function onCanvasDown(e) {
    if (tools.current.onCanvasDown) {
        tools.current.onCanvasDown(e);
    }
}

// --------------------------------------------------------------------- EVENTS
ipc.on('connection-created', function(event, connection, start, end) {
    layers.connection.activate();
    let paperConnection = new paper.Path();
    paperConnection.strokeColor = 'black';
    paperConnection.add(new paper.Point(start.x, start.y));
    paperConnection.add(new paper.Point(end.x, end.y));
    paperConnection.data = {
        uuid: connection.uuid,
    };
});

ipc.on('connection-deleted', function(event, uuid) {
    let paperConnection = getConnection(uuid);
    paperConnection.remove();
});

ipc.on('node-updated', function(event, node) {
    let paperNode = getNode(node.uuid);
    paperNode.position.x = node.x;
    paperNode.position.y = node.y;
    // find all connections that have this node and update the endpoint
    for (let i = 0; i < node.connections.length; i++) {
        let cuuid = node.connections[i];
        let connection = ipc.sendSync('request-connection', cuuid);
        let paperConnection = getConnection(cuuid);
        // only update the end thats connected to the node updated
        let index = (connection.start == node.uuid) ? 0 : 1;
        let segment = paperConnection.segments[index];
        segment.point.x = node.x;
        segment.point.y = node.y;
    }
});

ipc.on('node-created', function(event, node) {
    layers.node.activate();
    let paperNode = new paper.Path.Circle(
        new paper.Point(node.x, node.y),
        16
    );
    paperNode.onClick = onNodeClick;
    paperNode.onMouseDown = onNodeDown;
    paperNode.onMouseUp = onNodeUp;
    paperNode.onMouseDrag = onNodeDrag;
    paperNode.fillColor = 'red';
    paperNode.data = {
        uuid: node.uuid,
    }
    paper.view.update();
});

ipc.on('node-deleted', function(event, uuid) {
    let paperNode = getNode(uuid);
    paperNode.remove();
});

ipc.on('tool-changed', function(event, tool) {
    tools.current.deactivate();
    tools.current = tools[tool];
    tools.current.activate();
});

ipc.on('property-changed', function(event, index, value) {
    
});
