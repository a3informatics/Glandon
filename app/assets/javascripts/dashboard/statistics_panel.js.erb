/*
* Statistics Panel
*
*/

/**
 * Statistics Panel Constructor
 *
 * @return [void]
 */
function StatisticsPanel(id, url) {
  var _this = this;

  this.url = url;
  this.id = id;

  $("#"+this.id).find(".stats-block").each(function(){
    _this.getData(this.id);
  });

}

/**
 * When
 *
 * @return [void]
 */
StatisticsPanel.prototype.getData = function (id) {
  var _this = this;

  $.ajax({
    method: "GET",
    url: "audit_trail/stats_"+id,
    dataType: 'json',
    success: function(result) {
      _this.populateList(id, result);
    },
    error: function(xhr,status,error){
      handleAjaxError(xhr, status, error);
    }
  });
}

StatisticsPanel.prototype.populateList = function (id, jsonData) {
  var _this = this;

  $.each(jsonData.data, function(key,val){
    var listE = $("#"+id).find(".list-wrap");

    if($.type(val) != "object")
      listE.append(_this.generateItemHTML(key, val, 0));
    else{
      listE.append(_this.generateItemHTML(key, val, 1));
      $.each(val, function(key2, val2){
        listE.append(_this.generateItemHTML(key2, val2, 2));
      });
    }
  });
}

StatisticsPanel.prototype.generateItemHTML = function (k, v, level) {
  var txt = level != 1 ? ("<span class='font-regular'>"+ k + "</span>: " + v) : k;
  return "<div class='list-item lvl-"+level+"'> " + txt + "</div>";
}
