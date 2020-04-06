/*
* Information Dialog
*
* Warning: This dialog's HTML structure is identical to a partial in shared/information_dialog.html.erb
* When changing it, you must change the other one as well!
*
*/

/**
 * Information Dialog Constructor
 *
 * @param options [Object] options for the confirm dialog. Format:
 *  title [String] (optional): Title of the dialog
 *  subtitle [String]: Subtitle of the dialog
 *  dangerous [Boolean] (optional): Will add a red border around the dialog
 *  wide [Boolean] (optional): Widens the dialog
 *  div [JQuery Element] (optional): Use if information dialog is already declared in the body
 * @return [void]
 */
function InformationDialog(options) {
  this.options = this.defaultOptions(options);
  this.id = (options.div == null ? this.generateId() : "#"+options.div.attr("id"));
}

/**
 * Appends HTML to page body, sets button handler and shows the InformationDialog
 *
 * @return [void]
 */
InformationDialog.prototype.show = function() {
  if(this.options.div == null)
    $("body").prepend(this.generateDialogHTML());
  else
    this.adjustDisplay();

  this.listeners();

  setTimeout(function(){
    $(this.id).addClass("cd-show");
  }.bind(this), 1);

  return this;
}


/**
 * Hides the InformationDialog, removes the HTML from the page body
 *
 * @return [void]
 */
InformationDialog.prototype.dismiss = function() {
  $(this.id).removeClass("cd-show");

  if(this.options.div == null)
    setTimeout(function(){ $(this.id).remove(); }.bind(this), 200);
}

/**
 * Sets the click event for Dismiss button
 *
 * @return [void]
 */
InformationDialog.prototype.listeners = function() {
  $(this.id + "  #id-dismiss-button").one('click', function() {
    this.dismiss();
  }.bind(this));

  $(window).one("keyup", function(e){
    if(e.keyCode == 27 || e.which == 27)
      this.dismiss();
  }.bind(this));
}

/**
 * Generates unique ID for the div
 *
 * @return [String] id
 */
InformationDialog.prototype.generateId = function() {
  return "#information-dialog-" + ($(".cd-wrap").length + 1);
}

/**
 * Moves element out of a modal, if it is included in modal, for styling issues
 *
 * @return [void]
 */
InformationDialog.prototype.adjustDisplay = function() {
  if($(".modal-open").find($(this.id)).length > 0)
    $("body").append( $('.modal-open ' + this.id) );
}

/**
 * Sets subtitle text to new text
 *
 * @return [void]
 */
InformationDialog.prototype.setText = function(newText) {
  $(this.id).find(".cd-subtitle").html(newText);
}

/**
 * Sets the default options combined with optional user options
 *
 * @param [Object] User options (can be empty object {})
 * @return [Object] Default values combined with user options that were set
 */
InformationDialog.prototype.defaultOptions = function(userOptions) {
  return _.defaults(userOptions, {
    title: "Information",
    subtitle: "",
    dangerous: false,
    wide: false,
    div: null
  });
}

/**
 * Generates the HTML of the confirmation dialog with instance options
 *
 * @return [String] HTML to be appended to <body>
 */
InformationDialog.prototype.generateDialogHTML = function() {
  var html = '';
  html += '<div id="' + this.id.replace('#','') + '" class="cd-wrap ' + (this.options.wide ? 'wide' : '') + '">';
  html +=   '<div class="cd-body shadow-medium ' + (this.options.dangerous ? 'danger' : '') + '">';
  html +=     '<div class="cd-title text-xnormal text-link">' + this.options.title + '</div>';
  html +=     '<div class="cd-subtitle scroll-styled text-small font-light">' + this.options.subtitle + '</div>';
  html +=     '<div class="cd-footer">';
  html +=       '<button id="id-dismiss-button" class="btn grey medium">Dismiss</button>';
  html +=     '</div>';
  html +=   '</div>';
  html += '</div>';

  return html;
}
