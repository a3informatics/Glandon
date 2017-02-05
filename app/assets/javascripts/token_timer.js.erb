var ttTokens = {};

var C_TT_SUCCESS = "btn-success"; 
var C_TT_WARNING = "btn-warning"; 
var C_TT_DANGER = "btn-danger"; 

function ttAddToken(id) {
  ttTokens[id] = {};
  ttTokens[id].timerId = null;
  ttTokens[id].currentClass = ttGetTimerClass(id);
  ttTokens[id].warningTimeout = ttGetTimerTimeout(id);
  ttTokens[id].tokenId = $('#token_' + id).val();
  ttDisableTimerField(id);
  ttHideTimer(id)
  ttStatusTimeout(id, 10000);
}

function ttRemoveToken(id) {
  clearTimeout(ttTokens[id]);
  ttTokens[id] = {};
}

function ttStatusTimeout(id, period) {
  ttTokens[id].timerId = setTimeout(function(){
    ttGetStatus(id);
  }, period);
}

function ttGetStatus(id) {
  $.ajax({
    url: "/tokens/" + ttTokens[id].tokenId + "/status",
    type: "GET",
    dataType: 'json',
    error: function (xhr, status, error) {
      displayError("An error has occurred obtaining the edit lock timeout information.");
    },
    success: function(result){
      if (result.running) {
      	if (result.remaining > ttTokens[id].warningTimeout) {
      		ttHideTimer(id);
      		ttStatusTimeout(id, 10000);
      	} else if (result.remaining > (ttTokens[id].warningTimeout / 2)) {
      		if (ttTokens[id].currentClass.indexOf(C_TT_SUCCESS) >= 0) {
      			ttUpdateTimerClass(id, C_TT_WARNING);
            ttShowTimer(id);
  				}	
      		ttTimerDisplay(id, result.remaining);
	      	ttStatusTimeout(id, 1000);
      	} else {
      		if (ttTokens[id].currentClass.indexOf(C_TT_WARNING) >= 0) {
	      		ttUpdateTimerClass(id, C_TT_DANGER);
            ttShowTimer(id);
	      		displayError("The edit lock is about to timeout!")
  				}	
      		ttTimerDisplay(id, result.remaining);
	      	ttStatusTimeout(id, 1000);
      	}
      } else {
      	ttTimerDisplay(id, 0);
      }
    }
  });
}

function ttTimerDisplay(id, seconds) {
  $('#token_timer_' + id).html(ttToMinSec(seconds));
}

function ttExtendLock(id) {
  $.ajax({
    url: "/tokens/" + ttTokens[id].tokenId + "/extend_token",
    type: "GET",
    dataType: 'json',
    error: function (xhr, status, error) {
      displayError("An error has occurred extending the edit lock timeout.");
    },
    success: function(result){
    	ttUpdateTimerClass(id, C_TT_SUCCESS);
    	ttHideTimer(id);
    }
  });
}

function ttSave(id) {
  ttUpdateTimerClass(id, C_TT_SUCCESS);
  $("#token_timer_" + id).hide();
}

function ttHideTimer(id) {
  $("#token_timer_" + id).hide();
}

function ttShowTimer(id) {
  $("#token_timer_" + id).show();
}

function ttUpdateTimerClass(id, newClass) {
	$("#token_timer_" + id).removeClass(ttTokens[id].currentClass).addClass(newClass);
	ttTokens[id].currentClass = newClass;
}

function ttGetTimerClass(id) {
  var current = $("#token_timer_" + id).attr('class'); 
  if (current.indexOf(C_TT_SUCCESS) >= 0) {
    return C_TT_SUCCESS;
  } else if (current.indexOf(C_TT_WARNING) >= 0) {
    return C_TT_WARNING;
  } else if (current.indexOf(C_TT_DANGER) >= 0) {
    return C_TT_DANGER;
  } else {
    return "";
  }
}

function ttGetTimerTimeout() {
  return $('#warning_timeout').val(); 
}

function ttDisableTimerField(id) {
  $("#token_timer_" + id).prop("disabled", true);
}

function ttToMinSec(seconds) {
  var minutes = Math.floor(seconds/60);
  var seconds = seconds % 60;
  return pad(minutes, 2, '0') + ":" + pad(seconds, 2, '0');
}
