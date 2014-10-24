;(function() {
  'use strict';

  var colors = require('colors');
  var path = require('path');

  var inBrowser = typeof window !== 'undefined';

  var c;
  var cerebellum = c = {
    directories: {
      root: path.dirname(__dirname),
      skeleton: path.dirname(__dirname) + '/skeleton',
      skin: path.dirname(__dirname) + '/skin',
      muscle: path.dirname(__dirname) + '/muscle',
      voice: path.dirname(__dirname) + '/voice'
    },
    log: {
      print: function(options, event) {
        var time = new Date();
        var timestamp = time.getFullYear() +
          '-' + c.format(time.getMonth() + 1, 2) +
          '-' + c.format(time.getDate(), 2) +
          ' ' + c.format(time.getHours(), 2) +
          ':' + c.format(time.getMinutes(), 2) +
          ':' + c.format(time.getSeconds(), 2) +
          '.' + c.format(time.getMilliseconds(), 3);

        var browserStyles = [];
        Object.defineProperty(browserStyles, 'addStyle', {
          value: function(style) {
            this.push(style);
            this.push('background: transparent; color: inhert');
          }
        });

        var clusterId = null;
        if (inBrowser) {
          clusterId = '%cBROWSER%c : ';
          browserStyles.addStyle('background: #f00; color: #fff');
        } else {
          clusterId = 'SERVER'.red.inverse + ' : ';
        }

        var e = c.log.events;
        var text;
        switch (event) {
          // Modules
          case e.module.load:
            for (var i = 0; i < options.length; i++) {
              options[i] = options[i].toUpperCase().inverse;
            }
            text = 'Imported Modules ' + options.join(', ') + '.';
          break;
          case e.module.listen:
            text = options.module.toUpperCase().inverse + ' is listening on port ' + options.port.toString().white.inverse + '.';
          break;
          case e.module.configure:
            text = options.toUpperCase().inverse + ' is successfully configured.';
          break;

          // Socket.io
          case e.socketio.connect:
            if (inBrowser) {
              text = '%cSOCKET.IO%c connection by %c' + options.toString() + '%c.';
              browserStyles.addStyle('background: #000; color: #fff');
              browserStyles.addStyle('background: #f0f; color: #fff');
            } else {
              text = 'SOCKET.IO'.inverse + ' connection by ' + options.toString().magenta.inverse + '.';
            }
          break;
          case e.socketio.disconnect:
            if (inBrowser) {
              text = '%cSOCKET.IO%c disconnect by %c' + options.toString() + '%c.';
              browserStyles.addStyle('background: #000; color: #fff');
              browserStyles.addStyle('background: #f0f; color: #fff');
            } else {
              text = 'SOCKET.IO'.inverse + ' disconnect by ' + options.toString().magenta.inverse + '.';
            }
          break;
        }

        var out = clusterId + text;
        if (inBrowser) {
          browserStyles.unshift(timestamp + ' ' + out);
          console.log.apply(console, browserStyles);
        } else {
          console.log(timestamp + ' ' + out);
        }
      },
      events: {
        module: {
          load: 'module load',
          listen: 'module listen',
          configure: 'module configure',
          error: 'module error'
        },
        socketio: {
          connect: 'socketio connect',
          disconnect: 'socketio disconnect'
        }
      }
    },
    format: function(n, place) {
      n = n.toString();
      return n.length >= place ? n : new Array(place - n.length + 1).join('0') + n;
    }
  };

  module.exports = cerebellum;
})();
