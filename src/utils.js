module.exports = {
    isInteger: function(str) {
          return str.match(/[^$,.\d]/) == null;
    },
}
