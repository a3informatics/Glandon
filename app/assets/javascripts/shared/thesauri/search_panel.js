/*
* Search Panel. Panel used to search terminologies. Paginated.
*/

/**
* SearchPanel Constructor
*
* @param url [String] url for the search
* @return [void]
*/
function SearchPanel(url, searchingMultiple) {
  this.url = url;
  this.tsSearchTable = null;
  this.length = 10000;
  this.active = false;
  this.searchingMultiple = (searchingMultiple == null ? true : searchingMultiple);
  this.filterPageSettings();
  this.initTable();
  this.cleanupInit();
  this.setListeners();

  $("#search-help").on("click", function(){
    new InformationDialog({div: $("#information-dialog-search")}).show();
  });
}

/**
* Initialise Table
*
* @return [void]
*/
SearchPanel.prototype.initTable = function () {
  this.tsSearchTable = $('#searchTable').DataTable( {
    "pageLength": pageLength,
    "lengthMenu": pageSettings,
    "columns": this.columns(),
    "processing": true,
    "scrollY": 500,
    "scrollX": true,
    "scrollCollapse": true,
    "language": {
      "infoFiltered": "",
      "emptyTable": "Make a new column or global search to see data",
      "processing": generateSpinner("small"),
      "sSearch": "Filter:"
    },
    "orderCellsTop": true,
  });

  this.toggleFilters(false);
}



/**
* Performs a search on the current input values
*
* @return [void]
*/
SearchPanel.prototype.search = function () {
  this.tsSearchTable.clear().draw();
  this.toggleFilters(true);
  this.toggleInputs(false);
  this.ajaxActive(true);
  this.tsSearchTable.processing(true);
  this.serverSearch(0, this.length);
  this.tsSearchTable.search("");
  this.clearInput("#searchTable_wrapper tfoot input");
}

/**
* Performs a paginated server search
*
* @return [void]
*/
SearchPanel.prototype.serverSearch = function (offset, length) {
  this.ajax = $.ajax({
    url: this.url,
    data: this.searchData(offset, length),
    type: 'GET',
    dataType: 'json',
    context: this,
    success: function(result) {
    	for (i = 0; i < result.data.length; i++) {
        this.tsSearchTable.row.add(result.data[i]);
      }
      this.tsSearchTable.draw();
      this.tsSearchTable.processing(false);

      if (result.recordsFiltered >= length) {
        this.serverSearch(offset + length, length);
      }
      else {
        this.tsSearchTable.processing(false);
        this.toggleInputs(true);
        this.ajaxActive(false);
      }
    },
    error: function(xhr,status,error){
      if (xhr.statusText != 'abort')
        handleAjaxError(xhr, status, error);

      this.tsSearchTable.processing(false);
      this.toggleInputs(true);
      this.ajaxActive(false);
    }
  });
}

/**
* Sets event handlers
*
* @return [void]
*/
SearchPanel.prototype.setListeners = function () {
  this.searchInputEvent();
  this.overallSearchEvent();
  this.columnFilterEvent();
  this.rowClickEvent();
  this.rowDblClickEvent();
  $("#clear_button").on("click", this.clearSearch.bind(this));
  $("#abort_button").on("click", function() { if(this.ajax != null) { this.ajax.abort(); } }.bind(this));
}

/**
* Row Single Click Event
*
* @return [void]
*/
SearchPanel.prototype.rowClickEvent = function () {
  var _this = this;

  $('#searchTable tbody').on('click', 'tr', function () {
    if (!_this.active) {
      $("#searchTable tr.selected").removeClass('selected');
      $(this).addClass('selected');
    }
  });
}

/**
* Row Double Click Event
*
* @return [void]
*/
SearchPanel.prototype.rowDblClickEvent = function () {
  var _this = this;

  $('#searchTable tbody').on('dblclick', 'tr', function () {
    if (!_this.active) {
      var data = _this.tsSearchTable.row(this).data();
      _this.clearSearch();
      $('#searchTable_csearch_parent_identifier').val(data.parent_identifier);
      _this.search();
    }
  });
}

/**
* Setup Filter Input Event
*
* @return [void]
*/
SearchPanel.prototype.columnFilterEvent = function () {
  this.tsSearchTable.columns().every(function () {
      var that = this;

      $('input.filter-local', this.footer()).on('keyup change clear', function () {
          if (that.search() !== this.value)
              that.search(this.value).draw();
      });
  });
}


/**
* Setup Overal Search Event
*
* @return [void]
*/
SearchPanel.prototype.overallSearchEvent = function () {
  var _this = this;

  $("#overall_search").on("keyup", function(e) {
    if(e.keyCode == 13 && this.value != "" && !_this.active)
      _this.search();
  });
}

/**
* Setup Search Input Event. Apply the column search. Fires on return or field empty assuming not the
* current search value (i.e. something has changed).
*
* @return [void]
*/
SearchPanel.prototype.searchInputEvent = function () {
  var _this = this;
  $('#searchTable_wrapper thead input.search-server').on('keyup', function (e) {
    if (e.keyCode == 13 && this.value != "" && !_this.active)
      _this.search();
  });
}

/**
* Clears the table of records, and inputs of any text
*
* @return [void]
*/
SearchPanel.prototype.clearSearch = function () {
  if (!this.active) {
    this.tsSearchTable.search("");
    this.clearInput("#overall_search, #searchTable_wrapper thead input, #searchTable_wrapper tfoot input");
    this.toggleFilters(false);
    this.tsSearchTable.clear().draw();
  }
}

/**
* Clears input value
*
* @param target [String] JQuery selector
* @return [void]
*/
SearchPanel.prototype.clearInput = function (target) {
  $(target).val("");
  $(target).trigger("change");
}

/**
* Enables / Disables the table search inputs
*
* @param enable [Boolean] true/false - enable/disable search inputs
* @return [void]
*/
SearchPanel.prototype.toggleInputs = function (enable) {
  $("#overall_search, #searchTable_wrapper thead input").prop("disabled", !enable);
}

/**
* Enables / Disables the table footer filters
*
* @param enable [Boolean] true/false - enable/disable filters
* @return [void]
*/
SearchPanel.prototype.toggleFilters = function (enable) {
  enable ? $("#searchTable_wrapper .dataTables_scrollFoot").show() : $("#searchTable_wrapper .dataTables_scrollFoot").hide();
}

/**
* Enables / Disables the active ajax state
*
* @param active [Boolean] true/false - enable/disable active ajax state
* @return [void]
*/
SearchPanel.prototype.ajaxActive = function (active) {
  this.active = active;
  active ? $("#search_active_info").show() : $("#search_active_info").hide();
}

/**
* Generates AJAX request data
*
* @return [Object] request data
*/
SearchPanel.prototype.searchData = function (start, length) {
  var order = this.tsSearchTable.order()[0];
  var reqData = {
    columns: {},
    order: {
      0: {
        column: order[0],
        dir: order[1]
      }
    },
    start: start,
    length: length,
    search: {
      value: $("#overall_search").val().trim()
    }
  };

  this.tsSearchTable.columns().every( function (index) {
    if ($(this.header()).attr("data-search") == "false")
      return;

    var value = $('#searchTable_wrapper thead tr:eq(1) th:eq(' + index + ') .search-server').val().trim();
    var data = this.dataSrc();
    reqData.columns[index] = {
      data: data,
      search: {
        value: value
      }
    }
  });
  return reqData;
}

/**
* Cleans up duplicated elements from DT init
*
* @return [void]
*/
SearchPanel.prototype.cleanupInit = function () {
  $("table#searchTable thead input, table#searchTable tfoot input").each(function(i) {
    $(this).removeAttr("id");
  });
}


/**
* Column definitions
*
* @return [Object Array] column definition objects
*/
SearchPanel.prototype.columns = function () {
  var columns = [
    {"data" : "parent_identifier", "width" : "7%"},
    {"data" : "parent_label", "width" : "8%"},
    {"data" : "identifier", "width" : "7%"},
    {"data" : "notation", "width" : "8%"},
    {"data" : "preferred_term", "width" : "7%" },
    {"data" : "synonym", "width" : "7%" },
    {"data" : "definition", "width" : "28%"},
    {"data" : "tags", "width" : "7%", "render" : function (data, type, row, meta) {
      return (data == null ? data : colorCodeTagsBadge(data) )
    }}
  ];

  if (this.searchingMultiple) {
    columns.push({"data" : "thesaurus_identifier", "width" : "4%"});
    columns.push({"data" : "thesaurus_version", "width" : "4%"});
  }

  return columns;
}

/**
* Removes the 'All' option from the page settings
*
* @return [void]
*/
SearchPanel.prototype.filterPageSettings = function () {
  pageSettings[0] = $.grep(pageSettings[0], function(v) { return v != -1; });
  pageSettings[1] = $.grep(pageSettings[1], function(v) { return v != "All"; });
  pageLength = pageLength == -1 ? Math.max.apply(Math, pageSettings[0]) : pageLength;
}
