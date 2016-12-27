const ipc = require('electron').ipcMain;

ipc.on('selection-changed', function(event, data) {
    global.window.inspector.webContents.send('selection-changed', data);
});
