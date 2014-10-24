;(function() {
  'use strict';

  var Router = require('ampersand-router');

  module.exports = Router.extend({
    initialize: function(options) {
      this.context = options.context;
    },
    routes: {
      '': 'welcome',
      'welcome': 'welcome'
    },
    welcome: function() {
      this.context.welcome.view.render();
    }
  });
})();
