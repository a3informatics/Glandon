$(document).ready( function() {
  var columns = [
    {"data" : "identifier"},
    {"data" : "notation"},
    {"data" : "preferred_term"},
    {"data" : "synonym"},
    {"data" : "extensible", "render": function (data, type, row, meta) {
      return type === "display" ? "<span class='i-centered icon-extend"+(data ? " text-secondary-clr" : "-disabled text-accent-2")+"'></span>" : (data ? "is-extensible": "not-extensible");
    }},
    {"data" : "definition"},
    {"data" : "tags", "render": function (data, type, row, meta) { return colorCodeTagsBadge(data);}},
    { "data": "indicators", "width": "90px", "render" : function (data, type, row, meta) {
        data = filterIndicators(data, {withoutVersions: true});
        return type === "display" ? formatIndicators(data) : formatIndicatorsString(data);
    }}
  ];

  var mcp = new ManagedChildrenPanel(url_path, 1000, columns, "thesauri");
});
