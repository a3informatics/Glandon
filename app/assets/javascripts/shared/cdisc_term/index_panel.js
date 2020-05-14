function IndexPanel(url) {
  this.url = url;
  this.processing(false);
  this.init();
}

IndexPanel.prototype.init = function () {
  $("#go_button").on("click", function() {
    this.loadData(this.makeUrlFromSlider());
  }.bind(this));

  $("#results_div").parent().append(generateSpinnerWText("medium", "Fetching results..."));
  $('.spinner-container').hide();
}

IndexPanel.prototype.loadData = function (url) {
  this.processing(true);

  $.ajax({
    url: url,
    type: 'GET',
    dataType: 'json',
    context: this,
    success: function(result) {
      this.processing(false);
      this.results("#created_div", result.data.created);
      this.results("#deleted_div", result.data.deleted);
      this.results("#updated_div", result.data.updated);
    },
    error: function(xhr,status,error){
      this.processing(false);
      handleAjaxError(xhr, status, error);
    }
  });
}

IndexPanel.prototype.makeUrlFromSlider = function () {
  return this.url
    .replace("compareThIdFirst", $(".point-highlight").eq(0).find(".ttip-text").attr("data-index"))
    .replace("compareThIdSecond", $(".point-highlight").eq(1).find(".ttip-text").attr("data-index"));
}

IndexPanel.prototype.processing = function (enable) {
  if (enable) {
    $('.spinner-container').show();
    $('#results_div').hide();
  }
  else {
    $('.spinner-container').hide();
    $('#results_div').show();
  }
}

IndexPanel.prototype.results = function(div, data) {
  var badge_class = this.getBadgeClass(div);

  // Reset
  this.resetViewToDefault($(div).parent());
  var html = '';

  $.each( data, function( key, value ) {
    html += '<a href="' + value.changes_path + '" class="item '+value.label.replace(/^[0-9\s]+/, '')[0].toUpperCase() +'">';
    html += ' <div class="list-card shadow-small">';
    html += '   <div class="card-badge '+badge_class+'"></div>';
    html += '     <div class="text">' + value.label + '</div>';
    html += '     <div class="text sub-text">' + value.notation + ' ' + '(' + value.identifier + ')</div>';
    html += ' </div>';
    html += '</a>';
  });

  if(data.length == 0)
    $(div).find(".no-results-msg").show();

  $(div).append(html);
  $(div).parent().find(".amount").html(data.length);
}

IndexPanel.prototype.getBadgeClass = function(div){
  switch (div) {
    case "#created_div":
      return "bg-sec-light";
      break;
    case "#updated_div":
      return "bg-accent-1";
      break;
    case "#deleted_div":
      return "bg-accent-2";
      break;
  }
}

// Resets UI to default, called when new query is triggered
IndexPanel.prototype.resetViewToDefault = function(div){
  div.find(".item").remove();
  div.find(".no-results-msg").hide();
  div.find(".alph-slider").val(1);
  div.find(".circular-badge").html('A');
  div.find(".filter-expandable").addClass("collapsed");
  div.find(".filter-btn").removeClass("highlight");
}
