/*
* Index Panel
*
* Requires:
* index [Table] the index table
*/

/**
 * Index Panel Panel Constructor
 * @param [String] URL for data load
 * @param [String] Strict param for data load request
 * @param [Columns] Columns defs
 * @param [Int] Count (items fetched in one call)
 * @param [String] optional: 'type' param for data load request
 *
 * @return [void]
 */
function IndexPanel(url, strict_params, columns, count, kind) {
  this.url = url;
  this.strict_params = strict_params;
  this.columns = this.initColumns(columns);
  this.count = count;
  this.kind = kind;
  this.indexTable = this.initTable();

  this.loadData(0);
}

/**
 * Initializes DataTable
 *
 * @return [void]
 */
IndexPanel.prototype.initTable = function () {
 return $('#index').DataTable( {
   "order": [[ 0, "desc" ]],
   "columns": this.columns,
   "pageLength": pageLength, // Gloabl setting
   "lengthMenu": pageSettings, // Gloabl setting
   "processing": true,
   "autoWidth": false,
   "language": {
     "infoFiltered": "",
     "emptyTable": "No items found.",
     "processing": generateSpinner("medium")
   },
   "createdRow": function(row, data, dataIndex) {
    // Color-marks row by owner
    $(row).addClass(data.owner.toLowerCase() == "cdisc" ? 'row-cdisc' : 'row-sponsor');
  }
 });
}

/**
 * Ajax request to load data in table
 * @param [Int] data offset
 *
 * @return [void]
 */
IndexPanel.prototype.loadData = function (offset) {
  this.indexTable.processing(true);

  $.ajax({
    url: this.url,
    data: this.loadDataParams(this.count, offset),
    type: 'GET',
    dataType: 'json',
    context: this,
    success: function(result) {
    	for (i=0; i<result.data.length; i++) {
        var row = this.indexTable.row.add(result.data[i]);
      }
      this.indexTable.draw();

      if (result.count >= this.count)
        this.loadData(parseInt(result.offset) + this.count)
      else
        this.indexTable.processing(false);
    },
    error: function(xhr,status,error){
      handleAjaxError(xhr, status, error);
      this.indexTable.processing(false);
    }
  });
}

/**
 * Initializes columns (indicators, history button)
 * @param [DataTables Columns Definitions] columns
 *
 * @return [DataTables Columns Definitions] formatted columns with indicators, button
 */
IndexPanel.prototype.initColumns = function(columns){
	columns.push(
    { "data": "indicators", "width": "90px",
      "render" : function (data, type, row, meta) {
        return type === "display" ? formatIndicators(data) : formatIndicatorsString(data);
    }},
    { "className": "text-right",
      "render" : function (data, type, row, meta) {
        return this.historyButtonHTML(row.history_path);
    }.bind(this)}
    );

	return columns;
}

/**
 * Generates parameters for request for fetching data
 * @param [Int] Data Count
 * @param [Int] Data Offset
 *
 * @return [Object] formatted data object
 */
IndexPanel.prototype.loadDataParams = function(c, o){
	var data = {};

	var param = this.strict_params
	data[param] = { count: c, offset: o }
	if(this.kind != null)
		data[param].type = this.kind;

	return data;
}

/**
 * Generates HTML for history button
 * @param [String] item history path
 *
 * @return [String] formatted HTML
 */
IndexPanel.prototype.historyButtonHTML = function(path){
	return "<a href='"+path+"' class='btn light btn-xs'><span class='icon-old text-white'></span> History </a>";
}
