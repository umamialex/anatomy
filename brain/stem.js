;(function() {
  'use strict';

  var CEREBELLUM = require('./cerebellum.js');
  var HOX = require('../gonads/hox-genes/brain.hox');

  var http = require('http');
  var express = require('express');
  var app = express();
  var server = http.createServer(app);

  var sessions = {};
  var namespaces = {};

  CEREBELLUM.log.print([ 'cerebellum', 'hox/brain', 'express', 'cerebrum/user' ], 'module load');

  HOX.express.configure({
    express: express,
    app: app,
    sessions: sessions
  });

  var io = require('socket.io')(server);

  HOX.socketio.configure({
    io: io,
    namespaces: namespaces,
    sessions: sessions
  });

  server.listen(HOX.express.port);

  CEREBELLUM.log.print({ module: 'express', port: HOX.express.port }, 'module listen');
})();
