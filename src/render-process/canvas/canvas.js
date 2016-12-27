'use strict';

const ipc = require('electron').ipcRenderer;
const paper = require('paper');

paper.setup(document.getElementById('canvas'));
paper.view.onClick = onCanvasClick;
paper.view.onMouseDown = onCanvasDown;
paper.view.onMouseUp = onCanvasUp;

let layerConnection = paper.project.activeLayer;
let layerNode = new paper.Layer();

// ----------------------------------------------------------------------- UTIL
function areNodesConnected(a, b) {
    if (a.data.connections.length == 0) {
        return false;
    }
    for (let i = 0; i < a.data.connections.length; i++) {
        let c = a.data.connections[i];
        if (c.data.start == b || c.data.end == b) {
            return true;
        }
    }
    return false;
}

function connectNodes(a, b) {
    layerConnection.activate();
    let connection = new paper.Path();
    connection.strokeColor = 'black';
    connection.add(new paper.Point(a.position.x, a.position.y));
    connection.add(new paper.Point(b.position.x, b.position.y));
    connection.data = { start:a, end:b };
    a.data.connections.push(connection);
    b.data.connections.push(connection);
}

// ---------------------------------------------------------------- SETUP TOOLS
let tools = {};
// create tools
tools.create = {
    onNodeClick: function (e) {
        e.stopPropagation();
        if (e.event.button == 0) {
            ipc.send('selection-changed', null);
        } else if (e.event.button == 2) {
            let node = e.target;
            for (let i = 0; i < node.data.connections.length; i++) {
                let c = node.data.connections[i];
                let other = (c.data.start == node) ? c.data.end : c.data.start;
                let index = other.data.connections.indexOf(c);
                if (index != -1) {
                    other.data.connections.splice(index, 1);
                }
                c.remove();
            }
            node.remove();
        }
    },

    onNodeDrag: function (e) {
        let node = e.target;
        node.position.x = e.event.clientX;
        node.position.y = e.event.clientY;
        for (let i = 0; i < node.data.connections.length; i++) {
            let c = node.data.connections[i];
            let segmentIndex = (c.data.start == node) ? 0 : 1;
            let point = c.segments[segmentIndex].point;
            point.x = e.event.clientX;
            point.y = e.event.clientY;
        }
    },

    onCanvasClick: function (e) {
        layerNode.activate();
        let node = new paper.Path.Circle(
            new paper.Point(e.event.clientX, e.event.clientY),
            16
        );
        node.onClick = onNodeClick;
        node.onMouseDown = onNodeDown;
        node.onMouseUp = onNodeUp;
        node.onMouseDrag = onNodeDrag;
        node.fillColor = 'red';
        node.data = {
            connections:[],
        }
        paper.view.update();
    },
}

// connect tool
tools.connect = {
    onNodeDown: function (e) {
        e.stopPropagation();
        let startX = e.currentTarget.position.x;
        let startY = e.currentTarget.position.y;
        this.startNode = e.currentTarget;
        layerConnection.activate();
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
        let endNode = e.currentTarget;
        if (this.startNode != endNode
        && !areNodesConnected(this.startNode, endNode)) {
            connectNodes(this.startNode, endNode);
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

ipc.on('tool-changed', function(event, tool) {
    tools.current = tools[tool];
});

window.addEventListener('resize', function() {
    paper.view.viewSize = new paper.Size(
        window.innerWidth - 20,
        window.innerHeight - 20
    );
});
