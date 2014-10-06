var CEREBELLUM = require('./cerebellum.js');
var HOX = require('../gonads/hox-genes/brain.hox');

var fs = require('fs');
var express = require('express');
var passport = require('passport');
var sticky = require('sticky-session');

CEREBELLUM.log.print([ 'fs', 'express', 'passport', 'sticky-session' ], 'module load');

var app = express();

sticky(function() {
  var http = require('http');
  var server = http.createServer(app);
  var bcrypt = require('bcrypt-nodejs');
  var io = require('socket.io')(server);
  var socketIoRedis = require('socket.io-redis');
  var redis = require('redis').createClient();

  var knex = require('knex')(HOX.knex);
  var bookshelf = require('bookshelf')(knex);
  HOX.passport.configure({
    passport: passport,
    bookshelf: bookshelf
  });

  HOX.express.configure({
    express: express,
    app: app,
    passport: passport
  });

  var namespaces = {};
  io.adapter(socketIoRedis());
  HOX.socketio.configure(io, namespaces);

  return server;
}).listen(HOX.express.port, function() {
  CEREBELLUM.log.print({ module: 'express', port: HOX.express.port }, 'module listen');
});
