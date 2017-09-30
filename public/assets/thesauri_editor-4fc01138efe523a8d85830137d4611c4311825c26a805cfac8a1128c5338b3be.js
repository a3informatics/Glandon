$(document).ready(function() {
    
  var addChildPath = $('#add_child_path').val();
  var childrenPath = $('#children_path').val();
  var parametersKey = $('#parameters_key').val();
  var html  = $("#json_data").html();
  var sourceJson;
  var managedItem;
  
  // Disable the saving spinner
  $("#saving").prop("disabled", true);

  // Get the JSON structure. Set the namespace of the thesauri.
  sourceJson = $.parseJSON(html);
  managedItem = sourceJson;

  emptyTc = 
    {
      "type": C_THC, 
      "id": "", 
      "namespace": "", 
      "parentIdentifier": "", 
      "identifier": "", 
      "label": "", 
      "notation": "", 
      "preferredTerm": "", 
      "synonym": "", 
      "definition": ""
    };

  // Start timeout timer
  ttAddToken("1");
   
  // Close button
  $('#close_button').click(function() {
    keepToken = false;
    window.location.href = $('#close_path').val();
  });

  // Save. Just extend the timeout
  $('#save').click(function (event) {
    ttExtendLock("1");
  });

  $('#referer_button').click(function() {
    ttExtendLock("1"); // Extend the token
    keepToken = true; // Keep the token. Important
    window.location.href = $('#referer_path').val();
  });

  var editor = new $.fn.dataTable.Editor( {
    ajax: {
      edit: {
          type: 'PUT',
          url:  '/thesaurus_concepts/_id_'
      },
    },
    table: "#editor_table",
    idSrc: "id",
    fields: 
    [
      {
          name: "label"
      },
      {
          label: "Submission Value:",
          name: "notation"
      },
      {
          label: "Preferred term:",
          name: "preferredTerm"
      },
      {
          label: "Synonym:",
          name: "synonym"
      },
      {
          label: "Definition:",
          name: "definition"
      }
    ]
  } );
 
  var main = $('#editor_table').DataTable({
      pageLength: 15,
      lengthMenu: [[5, 10, 15, 20, 25, 50, -1], [5, 10, 15, 20, 25, 50, "All"]],
      ajax: {
        url: childrenPath,
        data: {
          "id": managedItem.id,
          "namespace": managedItem.namespace
        },
        error: function (xhr, status, error) {
          var html = alertError("An error has occurred loading the thesauri concepts table.");
          displayAlerts(html);
        }
      },
      columns: [
        { data: "identifier" },
        { data: "label" },
        { data: "notation" },
        { data: "preferredTerm" },
        { data: "synonym" },
        { data: "definition" },
        { data: null, "render": function(data,type,full,meta) { 
          return '<button type="button" class="btn btn-primary btn-xs">Edit</button>';
        }},
        { data: null, "render": function(data,type,full,meta) { 
          return '<button type="button" class="btn btn-danger btn-xs">Delete</button>';
        }}
      ],
      keys: {
          columns: [ 1, 2, 3, 4, 5 ],
          keys: [ 9, 38, 40 ]
      }
  } );

  // Click on the table.
  $('#editor_table').on('click', 'tbody td:not(:first-child)', function (e) {
    var idx = main.cell(this).index();
    var row = idx.row;
    var col = idx.column;
    var data = main.cell(this).data();

    if (col == 6) {
      ttExtendLock("1"); // Extend the token
      keepToken = true; // Keep the token. Important
      window.location.href = "/thesaurus_concepts/" + data.id + "/edit?namespace=" + data.namespace
    } else if (col == 7) {
      if(confirm("Are you sure?")) {
        deleteRest(data.id, data.namespace)
      }
    } else {
      editor.inline(main.cell(this).index(), { submitOnBlur: true, submit: 'all' });
    }
  });

  // Inline editing on tab focus
  main.on( 'key-focus', function ( e, datatable, cell ) {
    editor.inline( cell.index(), { submitOnBlur: true, submit: 'all' } );
  } );

  // Presubmit event. Format the data.
  editor.on('preSubmit', function ( e, d, type ) {
    if ( type === 'edit' ) {
      d.thesaurus_concept = cloneTC();
      d.namespace = managedItem.namespace;
      var columnObject = firstObject(d.data);
      $.each(columnObject, function(key, value) {
        d.thesaurus_concept[key] = value;
      });
      delete d.data;
    }
    return true;
  });

  // Submit error event. Route to the specified link.
  editor.on('submitError', function (e, xhr, err, thrown, data) {
    window.location.href = xhr.responseJSON.link;
  });

  // Postsubmit event. Extend the timeout
  editor.on('postSubmit', function ( e, json, data, type ) {
    ttExtendLock("1");
  });

  // Set up the form validation
  validatorDefaults ();
  $('#main_form').validate({
    rules: {
      "Code List Identifier": {required: true, tcIdentifier: true }
    },
    submitHandler: function(form) {
      var localTc = cloneTC();
      localTc["identifier"] = $("#tcIdentifier").val();
      $("#tcIdentifier").val("");
      createRest(localTc);
      return false;
    },
    invalidHandler: function(event, validator) {
      var html = alertWarning("The form is not valid. Please correct the errors.");
      displayAlerts(html);
    }
  });

  function createRest(record) {
    var data;
    data = {};
    data[parametersKey] = record;
    $.ajax({
      url: addChildPath + '/?id=' + managedItem.id + '&namespace=' + managedItem.namespace,
      type: 'POST',
      data: JSON.stringify(data),
      dataType: 'json',
      contentType: 'application/json',
      success: function(result){
        var html = alertSuccess("The concept has been saved.");
        displayAlerts(html);
        main.ajax.reload();
        ttExtendLock("1");
      },
      error: function(xhr,status,error){
        handleAjaxError (xhr, status, error);
      }
    }); 
  }

  function deleteRest(id, namespace) {
    $.ajax({
      url: '/thesaurus_concepts/' + id + '/?namespace=' + namespace,
      type: 'DELETE',
      dataType: 'json',
      contentType: 'application/json',
      success: function(result){
        var html = alertSuccess("The concept has been deleted.");
        displayAlerts(html);
        main.ajax.reload();
        ttExtendLock("1");
      },
      error: function(xhr,status,error){
        handleAjaxError (xhr, status, error);
      }
    }); 
  }

  function firstObject(object) {
    var first;
    for (var i in object) {
      if (object.hasOwnProperty(i) && typeof(i) !== 'function') {
        first = object[i];
        break;
      }
    }
    return first;
  }

  function cloneTC() {
    return JSON.parse(JSON.stringify(emptyTc));
  }

});

// Null function for page unload. Nothing to do
function pageUnloadAction() {
}

  
;
