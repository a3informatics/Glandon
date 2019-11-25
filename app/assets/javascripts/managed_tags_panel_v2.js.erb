function ManagedTagsPanel(callback) {
  this.data = null;
  this.callback = callback;

  var _this = this;

  $('#add_tag').on('click', function () {
    _this.add();
  });

  $('#update_tag').click(function () {
    _this.update();
  });

  $('#delete_tag').click(function () {
    _this.delete();
  });
}

ManagedTagsPanel.prototype.show = function(data) {
  this.data = data;
  // $("#edit_label")[0].focus({preventScroll: true});
  $('#edit_label').val(data.pref_label);
  colorCodeElement('#edit_description', 'border-bottom', '2px solid '+getColorByTag(data.pref_label));
  colorCodeTagsOutline('.handle-selected-tag', '.bg-label');
  $('#edit_description').val(data.description);
  if (data.rdf_type ===  C_SYSTEM) {
    $('#update_tag').addClass("disabled");
    $('#delete_tag').addClass("disabled");
  } else if (data.rdf_type === C_TAG) {
    $('#update_tag').removeClass("disabled");
    $('#delete_tag').removeClass("disabled");
  }
}

ManagedTagsPanel.prototype.clear = function() {
  $('#add_label').val('');
  $('#add_description').val('');
  $('#edit_label').val('');
  $('#edit_description').val('');
}

ManagedTagsPanel.prototype.update = function() {
  var _this = this;
  var labelValue = $('#edit_label').val();
  var descriptionValue = $('#edit_description').val();
  var data = { "namespace": _this.data.namespace, "iso_concept_systems_node": { "label": labelValue, "description": descriptionValue }};
  $.ajax({
    url: '/iso_concept_systems/nodes/' + _this.data.id,
    type: 'PUT',
    data: data,
    success: function(data) {
      _this.callback(data);
    },
    error: function(xhr, status, error){
      handleAjaxError (xhr, status, error);
    }
  });
  _this.clear();
}

ManagedTagsPanel.prototype.delete = function() {
  var _this = this;
  var data = {"id": _this.data.id}
  $.ajax({
    url: '/iso_concept_systems/nodes/' + _this.data.id,
    type: 'DELETE',
    data: data,
    success: function(data) {
      _this.clear();
      _this.callback(data);
    },
    error: function(xhr, status, error){
      handleAjaxError (xhr, status, error);
    }
  });
}

ManagedTagsPanel.prototype.add = function() {
  var _this = this;
  var labelValue = $('#add_label').val();
  var descriptionValue = $('#add_description').val();
  if (_this.data.rdf_type === C_SYSTEM) {
    var url = '/iso_concept_systems/' + _this.data.id + '/add';
    var data = {"namespace": _this.data.namespace, "iso_concept_system": { "label": labelValue, "description": descriptionValue }};
  } else if (_this.data.rdf_type === C_TAG) {
    var url = '/iso_concept_systems/nodes/' + _this.data.id + '/add';
    var data = {"namespace": _this.data.namespace, "iso_concept_systems_node": { "label": labelValue, "description": descriptionValue }};
  }
  $.ajax({
    url: url,
    type: 'POST',
    data: data,
    success: function(data) {
      _this.callback(data);
    },
    error: function(xhr, status, error){
      handleAjaxError (xhr, status, error);
    }
  });
  _this.clear();
}
