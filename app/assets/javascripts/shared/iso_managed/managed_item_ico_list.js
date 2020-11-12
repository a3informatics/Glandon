/*
 * Managed Item Icon Table
 *
 * Requires:
 * managed-item-icon-table [Table]
 */

/**
 * Managed Item Icon Table Constructor
 *
 * @return [void]
 */
function ManagedItemIconList(emptyTableText) {
	this.tableId = "#managed-item-icon-table";
	this.emptyTable = emptyTableText || "No items were found.";
	this.columns = this.columns();
  this.initTable();
  return this;
}

/**
 * Initializes the DataTable
 *
 * @return [void]
 */
ManagedItemIconList.prototype.initTable = function (columns) {
	this.table = $(this.tableId).DataTable({
		"order": [[0, "desc"]],
		"columns": this.columns,
		"pageLength": pageLength,
		"lengthMenu": pageSettings,
		"processing": true,
		"paging": true,
		"autoWidth": false,
		"language": {
			"infoFiltered": "",
			"emptyTable": this.emptyTable,
			"processing": generateSpinner("small")
		}
	});
}

/**
 * Loads data from server
 *
 * @param dataUrl [String] data source url, optional
 * @return [void]
 */
ManagedItemIconList.prototype.loadData = function (dataUrl) {
  //TODO
}

/**
 * Clears table and adds new rows to table
 *
 * @param items [Array] Array of data objects, must contain values identifier, label, notation, owner and rdf_type
 * @return [void]
 */
ManagedItemIconList.prototype.addItems = function (items) {
  this.table.clear();
  this.loading(true)

  $.each(items, function(i, e){
    this.table.row.add(e);
  }.bind(this));

  this.table.draw();
  this.loading(false);
}

/**
* Enable / disable loading
 *
 * @param enable [Boolean] true/false ~ show / hide loading
 * @return [void]
 */
ManagedItemIconList.prototype.loading = function (enable) {
  this.table.processing(enable);
}

/**
 * Column definitions
 *
 * @return [Array] Columns definition objects
 */
ManagedItemIconList.prototype.columns = function () {
  var _this = this;

	return [
    {
      "data": "rdf_type",
      "render": function (data, type, row, meta) {
        if (type == "display")
					return typeToColorIconBadge(data, {size: "med", owner: row.owner});
        else
					return typeToString[data];
			}
    },
    {
      "data": "identifier",
      "render": function (data, type, row, meta) {
          return _this.itemHTML(row);
      }
    },
  ];
}

/**
 * Generates HTML for a child item in the table
 *
 * @param data [JSON Object] Child item JSON
 * @return [String] Formatted HTML
 */
ManagedItemIconList.prototype.itemHTML = function(data) {
  data.notation == null ? "" : data.notation;
  data.label == null ? "Empty label" : data.label;

  var html = '<div class="font-regular text-small">'+data.label+'<span class="font-light"> ('+typeToString[data.rdf_type]+')</span></div>';
  html += '<div class="font-light text-small">'+data.notation+' ('+data.identifier+')</div>';
  return html;
}
