;(function() {
  'use strict';

  var CEREBELLUM = require('../../brain/cerebellum.js');
  var HOX = require('../../gonads/hox-genes/muscle.hox');

  var $ = require('jquery');
  require('jquery-ui');

  var io = require('socket.io-client');

  var AmpersandModel = require('ampersand-model');
  var AmpersandView = require('ampersand-view');

  var SectionView = AmpersandView.extend({
    render: function() {
      this.renderWithTemplate(this);

      var id = $(this.el).attr('id');

      this.model.context.router.navigate(id);

      $(this.el).fadeIn(HOX.animationTime);
      
      return this;
    },
    destroy: function(next) {
      var self = this;
      $(this.el).fadeOut(HOX.animationTime, function() {
        if (typeof next === 'string' &&
            typeof self.model.context[next] === 'object' &&
            typeof self.model.context[next].view === 'object') {
              self.model.context[next].view.render();
        }
      });

      return this;
    }
  });

  var SectionModel = AmpersandModel.extend({
    props: {
      context: 'object',
      view: 'object'
    }
  });

  module.exports = {
    View: SectionView,
    Model: SectionModel
  };
})();
