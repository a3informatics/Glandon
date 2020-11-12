/*
* CDISC Version Select Modal
*
* Requires:
* #cdisc-select-modal [Partial]
*/

/**
 * CDISC Version Select Modal Constructor
 *
 * @param callback [Function] Version selected callback
 * @param description [String] Type of text description in the modal, if null, will remain default
 * @return [void]
 */
function CdiscVersionSelect(callback, description) {
  this.callback = callback;
  this.id = "#cdisc-select-modal";
  this.init();

  if(description != null)
    $(this.id + " #tl-slider-title").html(this.descriptions(description));

  return this;
}


/**
 * Initalizes Slider, and sets listeners
 *
 * @return [void]
 */
CdiscVersionSelect.prototype.init = function () {
  this.ts = new TimelineSlider($(this.id + " .timeline-container"), $(this.id + " #timeline-start-btn"), null, $(this.id + " .timeline-point"));

  $(this.id).off('shown.bs.modal').on('shown.bs.modal', function () {
    this.ts.moveToDate(this.ts.l_slider, latestCDISCVer);
  }.bind(this));


  $("#select-cdisc-ter-btn").off("click").on("click", function() {
    var selectedPoint = $(this.id + " .timeline-point.point-highlight span");
    var selectedDate = parseDateString(selectedPoint.text());
    var selectedId = selectedPoint.attr("data-index");

    this.callback(selectedDate, selectedId);
  }.bind(this));
  $('.timeline-container').data(this.ts)
}

/**
 * Opens Modal
 *
 * @return [void]
 */
CdiscVersionSelect.prototype.open = function () {
  $(this.id).modal('show');
}

/**
 * Add custom modal descriptions here
 *
 * @param name [String] key to map
 * @return [String] description from map by key
 */
CdiscVersionSelect.prototype.descriptions = function (name) {
  var descriptionsMap = {
    impact: "To continue, choose version of the CDISC Terminology for Impact Analysis and click Select. <br/> The selected version must be newer than the one this terminology is currently using."
  }

  return descriptionsMap[name];
}
