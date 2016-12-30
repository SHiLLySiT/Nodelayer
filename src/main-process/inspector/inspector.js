const ipc = require('electron').ipcMain;
const utils = require('../../utils');

ipc.on('selection-changed', function(event, properties) {
    global.window.inspector.webContents.send('selection-changed', properties);
});

ipc.on('property-changed', function(event, index, value) {
    if (utils.isInteger(value)) {
        let int = parseInt(value);
        if (int > MAX_SAFE_INTEGER) {
            value = MAX_SAFE_INTEGER;
        } else if (int < MIN_SAFE_INTEGER) {
            value = MIN_SAFE_INTEGER;
        }
    } else {
        $(e.currentTarget).val(0);
        value = 0;
    }

    global.window.canvas.webContents.send('property-changed', index, value);
});
