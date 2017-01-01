const ipc = require('electron').ipcMain;
const utils = require('../../utils');

ipc.on('selection-changed', function(event, uuid) {
    let node = global.project.nodes[uuid];
    global.window.inspector.webContents.send('selection-changed', node);
});

ipc.on('property-changed', function(event, uuid, data) {
    let node = global.project.nodes[uuid];
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
});
