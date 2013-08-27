window.App = Ember.Application.create();

App.Store = DS.Store.extend({
  revision: 13
});
DS.RESTAdapter.reopen({
  namespace: 'api',
  headers: {
    'X_AUTH_TOKEN': user_api_key
  }
});

App.Router.map(function () {
  this.resource('config_items', function() {
    this.resource('config_items', {path: ':config_item_id'});
  });
  this.resource('consumers');
  this.resource('users');
});

/* ===== Models ===== */

App.ConfigItem = DS.Model.extend({
  name: DS.attr('string'),
  value: DS.attr('string')
});

App.Consumer = DS.Model.extend({
  name: DS.attr('string'),
  apiKey: DS.attr('string')
});

App.User = DS.Model.extend({
  username: DS.attr('string'),
  role: DS.attr('string'),
  apiKey: DS.attr('string')
});

/* ===== Controllers ===== */

App.IndexController = Ember.ArrayController.extend({
  save: function(event) {
    console.log('Saving (index) ', event.context);
  }
});

App.ConfigItemsController = Ember.ArrayController.extend({
  save: function(event) {
    this.get('store').commit();
  },

  createConfigItem: function() {
    var name = this.get('newName');
    var value = this.get('newValue');
    var item = App.ConfigItem.createRecord({
      name: name,
      value: value
    });

    this.set('newName', '');
    this.set('newValue', '');

    item.save();
  },

  removeConfigItem: function(item) {
    item.deleteRecord();
    item.save();
  }
});

App.ConfigItemController = Ember.ObjectController.extend({
  save: function(event) {
    this.get('store').commit();
  }
});

App.ConsumersController = Ember.ArrayController.extend({
  save: function(event) {
    this.get('store').commit();
  },

  createConsumer: function() {
    var name = this.get('newName');
    var consumer = App.Consumer.createRecord({
      name: name
    });

    this.set('newName', '');

    consumer.save();
  },

  removeConsumer: function(consumer) {
    consumer.deleteRecord();
    consumer.save();
  }
});

App.ConsumerController = Ember.ObjectController.extend({
  save: function(event) {
    this.get('store').commit();
  }
});

App.UsersController = Ember.ArrayController.extend({
  save: function(event) {
    this.get('store').commit();
  },

  createUser: function() {
    var username = this.get('newUsername');
    var user = App.User.createRecord({
      username: username
    });

    this.set('newUsername', '');

    user.save();
  },

  removeUser: function(user) {
    user.deleteRecord();
    user.save();
  }
});

App.UserController = Ember.ObjectController.extend({
  save: function(event) {
    this.get('store').commit();
  }
});



/* ===== Views ===== */

App.TextField = Ember.TextField.extend({
  classNames: ['form-control'],

  didInsertElement: function(){
    this.$().focus();
  },

  eventManager: Ember.Object.create({
    focusOut: function(event, view) {
      view.set('editMode', false);
      view.get('controller').save();
    }
  })
});

App.ContentEditable = Ember.View.extend({
  editMode: false,

  eventManager: Ember.Object.create({
    click: function(event, view) {
      view.set('editMode', true);
    }
  }),

  fieldName: '',

  templateName: 'content-editable'
});

/* ===== Routes ===== */

App.IndexRoute = Ember.Route.extend({
  setupController: function(controller) {
    controller.set('config_items', App.ConfigItem.find());
    controller.set('consumers', App.Consumer.find());
    if (user_admin === true) {
      controller.set('users', App.User.find());
    }
  }
});

App.ConfigItemsRoute = Ember.Route.extend({
  model: function() {
    return App.ConfigItem.find();
  }
});

App.ConsumersRoute = Ember.Route.extend({
  model: function() {
    return App.Consumer.find();
  }
});

App.UsersRoute = Ember.Route.extend({
  model: function() {
    return App.User.find();
  }
});
