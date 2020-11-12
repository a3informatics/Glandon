/*
* Generic Dashboard Panel
*
*/

/**
 * Dashboard Panel Constructor
 *
 * @return [void]
 */
function DashboardPanel(id, url, parameter) {
  var _this = this;


  this.url = url;
  this.id = "#"+id;
  this.param = parameter;

  this.init();
}

/**
 * Initializes panel and loads data
 *
 * @return [void]
 */
 DashboardPanel.prototype.init = function(){
   var _this = this;
   $(_this.id).DataTable({
     "pagingType": "full",
     "ajax": {
       "url": _this.url,
       "dataSrc": "data",
       "error": function (xhr, error, code) {
         handleAjaxError(xhr, status, error);
       }
     },
     "language": {
       "infoFiltered": "",
       "processing": generateSpinner("medium")
     },
     "bProcessing": true,
     "paging": false,
     "scrollY": 265,
     "lengthMenu": [[5, 10, 25, 50], [5, 10, 25, 50]],
     "columns": [
       {"data" : "", "render": function(data,type,full,meta) {
         var url = _this.generateURL(full);
         var color = _this.generateColor(full.owner);
         return _this.generateManagedItemListHTML(url, color, full);
       }}
     ]
   });
 }

// WARNING: This has identical HTML code as a partial in shared/iso_managed/_managed_item_card_list. If you change one, change the other one too!
DashboardPanel.prototype.generateManagedItemListHTML = function(url, color, item){
   var html = "<a class='card-item hover-indent shadow-small' href='" + url + "''>"
   html += "<div class='circular-badge med " + color + "'><span class='icon-terminology text-white'></span></div>";
   html += "<div class='card-item-info'>";
   html += "<div class='font-regular text-normal'>" + item.label + "</div>";
   html += "<div class='font-light text-small'>" + item.owner + " &nbsp; | &nbsp; Identifier: " + item.identifier + "</div>";
   html += "</div>";
   html += "</a>";
   return html;
}

DashboardPanel.prototype.generateURL = function(data){
  var _this = this;
  var query_string = 'identifier='+ data.identifier +'&scope_id=' + data.scope_id;

  if(_this.param !== "") {
    query_string = _this.param + '[identifier]=' + data.identifier + '&' + _this.param + '[scope_id]=' + data.scope_id
  }
  return _this.url + '/history?' + query_string;
}

DashboardPanel.prototype.generateColor = function(owner) {
  var color = ~(owner.toUpperCase()).indexOf("CDISC") ? "bg-accent-1" : "bg-prim-light"
  return color;
}
