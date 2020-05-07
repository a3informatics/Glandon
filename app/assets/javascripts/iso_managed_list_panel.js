/*
* Managed Item Panel
*
* Requires:
* managed_item_table [Table] the managed item table
*/

/**
 * ISO Managed List Panel Constructor
 *
 * @return [void]
 */
function IsoManagedListPanel() {
  var _this = this;
  this.currentRow = null;
  this.map = {};
	this.miTable = $('#managed_item_table').DataTable( {
		"rowId": 'key',
    "columns": [
      {"data" : "scoped_identifier.identifier"},
      {"data" : "label"},
      {"data" : "scoped_identifier.semantic_version"},
      {"data" : "scoped_identifier.version_label"},
      {"render" : function (data, type, row, meta) {
        return '<a href="' + getPathStrong(row.type, row.id, row.namespace) + '" class="btn  btn-xs">Show</a>';
      }}
    ],
    "pageLength": pageLength, // Gloabl setting
    "lengthMenu": pageSettings, // Gloabl setting
    "processing": true,
    "scroller": true,
    "language": {
      "processing": generateSpinner("small")
    }
  });
}

/**
 * Add item to table
 *
 * @param [String] uri the uri of the item being added
 * @param [Integer] key a unique reference
 * @return [void]
 */
IsoManagedListPanel.prototype.add = function (uri, key) {
  var _this = this;
  if (!this.map.hasOwnProperty(uri)) {
  	_this.map[uri] = key;
    $.ajax({
	    url: "/iso_managed/" + getId(uri),
	    data: { "namespace": getNamespace(uri) },
	    type: 'GET',
	    dataType: 'json',
	    success: function(result) {
	    	result.key = key;
	      _this.miTable.row.add(result);
	      _this.miTable.draw();
	    },
	    error: function(xhr,status,error){
	      handleAjaxError(xhr, status, error);
	    }
	  });
	}
}

/**
 * Highlight
 *
 * @param [Integer] key a unique reference
 * @return [void]
 */
IsoManagedListPanel.prototype.highlight = function (key) {
  if (this.currentRow !== null) {
    $(this.currentRow).toggleClass('success');
  }
  var row = this.miTable.row('#' + key);
  this.currentRow = row.nodes();
  this.moveToPage(row);
  $(this.currentRow).toggleClass('success')
}

/**
 * Clear the highlight
 *
 * @return [void]
 */
IsoManagedListPanel.prototype.clear = function () {
  if (this.currentRow !== null) {
    $(this.currentRow).toggleClass('success');
  }
  this.currentRow = null;
}

/**
 * Move To Page
 *
 * @param [Object] row the datatables row object
 * @return [void]
 */
IsoManagedListPanel.prototype.moveToPage = function (row) {
	var page_info = this.miTable.page.info();
  var new_row_index = row.index();
  var row_position = this.miTable.rows()[0].indexOf(new_row_index);
  if( row_position >= page_info.start && row_position < page_info.end ) {
    return;
  }
  var page_to_display = Math.floor( row_position / this.miTable.page.len() );
  this.miTable.page(page_to_display);
  this.miTable.draw(false);
  return;
}
