(function() {
  var cluster = require('cluster');
  var colors = require('colors');
  var path = require('path');

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
      print: function(options, event, overwrite) {
        overwrite = typeof overwrite !== 'boolean' ? false : overwrite;

        var time = new Date();
        var timestamp = time.getFullYear() +
          '-' + c.format(time.getMonth() + 1, 2) +
          '-' + c.format(time.getDate(), 2) +
          ' ' + c.format(time.getHours(), 2) +
          ':' + c.format(time.getMinutes(), 2) +
          ':' + c.format(time.getSeconds(), 2) +
          '.' + c.format(time.getMilliseconds(), 3);

        var clusterId = null;
        if (cluster.isMaster) {
          clusterId = 'M**'.red.inverse + ' : ';
        } else {
          var prefix = 'W#' + cluster.worker.id;
          switch (cluster.worker.id) {
            case 1: prefix = prefix.green; break;
            case 2: prefix = prefix.blue; break;
            case 3: prefix = prefix.magenta; break;
            case 4: prefix = prefix.yellow; break;
          }
          clusterId = prefix.inverse + ' : ';
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
            text = 'socket.io'.toUpperCase().inverse + ' connection by ' + options.toString().magenta.inverse + '.';
          break;
          case e.socketio.disconnect:
            text = 'socket.io'.toUpperCase().inverse + ' disconnect by ' + options.toString().magenta.inverse + '.';
          break;
        }

        var out = clusterId + text;
        if (overwrite) {
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
          disconnect: 'socketio disconnect',
          event: 'socketio event',
          error: 'socketio error'
        }
      }
    },
    format: function(n, place) {
      n = n.toString();
      return n.length >= place ? n : new Array(place - n.length + 1).join('0') + n;
    },
    makeUrlSafe: function(url) {
      return url.toLowerCase().replace(/ /g, '-')
                  .replace(/\(/g, '')
                  .replace(/\)/g, '');
    }
  };

  module.exports = cerebellum;
})();
