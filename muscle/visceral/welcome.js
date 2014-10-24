;(function() {
  'use strict';

  var HOX = require('../../gonads/hox-genes/muscle.hox');

  var $ = require('jquery');
  require('jquery-ui');

  var Section = require('./section.js');

  var WelcomeView = Section.View.extend({
    template: function() { return $('#welcome')[0]; },
    render: function() {
      Section.View.prototype.render.call(this);

      $(this.el).find('#anatomy-logo').css({ top: '0' });
    },
    bindings: {
      'model.name': {
        type: 'text',
        selector: '#greeting'
      }
    },
    events: {
      'submit form': 'greet'
    },
    greet: function(event) {
      event.preventDefault();

      var form = $(event.target);
      
      this.model.name = form.find('input[name="name"]').val();

      return this;
    }
  });

  var WelcomeModel = Section.Model.extend({
    props: {
      name: 'string'
    },
    initialize: function() {
      this.view = new WelcomeView({ model: this });

      this.on('change:name', function(model) {
        var $el = $(model.view.el);
        $el.find('form').fadeOut(HOX.animationTime, function() {
          $el.find('#greeting').prepend('Welcome to Anatomy, ').append('!').fadeIn(HOX.animationTime);
        });
      }); 
    }
  });

  module.exports = WelcomeModel;
})();
