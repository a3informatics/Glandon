/*
* CDISC Changes Panel
*
*/

/**
 * CDISC Changes Panel Constructor
 * Changes are filtered by relation to a specific Sponsor Thesaurus
 *
 * @param url [String] url for the data ajax request
 * @return [void]
 */
function ChangesCdiscPanel(url) {
  this.sCallback = null;
  this.dCallback = null;
  this.id = "#changes-cdisc-table";
  this.url = url;

  this.init();
  this.setListeners();
}

/**
 * Initializes Table
 *
 * @return [void]
 */
ChangesCdiscPanel.prototype.init = function() {
  this.table = $(this.id).DataTable({
    "columns": this.columns(),
    "order": [[0, "desc"]],
    "pageLength": 50,
    "lengthMenu": pageSettings,
    "processing": true,
    "scrollY": 500,
    "scrollCollapse": true,
    "autoWidth": false,
    "ajax": {
      "url": this.url,
      "error": function (xhr, error, code) {
        handleAjaxError(xhr, status, error);
      }
    },
    "language": {
      "infoFiltered": "",
      "emptyTable": "No changes were found.",
      "processing": generateSpinner("small"),
    },
    "select": {
      "style": "single",
      "info": false
    },
    "createdRow": function( row, data, dataIndex ) {
      $(row).addClass(data.type == "deleted" ? "r" : "y");
    }
  });
}

/**
 * Sets event listeners
 *
 * @return [void]
 */
ChangesCdiscPanel.prototype.setListeners = function() {

  // Row selected event
  this.table.off("select").on("select", function(e, dt, type, indexes){
    var r = this.table.row(indexes[0]);
    try { this.sCallback(r.data()) } catch(e) { };
  }.bind(this));

  // Row deselected event
  this.table.off("deselect").on("deselect", function(e, dt, type, indexes){
    var r = this.table.row(indexes[0]);
    try { this.dCallback(r.data()) } catch(e) { };
  }.bind(this));
}

/**
 * Column definitions
 *
 * @return [void]
 */
ChangesCdiscPanel.prototype.columns = function() {
  return [
    {"data": "type", "render": function (data, type, row, meta) {
        if (type == "display")
          return this.typeHTML(data);
        return data;
      }.bind(this)
    },
    {"data": "notation", "render": function (data, type, row, meta) {
        return this.itemHTML(row);
      }.bind(this)
    }
  ];
}

/**
 * HTML for the deleted / updated icons and tooltips
 *
 * @param type [String] "d" deleted, or "u" updated
 * @return [String] formatted HTML
 */
ChangesCdiscPanel.prototype.typeHTML = function(type) {
  var icon = (type == "deleted" ? "icon-times-circle text-accent-2" : "icon-update text-accent-1");
  var name = (type == "deleted" ? "Deleted" : "Updated");

  return "<span class='" + icon + " text-xlarge i-centered ttip'>" +
    "<span class='ttip-text ttip-table shadow-small text-small text-medium'>" + name + "</span>" +
  "</span>";
}

/**
 * Generates HTML for a child item in the table
 *
 * @param data [JSON Object] Child item JSON
 * @return [String] Formatted HTML
 */
ChangesCdiscPanel.prototype.itemHTML = function(data) {
  var html = '<div class="font-regular text-small">'+data.label+'</div>';
  html += '<div class="font-light text-small">'+data.notation+' ('+data.identifier+')</div>';
  return html;
}
