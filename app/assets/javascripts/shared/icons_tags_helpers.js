/**
 ****** Tags ******
**/

// Returns a HEX color based on CDISC tag name, or a default color for any other name
function getColorByTag(tagName) {
  var tagsColorsMap =
    {"SDTM" : "#f29c8c",
    "QS" : "#e4aca1", "QS-FT" : "#e4aca1", "COA" : "#e4aca1", "QRS" : "#e4aca1",
    "CDASH" : "#eec293",
    "ADaM" : "#b6d58f",
    "Protocol" : "#93c9b5",
    "SEND": "#a9aee0",
    "CDISC": "#9dc0cf",
    "default": "#6d91a1"}

  if (tagName in tagsColorsMap)
    return tagsColorsMap[tagName];
  else return tagsColorsMap["default"];
}

// Will colorize outline of all tags with TagClass in a given parent id
function colorCodeTagsOutline(parent, tagClass) {
  $.each($(parent).find(tagClass), function(i, e){
    var color = (getColorByTag($(e).context.localName == "input" ? $(e).val() : $(e).text()));

    $(e).css("background", "transparent");
    $(e).css("box-shadow", "inset 0 0 0 2px "+color);
  });
}

// Takes in a string of tags divided by ';' and returns
// the tags HTML formatted with small color-coded badges for each tag
function colorCodeTagsBadge(tags) {
  tags = tags.split('; ');
  var html = (tags.length > 0 && tags[0].length > 0) ? "" : "None";

  $.each(tags, function (i, e) {
    if (e.length == 0) return;
    var color = getColorByTag(e);
    html += "<span class='min-badge-item'>" +
              "<span class='circular-badge tiny' style='background: "+color+";'></span>" +
                e +
            "</span>"
  });

  return html;
}

// Generic css setter, used in tags pages
function colorCodeElement(selector, css, value) {
  $(selector).css(css, value);
}

/**
 ****** Indicators ******
**/

// Map of indicator icons and descriptions
function indicatorMap(indicator) {
  var indMap =
    {
      "current": {icon: "icon-current", ttip: "Current version"},
      "extended": {icon: "icon-extend", ttip: "Item is extended"},
      "extends": {icon: "icon-extension", ttip: "Item is an extension"},
      "version_count": {icon: "icon-multi", ttip: "Item has %n% versions"},
      "subset": {icon: "icon-subset", ttip: "Item is a subset"},
      "subsetted": {icon: "icon-subsetted", ttip: "Item is subsetted"},
      "annotations": {icon: "icon-note-filled", ttip: "Item has %n% Change Note(s) and %i% Change Instruction(s)"}
    }

  return indMap[indicator];
}

// Takes in indicator JSON data and returns encoded HTML indicators icons with tooltips
// (skips ones set to 0 or false)
function formatIndicators(indicators) {
  var html = "";

  $.each(indicators, function(iName, iValue) {
    var iIcon = indicatorMap(iName).icon,
        iText = null;

    switch (iName) {
      case "version_count":
        iText = iValue > 1 ? indicatorMap(iName).ttip.replace("%n%", iValue) : null
        break;
      case "annotations":
        if (iValue.change_notes > 0 || iValue.change_instructions > 0)
          iText = indicatorMap(iName).ttip.replace("%n%", iValue.change_notes)
                                          .replace("%i%", iValue.change_instructions)
        break;
      default:
        iText = iValue ? indicatorMap(iName).ttip : null;
        break;
    }

    html += _.isNull(iText) ? "" : indicatorHTML(iIcon, iText)
  });

  return html;
}

// Single indicator HTML
function indicatorHTML(icon, ttipText) {
  return "<span class='"+ icon +" indicator ttip'>" +
            "<span class='ttip-text ttip-table left shadow-small'>" +
              ttipText +
            "</span>" +
          "</span>";
}

// Takens in indicator JSON data and returns a formatted indicator string
// (used for datatable searching)
function formatIndicatorsString(indicators){
  var output = "";

  $.each(indicators, function(iName, iValue){
    switch (iName) {
      case "version_count":
        output += iValue + " versions ";
        break;
      case "annotations":
        output += iValue.change_instructions > 0 ? iValue.change_instructions + " change instructions " : "";
        output += iValue.change_notes > 0 ? iValue.change_notes + " change notes " : "";
        break;
      default:
        output += iValue ? indicatorMap(iName).ttip + " " : "";
        break;
    }
  });

  return output;
}

/**
 ****** Icons and Colors ******
**/

function typeIconMap(type) {
  var icoMap = {};
  icoMap[C_TH_NEW] = 'icon-terminology';
  icoMap[C_TH_CL] = 'icon-codelist';
  icoMap[C_TH_SUBSET] = 'icon-subset';
  icoMap[C_TH_EXT] = 'icon-extension';
  icoMap[C_TH_CLI] = 'icon-codelist-item';

  return icoMap[type];
}

function typeIconCharMap(type) {
  var icoMap = {};
  icoMap[C_TH_NEW] = '\ue909';
  icoMap[C_TH_CL] = '\ue952';
  icoMap[C_TH_SUBSET] = '\ue941';
  icoMap[C_TH_EXT] = '\ue945';

  return icoMap[type];
}

function typeToBgColor(type, params) {
  if(params != null && params.owner != null && params.owner.toLowerCase() == "cdisc")
    return '#f5d684';

  var clrMap = {}
  clrMap[C_TH_NEW] = '#6d91a1';
  clrMap[C_TH_CL] = '#9dc0cf';
  clrMap[C_TH_SUBSET] = '#9dc0cf';
  clrMap[C_TH_EXT] = '#9dc0cf';
  clrMap[C_TH_CLI] = '#9dc0cf';

  return clrMap[type];
}

function typeToColorIcon(type, params) {
  var size = params.size == null ? "text-xnormal" : params.size;
  var ttip = params.ttip == null ? false : params.ttip;

  if(ttip)
    return '<span class="'+typeIconMap(type)+' '+ size + ' ttip" style="color: '+ typeToBgColor(type, params) +';">' +
              '<span class="ttip-text ttip-table shadow-small text-medium text-small">' + typeToString[type] + '</span>' +
           '</span>';

  return '<span class="'+typeIconMap(type)+' '+ size + '" style="color: '+ typeToBgColor(type, params) +';"></span>';
}

function typeToColorIconBadge(type, params) {
  var size = params.size == null ? "small" : params.size;
  var ttip = params.ttip == null ? false : params.ttip;

  if(ttip)
    return '<span class="circular-badge '+ size +' text-white ttip" style="background: '+ typeToBgColor(type, params) +';">' +
              '<span class="'+typeIconMap(type)+' text-xnormal"></span>' +
              '<span class="ttip-text shadow-small text-medium text-small">' + typeToString[type] + '</span>' +
           '</span>';

  return '<span class="circular-badge '+ size +' text-white" style="background: '+ typeToBgColor(type, params) +';">' +
            '<span class="'+typeIconMap(type)+' text-xnormal"></span>' +
         '</span>';
}

// Generate true/false icon
function trueFalseIcon(value, centered) {
  var icoClass = centered == true ? "i-centered" : "";

  return value ?
      "<span class='icon-ok text-secondary-clr "+ icoClass +"'></span>" :
      "<span class='icon-times text-accent-2 "+ icoClass +"'></span>";
}
