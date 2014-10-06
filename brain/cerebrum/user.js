var bcrypt = require('bcrypt-nodejs');

var User = function(properties) {
  var keys = Object.keys(properties);
  for (var i = 0; i < keys.length; i ++){
    var property = keys[i];
    this[property] = properties[property];
  }
};

User.prototype = {
  hashPassword: function(password) {
    return bcrypt.hashSync(password, bcrypt.genSaltSync(0), null);
  },
  validatePassword: function(password) {
    return bcrypt.compareSync(password, this.password);
  }
};

module.exports = User;
