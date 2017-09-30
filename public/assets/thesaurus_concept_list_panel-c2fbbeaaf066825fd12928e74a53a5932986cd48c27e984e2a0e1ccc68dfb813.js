/*
* Thesaurus Concept Panel
* 
* Requires:
* thesaurus_concept_table [Table] the terminology table
*/

/**
 * Terminology List Panel Constructor
 *
 * @return [Null]
 */

function ThesaurusConceptListPanel() {
  var _this = this;
  this.currentRow = null;
  this.map = {};
	this.tcTable = $('#thesaurus_concept_table').DataTable( {
		"rowId": 'key',
    "columns": [
      {"data" : "parentIdentifier"},
      {"data" : "identifier"},
      {"data" : "notation"},
      {"data" : "preferredTerm"},
      {"data" : "synonym"},      
      {"data" : "definition"},
      {"render" : function (data, type, row, meta) {
        return '<a href="/cdisc_clis/changes?id=' + row.id + '" class="btn btn-primary btn-xs">Changes</a>';
      }}     
    ],
    "pageLength": pageLength, // Gloabl setting
    "lengthMenu": pageSettings, // Gloabl setting
    "processing": true,
    "scroller": true,
    "language": {
      "processing": "<img src='/assets/processing-9034d5d34015e4b05d2c1d1a8dc9f6ec9d59bd96d305eb9e24e24e65c591a645.gif'>"
    }
  });
}

/**
 * Add item to table
 *
 * @param uri [String] the uri of the item being added
 * @param key [Integer] a unique reference
 * @return [Null]
 */
ThesaurusConceptListPanel.prototype.add = function (uri, key) {
  var _this = this;
  if (!this.map.hasOwnProperty(uri)) {
  	_this.map[uri] = key;
  	$.ajax({
	    url: "/thesaurus_concepts/" + getId(uri),
	    type: "GET",
	    data: { "namespace": getNamespace(uri) },
	    dataType: 'json',
	    error: function (xhr, status, error) {
	      handleAjaxError(xhr, status, error);
	    },
	    success: function(result) {
	      result.key = key;
	      _this.tcTable.row.add(result);
	      _this.tcTable.draw();
	    }
	  });
	}
}

/**
 * Highlight
 *
 * @param key [Integer] a unique reference
 * @return [Null]
 */
ThesaurusConceptListPanel.prototype.highlight = function (key) {
  if (this.currentRow !== null) {
    $(this.currentRow).toggleClass('success');
  }
  var row = this.tcTable.row('#' + key);
  this.currentRow = row.nodes();
  this.moveToPage(row);
  $(this.currentRow).toggleClass('success')
}

ThesaurusConceptListPanel.prototype.clear = function () {
  if (this.currentRow !== null) {
    $(this.currentRow).toggleClass('success');
  }
  this.currentRow = null;
}

/**
 * Move To Page
 *
 * @param row [Object] the datatables row object
 * @return [Null]
 */
ThesaurusConceptListPanel.prototype.moveToPage = function (row) {
	var page_info = this.tcTable.page.info();
  var new_row_index = row.index();
  var row_position = this.tcTable.rows()[0].indexOf(new_row_index);
  if( row_position >= page_info.start && row_position < page_info.end ) {
    return;
  }
  var page_to_display = Math.floor( row_position / this.tcTable.page.len() );
  this.tcTable.page(page_to_display);
  this.tcTable.draw(false);
  return;
}
;
