const ipc = require('electron').ipcMain;

ipc.on('selection-changed', function(event, properties) {
    global.window.inspector.webContents.send('selection-changed', properties);
});

ipc.on('property-changed', function(event, index, value) {
    global.window.canvas.webContents.send('property-changed', index, value);
});
