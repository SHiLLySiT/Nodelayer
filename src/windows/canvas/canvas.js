'use strict';

const ipc = require('electron').ipcRenderer;
const paper = require('paper');
const canvas = document.getElementById('canvas');

paper.setup(canvas);
paper.view.onClick = onViewClick;

function onNodeClick(e) {
    e.stopPropagation();
    e.target.fillColor = 'green';
}

function onNodeDrag(e) {
    e.target.position.x = e.event.clientX;
    e.target.position.y = e.event.clientY;
}

function onViewClick(e) {
    var path = new paper.Path.Circle(new paper.Point(e.event.clientX, e.event.clientY), 16);
    path.onClick = onNodeClick;
    path.onMouseDrag = onNodeDrag;
    path.fillColor = 'red';
    paper.view.draw();
}

function onWindowResize() {
    paper.view.viewSize = new paper.Size(window.innerWidth - 20, window.innerHeight - 20);
}

window.addEventListener('resize', onWindowResize);
