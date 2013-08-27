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

App.ConfigItem = DS.Model.extend({
  name: DS.attr('string'),
  value: DS.attr('string')
});

App.IndexController = Ember.ArrayController.extend({
  save: function(event) {
    console.log('Saving (index) ', event.context);
  }
});

App.ConfigItemsController = Ember.ArrayController.extend({
  save: function(event) {
    console.log('Saving (ConfigItems)', event);
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

App.Consumer = DS.Model.extend({
  name: DS.attr('string'),
  apiKey: DS.attr('string')
});

App.User = DS.Model.extend({
  username: DS.attr('string'),
  apiKey: DS.attr('string')
});


App.IndexRoute = Ember.Route.extend({
  setupController: function(controller) {
    controller.set('config_items', App.ConfigItem.find());
    controller.set('consumers', App.Consumer.find());
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


var addItem = function(ctrl) {
  var item = $(ctrl).parents('.new-item');
  var new_item = item.clone();
  var list = $(item).parents('.edit-list');

  list.append(new_item);
  new_item.find('.add-ctrl').on('click', function() { addItem(this) });

  $(ctrl).off();
  $(ctrl).on('click', function() { removeItem(this) });

  item.addClass('edit-item').removeClass('new-item');
  $(ctrl).removeClass('add-ctrl').addClass('remove-ctrl');

  return false;
};

var removeItem = function(ctrl) {
  var item = $(ctrl).parents('.edit-item');
  var list = $(item).parents('.edit-list');

  item.hide();
  item.find('.delete-input').val(true);

  return false;
};

$('.edit-list .edit-item .remove-ctrl').on('click', function() { removeItem(this) });
$('.edit-list .new-item .add-ctrl').on('click', function() { addItem(this) });
