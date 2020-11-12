/*
* Upgrade Panel (Wraps Impact Graph panel functions)
*
*/

/**
 * Upgrade Panel Constructor
 * Gets data, builds and renders impact graph, handles events
 *
 * @return [void]
 */
function UpgradePanel(dataUrl, upgradeUrl) {
  this.impact = new ImpactGraph(dataUrl, true, false);
  this.upgradeUrl = upgradeUrl;
  this.tabName = "tab-affected";
  this.initTable();
  this.setListeners();
}

/**
 * Makes the upgrade
 *
 * @return [void]
 */
UpgradePanel.prototype.upgrade = function(url, callback) {
  this.impact.loading(true);

  $.ajax({
    url: url,
    type: 'PUT',
    dataType: 'json',
    context: this,
    success: function (result) {
      this.impact.loading(false);
      try { callback() }catch(e){ };
    },
    error: function (xhr, status, error) {
			handleAjaxError(xhr, status, error);
      this.impact.loading(false);
		}
  })
}

/**
 * Sets event handlers
 *
 * @return [void]
 */
UpgradePanel.prototype.setListeners = function() {
  var _this = this;

  $(this.impact.itemList.tableId + " tbody")
    .off("click", ".upgrade")
    .on("click", ".upgrade", function(){
      var buttonEl = $(this);
      var data = _this.impact.itemList.table.row(buttonEl.parents("tr:first")).data();
      var itemId = data.id, sourceId = data.source_id, targetId = data.target_id;
      var cback = function(){
        displaySuccess("Item was successfully upgraded");
        _this.loadData(_this.currentItem);
      }.bind(_this)
      _this.upgrade(_this.makeUrl(itemId, sourceId, targetId), cback);
  });
}

/**
 * Clears table, adds column, reinitializes
 *
 * @return [void]
 */
UpgradePanel.prototype.initTable = function() {
  this.impact.itemList.columns.push(
    { "data": "id",
      "orderable": false,
      "render": function(data, type, row, meta) {
        return this.upgradeButtonHTML(row);
      }.bind(this) });

  this.impact.itemList.table.destroy();
  $(this.impact.itemList.tableId + " thead tr").append("<th class='fit'></th>");
  this.impact.itemList.initTable();
}

/**
 * Generates URL for impact data
 *
 * @param id [String] id of the item to be upgraded
 * @param source [String] id of cdisc source code list
 * @param target [String] id of the new version of the cdisc code list
 * @return [String] formatted URL
 */
UpgradePanel.prototype.makeUrl = function(id, source, target) {
  return this.upgradeUrl.replace("clId", id);
}

/**
 * Loads data from server or cache, if present
 *
 * @param item [Object] Clicked Row Data from the History Panel
 * @return [void]
 */
UpgradePanel.prototype.loadData = function(item) {
  this.currentItem = item;
  this.impact.loadData(item);
}

/**
 * Generates HTML for the upgrade button
 *
 * @return [String] Formatted HTML
 */
UpgradePanel.prototype.upgradeButtonHTML = function(item) {
  if (item.upgraded)
    return "<button class='btn medium grey disabled'>Cannot upgrade</button>";
  else
    return "<button class='btn medium light upgrade'><span class='icon-upgrade text-small'></span> Upgrade</button>";
}
