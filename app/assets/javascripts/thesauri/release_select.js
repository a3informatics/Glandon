/*
* Release Select page
*
*
*/
$(document).ready(function(){
  var releaseSelect = new ReleaseSelect();
  var unload = new Unload(false);
});

/**
 * Release Select Constructor
 * This class is only a wrapper for code organization. It is page specific and should not be used elsewhere.
 *
 * @return [void]
 */
function ReleaseSelect(){
  this.referenceThUrl = referenceThUrl;

  this.timeline = this.initTimelineSlider();
  this.cdiscCT = this.initCdiscCt();
  this.timer = this.initTimer();
  this.tabs = this.initTabs();
  this.setEventListeners();

  // Load CDISC code lists if a version had been selected previously
  if(this.cdiscCT.versionId != null){
    this.tabs.cdiscTab.refresh(this.makeCdiscUrl(this.cdiscCT.versionId));
    $(".tab-option.disabled").removeClass("disabled");
  }
}

/**
 * Initializes TimelineSlider
 *
 * @return [TimelineSlider]
 */
ReleaseSelect.prototype.initTimelineSlider = function(){
  var tl = new TimelineSlider($(".timeline-container"), $("#timeline-start-btn"), null, $(".timeline-point"));
  tl.disableRange(tl.tl_points.eq(0).text(), $("#cdisc-version-label").text());
  return tl;
}

/**
 * Initializes edit lock timer
 *
 * @return [Timer instance]
 */
ReleaseSelect.prototype.initTimer = function(){
  return new Timer($('#edit_lock_token').val(), "imh_header", $('#warning_timeout').val());
}

/**
 * Initializes CDISC CT information. If none, defaults
 *
 * @return [Object] {version, versionId}
 */
ReleaseSelect.prototype.initCdiscCt = function(){
  var cdiscVer = $("#cdisc-version-label").text() == "None" ? null : $("#cdisc-version-label").text();
  var cdiscVerId = cdiscVer == null ? null : $(".timeline-point:contains("+cdiscVer+") span").attr("data-index");

  // Set slider to latest version as default if CDISC version hadn't been previously selected
  if (cdiscVer == null)
    cdiscVer = this.timeline.tl_points.eq(-1).children().first().html();

  return {version: cdiscVer, versionId: cdiscVerId};
}

/**
 * Initializes all the tabs on the page
 *
 * @return [Object] of tab references {cdiscTab, sponsorClTab, sponsorSubsetsTab, sponsorExtensionsTab, target}
 */
ReleaseSelect.prototype.initTabs = function(){
  var overview = new ManagedChildrenSelectOverview(overviewUrls, "#table-selection-overview", 1000, this);
  var cdiscCls = new ManagedChildrenSelect(cdiscCLUrl, "#table-cdisc-cls", 1000, overview, "thCodeList").init().setListeners();
  var sponsorCls = new ManagedChildrenSelect(sponsorCLUrl, "#table-sponsor-cls", 1000, overview, "thCodeList", "normal").init().setListeners();
  var sponsorSubsets = new ManagedChildrenSelect(sponsorCLUrl, "#table-sponsor-subsets", 1000, overview, "thCodeList", "subsets").init().setListeners();
  var sponsorExtensions = new ManagedChildrenSelect(sponsorCLUrl, "#table-sponsor-extensions", 1000, overview, "thCodeList", "extensions").init().setListeners();

  return {cdiscTab: cdiscCls, sponsorClTab: sponsorCls, sponsorSubsetsTab: sponsorSubsets, sponsorExtensionsTab: sponsorExtensions, target: overview};
}

/**
 * Changes CDISC version, reloads data, updates UI
 *
 * @return [void]
 */
ReleaseSelect.prototype.changeCdiscVer = function(){
  this.cdiscCT.versionId = $(".timeline-point.point-highlight span").attr("data-index");
  this.cdiscCT.version = $(".timeline-point.point-highlight span").first().text();

  this.referenceThUpdate();
}

/**
 * Sets the referenced thesaurus to a CDISC version via ajax, clears all CDISC data from the thesaurus, reloads new version data
 *
 * @return [void]
 */
ReleaseSelect.prototype.referenceThUpdate = function(){
  this.tabs.cdiscTab.processing(true, "Updating CDISC version...");

  $.ajax({
    url: this.referenceThUrl,
    data: {thesauri: {thesaurus_id: this.cdiscCT.versionId}},
    type: 'PUT',
    dataType: 'json',
    context: this,
    success: function (result) {
      // Refresh
      location.reload();
    },
    error: function (xhr, status, error) {
      $("#select-cdisc-ver-button").removeClass("disabled");
      $(".tab-wrap .expandable-content-btn").click();
			handleAjaxError(xhr, status, error);
			this.tabs.cdiscTab.processing(false);
		}
  })
}

/**
 * Sets various event handlers on the page
 *
 * @return [void]
 */
ReleaseSelect.prototype.setEventListeners = function(){
  var _this = this;

  // Timeline Slider displayed event handler
  $(".card-with-tabs .expandable-content-btn").one("change", function(){
    _this.timeline.moveToDate(_this.timeline.l_slider, _this.cdiscCT.version);
    $(".timeline-container").data(_this.timeline);
  });

  // Submit version change event handler
  $("#select-cdisc-ver-button").on("click", function(){
    if ($(".timeline-point.point-highlight span").text() == $("#cdisc-version-label").html())
      return;
    else if (_this.cdiscCT.versionId == null)
      _this.changeCdiscVer();
    else
      new ConfirmationDialog(function() { _this.changeCdiscVer() },
        {subtitle: "If you change CDISC version, the CDISC Code Lists which have changed between the versions will be updated in your thesaurus."+
                    " Deleted CDISC Code Lists will be removed." +
                    " Any created CDISC Code Lists will not be added. This operation cannot be undone.", dangerous: true})
        .show();
  });

  // Define handlers for tabs switched
  $(".tab-option").on("switch", function(e, id){
    switch(id){
      case "tab-sponsor-cls":
        _this.loadTab(_this.tabs.sponsorClTab);
        break;
      case "tab-sponsor-subsets":
        _this.loadTab(_this.tabs.sponsorSubsetsTab);
        break;
      case "tab-sponsor-extensions":
        _this.loadTab(_this.tabs.sponsorExtensionsTab);
        break;
    }
  });
}

/**
 * Calls auto deselect on each tab instance (except for the overview tab)
 *
 * @return [void]
 */
ReleaseSelect.prototype.autoDeselectAllTabs = function(data){
  $.each(this.tabs, function(k,v){
    if(k != "target")
      v.autoDeselect(data);
  });
}

/**
 * Loads data into tab reference if not done yet
 * @param [Instance reference] tab to be loaded
 *
 * @return [void]
 */
ReleaseSelect.prototype.loadTab = function(tab){
  if(!tab.dataLoaded)
    tab.loadData(0, tab.autoSelect.bind(tab) );
}

/**
 * Generates URL string for CDISC data fetching based on CT id
 * @param [String] terminology ID
 *
 * @return [String] URL to fetch CDISC CT children
 */
ReleaseSelect.prototype.makeCdiscUrl = function(id){
  return cdiscCLUrl.replace("th_id", id)
}
