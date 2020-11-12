/*
* Change Instructions HTML Helper
* Contains reusable functions for building html parts of change instructions
*/

/**
* Change Instructions HTML Helper Constructor
*
* @return [void]
*/
function CIHtml() { }


/**
 * Generates HTML for a single Change Instruction (index)
 *
 * @param data [Object] Change Instruction data object
 * @param editable [Boolean] true if should render edit and remove buttons
 * @return [String] formatted HTML
 */
CIHtml.prototype.changeInstruction = function (data) {
  var cdiscOwned = data.owner.toLowerCase() == "cdisc";
  var html = "";

  html += "<div class='change-instruction shadow-small " + (cdiscOwned ? "cdisc" : "") + "' data-id='"+data.id+"'>";
  html +=   "<div class='ci-header'>";
  html +=     "<div class='icon-instruction text-link text-large'></div>";
  html +=  "<div class='actions'>"

  if (data.edit)
    html +=    "<a href='"+data.edit_path+"' class='icon-edit text-link'></a>" +
                "<a href='#' class='icon-trash text-accent-2'></a>";
  else if(cdiscOwned)
    html +=    "<i>Owned by CDISC</i>";

  html +=   "</div></div>";
  html +=   "<div class='ci-body'>";
  html +=     "<div>Reference: " +
                (data.reference == "" ? "Not set" : data.reference) + "</div>";
  html +=     "<hr>";
  html +=     "<div>Description: " + data.description + "</div>";
  html +=     this.linksList(data, {withHref: true, ttip: true, class: "highlightable"});
  html +=   "</div>";
  html += "</div>";
  return html;
}


/**
 * Generates HTML for a list of links for CI
 *
 * @param data [Object] Change Instruction data object
 * @param opts [Object] Options, must specify: withHref (bool), ttip (bool), class (string)
 * @return [String] formatted likns list HTML
 */
CIHtml.prototype.linksList = function (data, opts) {
  var html = "";

  html += "<div class='items-list scroll-styled'>"

  $.each(data.previous, function(idx, link) {
    html += this.listItem(link, "previous", opts);
  }.bind(this));

  $.each(data.current, function(idx, link) {
    html += this.listItem(link, "current", opts);
  }.bind(this));

  html += "</div>";

  return html;
}

/**
 * Builds HTML for a link item in the list
 *
 * @param link [Object] Single link's data
 * @param type [String] previous/current
 * @param opts [Object] Options, must specify: withHref (bool), ttip (bool), class (string)
 * @return [String] formatted HTML
 */
CIHtml.prototype.listItem = function(link, type, opts) {
  var itemId = link.child != null ? link.child.id : link.parent.id;
  var html = "<a href='" + (opts.withHref ? link.show_path : "#") + "' " +
                "class='bg-label " + opts.class + "' " +
                "data-id='" + itemId + "' data-type='" + type + "'>";
  html +=         typeToColorIcon(link.parent.rdf_type || link.child.rdf_type, {ttip: true});
  html +=         "<span>" + this.linkText(link) + "</span>";
  html +=         this.linkIcon(type, opts);
  html +=   "</a>";
  return html;
}

/**
 * Builds previous/current icon with tooltip for an item
 *
 * @param type [String] previous/current
 * @param opts [Object] Options, must specify: withHref (bool), ttip (bool), class (string)
 * @return [String] formatted HTML
 */
CIHtml.prototype.linkIcon = function(type, opts) {
  var html = "";
  if (opts.ttip) {
    html += "<span class='type-icon icon-" + (type == "previous" ? "old" : "new") + " text-normal ttip'>";
    html +=   "<span class='ttip-text left ttip-table shadow-small text-small'>" +
                (type == "previous" ? "Previous" : "Current") +
              "</span>";
    html += "</span>";
  }
  else {
    html += "<span class='type-icon icon-" + (type == "previous" ? "old" : "new") + " text-normal'>";
    html += "</span>";
  }

  return html;
}

/**
 * Builds HTML text for an item link
 *
 * @param link [Object] Single link's data
 * @return [String] formatted HTML
 */
CIHtml.prototype.linkText = function(link) {
  var text = "<span class='font-regular'>" + (link.parent.label || link.parent.notation) + "</span> ";
  text += "(" + link.parent.identifier + ") v" + link.parent.semantic_version;

  if (link.child != null) {
    text += "<br/>"
    text += "Child: <span class='font-regular'>" + (link.child.label || link.child.notation) + "</span> (" + link.child.identifier + ")";
  }

  return text;
}
