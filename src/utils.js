module.exports = {
    generateUUID: function() {
        var d = new Date().getTime();
        var uuid = '0xxxxxxxxxxxxxxxyxxxxxxxxxxxxxxx'.replace(/[xy]/g, function(c) {
            var r = (d + Math.random() * 16) % 16 | 0;
            d = Math.floor(d / 16);
            return (c == 'x' ? r : (r&0x3 | 0x8)).toString(16);
        });
        return uuid;
    },
    
    isInteger: function(str) {
          return str.match(/[^$,.\d]/) == null;
    },
}
