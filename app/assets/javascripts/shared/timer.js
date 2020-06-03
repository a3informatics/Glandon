/**
 * Timer. Runs a timer
*/

/**
 * Panel classes
*/
var C_TT_SUCCESS = "";
var C_TT_WARNING = "warning";
var C_TT_DANGER = "danger";

/**
 * Initialize the timer.
 *
 * @param id [String] The token id obtained from database
 * @param cardId [String] The id assigned to the card
 * @param timeout [String] The warning timeout
 * @return [Null]
 */
function Timer(id, cardId, timeout) {
  this.id = id;
  this.cardId = cardId;
  this.currentClass = C_TT_SUCCESS;
  this.expired = false;
  this.warningTimeout = timeout;
  this.statusTimeout(10000); //Must be called to start the countdown
  this.timer = null;

  var _this = this;

  $('#timeout').on('click', function () {
    _this.extendLock();
  });
}

/**
 * Gets the status timeout after a specified number of milliseconds.
 *
 * @param period [Integer] The number of milliseconds to wait before executing the function
 * @return [Null]
 */
Timer.prototype.statusTimeout = function (period) {
  var _this = this;
  _this.timer = setTimeout( function () {
    _this.getStatus();
  }, period);
}

/**
 * AJAX call to get current timer status.
 *
 * @return [NUll]
 */
Timer.prototype.getStatus = function () {
  var _this = this;
  $.ajax({
    context: _this,
    url: "/tokens/" + _this.id + "/status",
    type: "GET",
    dataType: 'json',
    error: function (xhr, status, error) {
      displayError("An error has occurred obtaining the edit lock timeout information.");
    },
    success: function(result){
      if (result.running) {
        if (result.remaining > _this.warningTimeout) {
          _this.statusTimeout(10000);
          _this.display(-1);
        } else if (result.remaining > (_this.warningTimeout / 2)) {
          _this.updateClass(C_TT_WARNING);
          _this.display(result.remaining);
          _this.statusTimeout(1000);
        } else {
          if (_this.currentClass.indexOf(C_TT_WARNING) >= 0) {
            _this.updateClass(C_TT_DANGER);
          }
          _this.display(result.remaining);
          _this.statusTimeout(1000);
        }
      } else {
        _this.display(0);
        _this.disable();
      }
    }
  });
}

/**
 * AJAX call to extend the time. Restarts timer.
 *
 * @return [Null]
 */
Timer.prototype.extendLock = function () {
  var _this = this;
  $.ajax({
    url: "/tokens/" + _this.id + "/extend_token",
    type: "GET",
    dataType: 'json',
    error: function (xhr, status, error) {
      displayError("An error has occurred extending the edit lock timeout.");
    },
    success: function(result){
      _this.updateClass(C_TT_SUCCESS);
    }
  });
}

/**
 * Unload. Actions to be taken on unloading the page.
 *
 * @return [Null]
 */
Timer.prototype.unload = function () {
  if (this.timer !== null) {
    window.clearTimeout(this.timer);
  }
}

/**
 * Updates panel class
 *
 * @param newClass [String] New panel class
 * @return [Null]
 */
Timer.prototype.updateClass = function (newClass) {
  $("#" + this.cardId).removeClass(this.currentClass).addClass(newClass);
  this.currentClass = newClass;
}

/**
 * Displays timer.
 *
 * @param seconds [Integer] Current time in seconds
 * @return [Null]
 */
Timer.prototype.display = function (seconds) {
  $('#' + this.cardId).find("#timeout").find(".ico-btn-sec-text").html(ttToMinSec(seconds));
}

/**
 * Disables timer button. Prevents to extend timer when time is out
 *
 * @return [Null]
 */
Timer.prototype.disable = function () {
  $('#' + this.cardId).find("#timeout").addClass("disabled");
  this.expired = true;
}

/**
 * Sets the timer format
 *
 * @param seconds [integer] The number of milliseconds to format
 * @return [String] mm:ss format
 */
function ttToMinSec(seconds) {
  if (seconds == -1) {
    return ""
  } else {
    var minutes = Math.floor(seconds/60);
    var seconds = seconds % 60;
    return pad(minutes, 2, '0') + ":" + pad(seconds, 2, '0');
  }
}
