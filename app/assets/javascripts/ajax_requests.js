/*
* Obtain a Thesaurus Concept
*
* @param node [Object] The source data node (the D3 node data)
* @param callback [Function] The callback function to be called on success
* @return [Null]
*/
function getThesaurusConcept(node, callback) {
  $.ajax({
    url: "/thesaurus_concepts/" + node.data.subject_ref.id,
    type: "GET",
    data: { "namespace": node.data.subject_ref.namespace },
    dataType: 'json',
    error: function (xhr, status, error) {
      var html = alertError("An error has occurred loading a Terminology reference.");
      displayAlerts(html);
    },
    success: function(result){
      callback(node, result);
    }
  });
}

/*
* Obtain a BC Property 
*
* @param node [Object] The source data node (the D3 node data)
* @param callback [Function] The callback function to be called on success
* @return [Null]
*/
function getBcProperty(node, callback) {
  $.ajax({
    url: "/biomedical_concepts/properties/" + node.data.property_ref.subject_ref.id,
    type: "GET",
    data: { "namespace": node.data.property_ref.subject_ref.namespace },
    dataType: 'json',
    error: function (xhr, status, error) {
      var html = alertError("An error has occurred loading a Biomedical Concept reference.");
      displayAlerts(html);
    },
    success: function(result){
      callback(node, result);
    }
  });
}

/*
* Get Markdown 
*
* @param object [UI Control] The object to be quoted in the callback
* @param text [String] The text to be converted
* @param callback [Function] The callback function to be called on success
* @return [Null]
*/
function getMarkdown(object, text, callback) {
  if (text !== "") {
    $.ajax({
      url: "/markdown_engines",
      type: "POST",
      data: { "markdown_engine": { "markdown": text }},
      dataType: 'json',
      error: function (xhr, status, error) {
        var html = alertError("An error has occurred loading the markdown.");
        displayAlerts(html);
      },
      success: function(result){
        var html_text = $.parseJSON(JSON.stringify(result));
        callback(object, html_text.result);
      }
    });
  } else {
    callback(object, text);
  }
}