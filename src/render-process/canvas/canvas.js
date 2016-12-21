'use strict';

const ipc = require('electron').ipcRenderer;
const paper = require('paper');

var tools = {};
var canvas = document.getElementById('canvas');
paper.setup(canvas);
paper.view.onClick = onCanvasClick;
paper.view.onMouseDown = onCanvasDown;
paper.view.onMouseUp = onCanvasUp;

// ---------------------------------------------------------------- SETUP TOOLS
// create tool
tools.create = {
    onNodeClick: function (e) {
        e.stopPropagation();
        e.target.remove();
    },

    onNodeDrag: function (e) {
        e.target.position.x = e.event.clientX;
        e.target.position.y = e.event.clientY;
    },

    onCanvasClick: function (e) {
        var path = new paper.Path.Circle(new paper.Point(e.event.clientX, e.event.clientY), 16);
        path.onClick = onNodeClick;
        path.onMouseDown = onNodeDown;
        path.onMouseUp = onNodeUp;
        path.onMouseDrag = onNodeDrag;
        path.fillColor = 'red';
        paper.view.update();
    },
}

// connect tool
tools.connect = {
    onNodeDown: function (e) {
        e.stopPropagation();
        let startX = e.currentTarget.position.x;
        let startY = e.currentTarget.position.y;
        this.currentNode = e.currentTarget;
        this.connectLine = new paper.Path();
        this.connectLine.strokeColor = 'red';
        this.connectLine.add(new paper.Point(startX, startY));
        this.connectLine.add(new paper.Point(e.event.clientX, e.event.clientY));
    },

    onNodeDrag: function (e) {
        let segment = this.connectLine.lastSegment.point;
        segment.x = e.event.clientX;
        segment.y = e.event.clientY;
        paper.view.update();
    },

    onNodeUp: function (e) {
        if (this.currentNode != e.currentTarget) {
            let connection = new paper.Path();
            let startX = this.currentNode.position.x;
            let startY = this.currentNode.position.y;
            let endX = e.currentTarget.position.x;
            let endY = e.currentTarget.position.y;
            connection.strokeColor = 'black';
            connection.add(new paper.Point(startX, startY));
            connection.add(new paper.Point(endX, endY));
            this.currentNode = null;
        }
    },

    onCanvasUp: function (e) {
        console.log("canvas");
        if (this.connectLine) {
            this.connectLine.remove();
            this.connectLine = null;
        }
    },
}

var currentTool = tools.create;

// --------------------------------------------------------------------- EVENTS
function onNodeClick(e) {
    if (currentTool.onNodeClick) {
        currentTool.onNodeClick(e);
    }
}

function onNodeUp(e) {
    if (currentTool.onNodeUp) {
        currentTool.onNodeUp(e);
    }
}

function onNodeDown(e) {
    if (currentTool.onNodeDown) {
        currentTool.onNodeDown(e);
    }
}

function onNodeDrag(e) {
    if (currentTool.onNodeDrag) {
        currentTool.onNodeDrag(e);
    }
}

function onCanvasClick(e) {
    if (currentTool.onCanvasClick) {
        currentTool.onCanvasClick(e);
    }
}

function onCanvasUp(e) {
    if (currentTool.onCanvasUp) {
        currentTool.onCanvasUp(e);
    }
}

function onCanvasDown(e) {
    if (currentTool.onCanvasDown) {
        currentTool.onCanvasDown(e);
    }
}

ipc.on('tool-changed', function(event, tool) {
    currentTool = tools[tool];
});

window.addEventListener('resize', function() {
    paper.view.viewSize = new paper.Size(window.innerWidth - 20, window.innerHeight - 20);
});
