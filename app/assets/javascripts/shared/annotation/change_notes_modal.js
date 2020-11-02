/*
* Change Notes View
*
*/

/**
 * Change Notes View Constructor
 *
 * @return [void]
 */
function ChangeNotesView(urlSource, urlNotes, itemHTML) {
  this.modal = "#change-notes-modal";
  this.urlSource = urlSource;
  this.urlAddNote = urlSource.replace("notes", "note");
  this.urlChangeNotes = urlNotes;
  this.rawNoteHTML = itemHTML;
  this.editMode = {active: false, node: null, cache: null};
  this.initialized = false;

  $(this.modal).on("shown.bs.modal", this.init.bind(this));
}

/**
 * Initializes table and loads Change Note data
 *
 * @return [void]
 */
ChangeNotesView.prototype.init = function(){
  if (this.initialized)
    return;

  var _this = this;
  _this.table = $("#change-notes-table").DataTable({
   "pagingType": "full",
   "order": [1, "desc"],
   "ajax": {
     "url": _this.urlSource,
     "dataSrc": "data",
     "error": function (xhr, error, code) {
       handleAjaxError(xhr, status, error);
     }
   },
   "language": {
     "infoFiltered": "",
     "processing": generateSpinner("medium"),
     "emptyTable": "No change notes found"
   },
   "bProcessing": true,
   "paging": false,
   "scrollY": 500,
   "scrollCollapse": true,
   "columns": [
     {"data" : "", "render": function (data,type,full,meta) { return _this.renderColumn(full, meta, _this); }},
     {"data" : "timestamp", "visible": false},
   ],
   "initComplete": function(){_this.initListeners()}
  });

  this.initialized = true;
}

/**
 * Makes an AJAX call to add / update / delete a note, handles response
 *
 * @param [DataTables Row] note: the row object containing the note
 * @param [String] the url of the ajax call
 * @param [Action] Action type (POST / PUT / DELETE)
 * @return [void]
 */
ChangeNotesView.prototype.makeAjax = function(note, url, action){
  var _this = this;
  _this.table.processing(true);

  url = action == "POST" ? url : url.replace("note_id", note.data().id);
  var data = {}
  var name = action == "POST" ? "iso_concept" : "change_note";
  data[name] = {"reference": $(note.node()).find(".note-reference").text().trim(),
                "description": $(note.node()).find(".note-text").text().trim()}

  $.ajax({
    url: url,
    data: data,
    type: action,
    dataType: 'json',
    success: function(result) {
      _this.table.processing(false);

      if (action == "PUT" || action == "POST"){
        note.data(result.data).draw();
        _this.leaveEditMode();
        _this.initListeners();
      } else
        note.remove().draw();
    },
    error: function(xhr,status,error){
      _this.table.processing(false);
      handleAjaxError(xhr, status, error);
    }
  });
}

/**
 * Initializes listeners for note interaction events
 *
 * @return [void]
 */
ChangeNotesView.prototype.initListeners = function(){
  this.deleteNoteListener($(this.modal).find(".note-delete-button"));
  this.editNoteListener($(this.modal).find(".content-editable"));
  this.addNewNoteListener($("#add-cn-button"));
}


/**
 * Handles click on note's delete button
 *
 * @param [JQuery Object] one or more targets (delete buttons) for the click event handler
 * @return [void]
 */
ChangeNotesView.prototype.deleteNoteListener = function(targets){
  var _this = this;

  targets.off("click").on("click", function(){
    var note = _this.table.row($(this).closest("tr"));
    new ConfirmationDialog(function(){ return _this.makeAjax(note, _this.urlChangeNotes, "DELETE"); },{dangerous: true}).show();
  });
}

/**
 * Handles click on note's editable text
 *
 * @param [JQuery Object] one or more targets (editable text fields) for the click event handler
 * @return [void]
 */
ChangeNotesView.prototype.editNoteListener = function(targets){
  var _this = this;

  targets.off("focus").on("focus", function(){
    var note = _this.table.row($(this).closest("tr"));

    if(!_this.editMode.active)
      _this.enterEditMode(note);
    else if(_this.editMode.node.data().id != note.data().id)
      _this.leaveEditMode(true);
  });
}

/**
 * Handles click on Add new button
 *
 * @param [JQuery Object] target - Add note button
 * @return [void]
 */
ChangeNotesView.prototype.addNewNoteListener = function(target){
  var _this = this;

  target.off("click").on("click", function(){
    if(_this.editMode.active)
      return;

    _this.table.row.add({new: true, timestamp: "9999"}).draw();

    var note = _this.table.row($("#cn-new").closest("tr"));
    _this.enterEditMode(note);

    // Saves new note
    $("#save-cn-new-button").off("click").on("click", function() {
      _this.makeAjax(note, _this.urlAddNote, "POST");
    });

    // Discards new note
    $("#cancel-cn-new-button").off("click").on("click", function() {
      new ConfirmationDialog(function(){  _this.leaveEditMode(); note.remove().draw(); },
                            {subtitle: "Your unsaved changes will be lost."}).show();
     });
  });
}

/**
 * Enters the edit mode for a note
 *
 * @param [DataTables Row] note: the row object containing the note
 * @return [void]
 */
ChangeNotesView.prototype.enterEditMode = function(note){
  var _this = this;

  _this.editMode.node = note;
  _this.editMode.active = true;
  _this.editMode.cache = {ref: note.data().reference, text: note.data().description};

  _this.initEditModeControls(note);
  _this.deactivateNotesExcept(note);
  $(note.node()).find(".note-delete-button").css("visibility", "hidden");
  $("#add-cn-button").addClass("disabled");
}

/**
 * Initializes the controls for editing a note and their handlers
 *
 * @param [DataTables Row] note: the row object containing the note
 * @return [void]
 */
ChangeNotesView.prototype.initEditModeControls = function(note){
  var _this = this;

  var id = $(note.node()).find(".note").attr("id").split('-')[1];
  var saveBtnId = "save-cn-"+id+"-button", cancelBtnId = "cancel-cn-"+id+"-button";

  $(note.node()).find(".note-footer").html("");

  $(note.node()).find(".note-footer")
                .append(_this.newButtonHTML(saveBtnId, "note-save-button", "ok", "Save"))
                .append(_this.newButtonHTML(cancelBtnId, "note-edit-cancel-button", "times", "Discard"));

  // Saves note changes
  $("#"+saveBtnId).on("click", function(){ _this.makeAjax(note, _this.urlChangeNotes, "PUT"); });

  // Discards note changes
  $("#"+cancelBtnId).on("click", function(){
    new ConfirmationDialog(function(){ _this.resetNoteData(note, _this.editMode.cache); _this.leaveEditMode()},
                          {subtitle: "Your unsaved changes will be lost."}).show();
  });
}

/**
 * Leaves edit mode, resets UI
 *
 * @return [void]
 */
ChangeNotesView.prototype.leaveEditMode = function(){
  var _this = this;
  var note$ = $(_this.editMode.node.node()).find(".note");

  $(_this.modal).find(".note").removeClass("active inactive");
  note$.children(".note-footer").children().remove();
  note$.find(".note-delete-button").css("visibility", "visible");
  $("#add-cn-button").removeClass("disabled");

  _this.editMode = {active: false, node: null, cache: null};
}

/**
 * Resets note data to chached values
 *
 * @param [DataTables Row] note: the row object containing the note
 * @param [Object] cachce object in the format {ref, text}
 * @return [void]
 */
ChangeNotesView.prototype.resetNoteData = function(note, cache){
  var _this = this;
  if(_this.editMode.active){
    $(note.node()).find(".note-reference").text(cache.ref);
    $(note.node()).find(".note-text").text(cache.text);
  }
}

/**
 * Deactivates all notes except argument note
 *
 * @param [DataTables Row] note: the row object containing the note
 * @return [void]
 */
ChangeNotesView.prototype.deactivateNotesExcept = function(note){
  $(this.modal).find(".note").addClass("inactive");
  $(this.modal).find(".content-editable").attr("contenteditable", false);
  $(note.node()).find(".note").removeClass("inactive")
                              .addClass("active");
  $(note.node()).find(".content-editable").attr("contenteditable", true);
  $(note.node()).find(".content-editable")[0].focus();

}

/**
 * Renders a formatted Change note HTML code with data
 *
 * @param [Object] full data object of a single note (from the server)
 * @param [Object] datatables metadata of the row
 * @param [Context Instance] current context referring to this object instance
 * @return [String] Change Note HTML code
 */
ChangeNotesView.prototype.renderColumn = function(full, meta, context){
  if(full.new == true)
    return context.newNoteHTML("new", "New Change note", "", "Enter reference", "Enter description");
  else {
    var formattedTimestamp = full.timestamp.replace("T", " ").replace(/-/g,'/').substring(0, full.timestamp.indexOf('+'));
    var date = $.format.date((new Date(formattedTimestamp)).getTime(), "dd/MM/yyyy, HH:mm");
    return context.newNoteHTML(meta.row, full.user_reference, date, full.reference, full.description);
  }
}

/**
 * Fills the raw Note HTML with data
 *
 * @param [String/Integer] num - note index number / name that will be used in the id of the note element
 * @param [String] email of the user
 * @param [String] formatted date string
 * @param [String] reference text
 * @param [String] note description text
 * @return [String] Change Note HTML code with data
 */
ChangeNotesView.prototype.newNoteHTML = function(num, email, date, ref, text){
  return this.rawNoteHTML
    .replace(/%%num%%/g, num)
    .replace("%%email%%", email)
    .replace("%%date%%", date)
    .replace("%%ref%%", ref)
    .replace("%%text%%", text);
}

/**
 * Generates HTML for an edit note button
 *
 * @param [String] id of the button
 * @param [String] class name of the button
 * @param [String] icon name (from icon-font)
 * @param [String] ttip text
 * @return [String] Button HTML with data
 */
ChangeNotesView.prototype.newButtonHTML = function(id, cls, icon, ttip){
  var html =
    '<button class="circular-badge small bg-grey-bright '+cls+' ttip" id="'+id+'">'+
      '<span class="ttip-text ttip-left ttip-top shadow-small text-small">'+ttip+'</span>' +
      '<span class="icon-'+icon+' text-link"></span>' +
    '</button>';
  return html;
}
