/*
* Links Panel
*
*/

/**
* Links Panel Constructor
* @param url [String] The url to make the ajax call
* @param panelId [String] The id assigned to the panel
*
* @return [void]
*/
function LinksPanel(url, panelId, panelTitle) {
  this.url = url;
  this.panelId = panelId;
  this.panelTitle = panelTitle;
  this.getData();
}

/**
 * Ajax Call
 *
 * @return [void]
 */
LinksPanel.prototype.getData = function () {
  var _this = this;
  $.ajax({
    url: _this.url,
    type: 'GET',
    dataType: 'json',
    contentType: 'application/json',
    success: function(result){
      _this.display(result.data);
    },
    error: function(xhr,status,error){
      handleAjaxError (xhr, status, error);
    }
  });
}

/**
 * Display the result
 * @param result [String] The result obtained from Ajax call
 *
 * @return [void]
 */
LinksPanel.prototype.display = function (result) {
  var _this = this;
  var html = '';

  html += '<div class="col-md-6 card wide">' +
            '<h3 class="card-header">'+_this.panelTitle+'</h3>'+
            '<div class="card-content">';

  html += '<div class="list-wrap">';

  if(isResultEmpty(result))
    html += generateNoResultsMsg("No " + _this.panelTitle + ".");

  $.each(result, function(index, item) {

    item.references.sort( function (item1, item2){
      return new Date(item2.parent.date) - new Date(item1.parent.date)
    });

    if(item.references.length > 0) {
      html += '<div class="text-xnormal font-light ci-card-title">'+ item.description +'</div>';

      $.each(item.references, function(index, ref) {
        html += '<a href="' + ref.show_path + '">';
        html += ' <div class="list-card shadow-small">';
        html += '   <div class="card-badge bg-prim-bright"></div>';
        html += '   <div class="text">' + ref.parent.notation + ' (' + ref.parent.identifier + ') </div>';
        html += '   <div class="text sub-text">' + ref.child.notation + ' (' + ref.child.identifier + ') </div>';
        html += ' </div>';
        html += '</a>';
      });

    }
  });

  html +='</div></div></div>';

  $('#'+_this.panelId).html(html);
}

function isResultEmpty(result) {
  if ($.isEmptyObject(result))
    return true;

  var areAllEmpty = true;
  $.each(result, function(i, e) {
    if(e.references.length != 0)
      areAllEmpty = false;
  });

  return areAllEmpty;
}
