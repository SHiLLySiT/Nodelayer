const ipc = require('electron').ipcMain;
const remote = require('electron').remote

ipc.on('tool-changed', function(event, tool) {
    global.window.canvas.webContents.send('tool-changed', tool);
});
