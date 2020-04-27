/*
* Confirmation Dialog
*
*/

/**
 * Confirmation Dialog Constructor
 *
 * @param confirmCallback [Function] called when user clicks positive button
 * @param options [Object] options for the confirm dialog. Format:
 *  title [String] (optional): Title of the dialog
 *  subtitle [String] (optional): Subtitle of the dialog
 *  positiveButton [String] (optional): Text on the positive button
 *  negativeButton [String] (optional): Text on the negative button
 *  dangerous [Boolean] (optional): If true, will add a red border around the dialog
 *  withLoading [Boolean] (optional): If true, will append loading animation in the dialog
 * @param negativeCallback [Function] called when user clicks negative button (optional)
 *
 * @return [void]
 */
function ConfirmationDialog(confirmCallback, options, negativeCallback) {
  var _this = this;
  this.options = options == null ? this.defaultOptions({}) : this.defaultOptions(options);
  this.callback = confirmCallback;
  this.negativeCallback = negativeCallback;
  this.id = this.generateId();
}

/**
 * Appends HTML to page body, sets button callbacks and shows the ConfirmationDialog
 *
 * @return [void]
 */
ConfirmationDialog.prototype.show = function() {
  $("body").prepend(this.generateDialogHTML());
  this.setListeners();

  setTimeout(function(){
    $(this.id).addClass("cd-show");
  }.bind(this), 1);
}


/**
 * Hides the ConfirmationDialog, removes the HTML from the page body
 *
 * @return [void]
 */
ConfirmationDialog.prototype.dismiss = function() {
  $(this.id).removeClass("cd-show");

  setTimeout(function(){
    $(this.id).remove();
  }.bind(this), 200);
}

/**
 * Sets the click events for the postive and negative buttons, escape button
 *
 * @return [void]
 */
ConfirmationDialog.prototype.setListeners = function() {
  var _this = this;
  $(this.id + " #cd-positive-button").on('click', function(){
    if(_this.callback != null)
      _this.callback(_this);
    _this.dismiss();
  });

  $(this.id + " #cd-negative-button").on('click', function(){
    _this.dismiss();
    if(_this.negativeCallback != null)
      _this.negativeCallback();
  });

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
ConfirmationDialog.prototype.generateId = function() {
  return "#confirmation-dialog-" + ($(".cd-wrap").length + 1);
}

/**
 * Toggles loading animation display, only usable if withLoading option is set to true
 *
 * @param [Boolean] enable: if true, will display, if false, will hide the loading
 * @return [void]
 */
ConfirmationDialog.prototype.toggleProcessing = function(enable) {
  if(!this.options.withLoading)
    return;
  if(enable)
    $(this.id + " .cd-loading").removeClass("hidden");
  else
    $(this.id + " .cd-loading").addClass("hidden");
}

/**
 * Sets the default options combined with optional user options
 *
 * @param [Object] User options (can be empty object {})
 * @return [Object] Default values combined with user options that were set
 */
ConfirmationDialog.prototype.defaultOptions = function(userOptions) {
  return _.defaults(userOptions, {
    title: "Are you sure you want to proceed?",
    subtitle: "You cannot undo this operation.",
    positiveButton: "Yes",
    negativeButton: "No",
    dangerous: false,
    withLoading: false
  });
}

/**
 * Generates the HTML of the confirmation dialog with instance options
 *
 * @return [String] HTML to be appended to <body>
 */
ConfirmationDialog.prototype.generateDialogHTML = function() {
  var html = '';
  html += '<div id="' + this.id.replace('#','') + '" class="cd-wrap">';
  html +=   '<div class="cd-body shadow-medium ' + (this.options.dangerous ? 'danger' : '') + '">';
  html +=     '<div class="cd-title text-xnormal">' + this.options.title + '</div>';
  html +=     '<div class="cd-subtitle scroll-styled text-small font-light">' + this.options.subtitle + '</div>';
  html +=     this.options.withLoading ? ('<div class="cd-loading hidden">'+generateSpinner("small")+'</div>') : '';
  html +=     '<div class="cd-footer">';
  html +=       '<button id="cd-negative-button" class="btn medium">' + this.options.negativeButton + '</button>';
  html +=       '<button id="cd-positive-button" class="btn medium">' + this.options.positiveButton + '</button>';
  html +=     '</div>';
  html +=   '</div>';
  html += '</div>';

  return html;
}
