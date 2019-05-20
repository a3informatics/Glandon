//= require shared/thesauri/search
//= require rspec_helper
//= require sinon
//= require application

var pageLength = 5;
var pageSettings = [[5,10,15,25,50,100,-1], ["5","10","15","25","50","100","All"]];

function keyUpReturn(element) {
    var e = $.Event('keyup');
    e.which = 13;
    e.keyCode = 13;
    $(element).trigger(e);
}

describe("Thesauri Search", function() {
  beforeEach(function() {
    html = 
    '  <table id="searchTable" class="table table-striped table-bordered table-condensed">' +
    '    <thead>' +
    '      <tr>' +
    '        <th>Code List</th>' +
    '        <th>Item</th>' +
    '        <th>Notation</th>' +
    '        <th>Preferred Term</th>' +
    '        <th>Synonym</th>' +
    '        <th>Definition</th>' +
    '      </tr>' +
    '      <tr>' +
    '        <th>Code List</th>' +
    '        <th>Item</th>' +
    '        <th>Notation</th>' +
    '        <th>Preferred Term</th>' +
    '        <th>Synonym</th>' +
    '        <th>Definition</th>' +
    '      </tr>' +
    '    </thead>' +
    '    <tbody>' +
    '    </tbody>' +
    '  </table>' +
    '  <div id="example-fixture-container"></div>' +
    '  <input type="hidden" id="thesaurus_current" value="<%= true %>">' +
    '  <input type="hidden" id="thesaurus_single" value="<%= false %>">' +
    '  <input type="hidden" id="thesaurus_id" value="aaa">' +
    '  <input type="hidden" id="thesaurus_namespace" value="bbb">' ;
    fixture.set(html);
    server = sinon.fakeServer.create();
  });

  afterEach(function() {
    server.restore();
  });

  it("Initialises the object", function() {
    var size = ["10", "10", "10", "10", "10", "20"]
    var pages = ["5","10","15","25","50","100"]
    var id = $('#thesaurus_id').val();
    var namespace = $('#thesaurus_namespace').val();
    var tsp = new ThesauriSearchPanel(id, namespace);
    expect($('#searchTable').DataTable().data().length == 0).to.eq(true); // Check we dont load anything
    $('#searchTable thead tr:eq(0) th').each( function (index) {
      var thead = $('#searchTable thead tr:eq(1) th:eq(' + index + ')');
      expect(thead[0].innerHTML).to.eq('<input id="searchTable_csearch_' + this.innerHTML.toLowerCase().replace(/ /g,"_") + '" type="text" class="form-control" size="' + size[index] + '" placeholder="Search ..." style="width: 100%;">');
    });
    $('#searchTable_length option').each( function (index) {
      expect(this.innerHTML).to.eq(pages[index]);
    });
  });

  it("Search from input header cell", function() {
    var id = $('#thesaurus_id').val();
    var namespace = $('#thesaurus_namespace').val();
    var tsp = new ThesauriSearchPanel(id, namespace);
    data = {"draw":"2","recordsTotal":"10","recordsFiltered":"1","data":[{"identifier":"C49484","notation":"NOT DONE","synonym":"","definition":"Indicates a task, process or examination that has either not been initiated or completed. (NCI)","preferredTerm":"Not Done","topLevel":false,"parentIdentifier":"C66789","children":[],"rdf_type":"http://www.assero.co.uk/ISO25964#ThesaurusConcept","id":"CLI-C66789_C49484","namespace":"http://www.assero.co.uk/MDRThesaurus/CDISC/V49","label":"","properties":[],"links":[],"extension_properties":[],"triples":{}}]}
    $('#searchTable thead tr:eq(1) th:eq(3) input').val("NOT DONE");
    keyUpReturn('#searchTable thead tr:eq(1) th:eq(3) input');
    server.respond([200, {"Content-Type":"application/json"}, JSON.stringify(data) ]);
    expect($("#searchTable tbody tr:nth-child(1) td:nth-child(1)").text()).to.eq("C66789");
  });

  it("Overall search", function(){
    var id = $('#thesaurus_id').val();
    var namespace = $('#thesaurus_namespace').val();
    var tsp = new ThesauriSearchPanel(id, namespace);
    data = {"draw":"2","recordsTotal":"10","recordsFiltered":"1","data":[{"identifier":"C66789","notation":"ND","synonym":"Not Done","definition":"Indicates a task, process or examination that has either not been initiated or completed. (NCI)","preferredTerm":"CDISC SDTM Not Done Terminology","topLevel":true,"parentIdentifier":"C66789","children":[],"rdf_type":"http://www.assero.co.uk/ISO25964#ThesaurusConcept","id":"CL-C66789","namespace":"http://www.assero.co.uk/MDRThesaurus/CDISC/V49","label":"","properties":[],"links":[],"extension_properties":[],"triples":{}}]}
    $('#searchTable_filter input').val("C66789");
    keyUpReturn('#searchTable_filter input');
    server.respond([200, {"Content-Type":"application/json"}, JSON.stringify(data) ]);
    expect($("#searchTable tbody tr:nth-child(1) td:nth-child(1)").text()).to.eq("C66789");
  });


  it("Click on table row", function(){
    var id = $('#thesaurus_id').val();
    var namespace = $('#thesaurus_namespace').val();
    var tsp = new ThesauriSearchPanel(id, namespace);
    data = {"draw":"2","recordsTotal":"10","recordsFiltered":"1","data":[{"identifier":"C49484","notation":"NOT DONE","synonym":"","definition":"Indicates a task, process or examination that has either not been initiated or completed. (NCI)","preferredTerm":"Not Done","topLevel":false,"parentIdentifier":"C66789","children":[],"rdf_type":"http://www.assero.co.uk/ISO25964#ThesaurusConcept","id":"CLI-C66789_C49484","namespace":"http://www.assero.co.uk/MDRThesaurus/CDISC/V49","label":"","properties":[],"links":[],"extension_properties":[],"triples":{}}]}
    $('#searchTable thead tr:eq(1) th:eq(3) input').val("NOT DONE");
    keyUpReturn('#searchTable thead tr:eq(1) th:eq(3) input');
    server.respond([200, {"Content-Type":"application/json"}, JSON.stringify(data) ]);
    expect($("#searchTable tbody tr:nth-child(1) td:nth-child(1)").text()).to.eq("C66789");
    $('#searchTable tbody tr').click();
    expect($('#searchTable tbody tr').hasClass('success')).to.eq(true);
  });


  it("Doubleclick on table row", function(){
    var id = $('#thesaurus_id').val();
    var namespace = $('#thesaurus_namespace').val();
    var tsp = new ThesauriSearchPanel(id, namespace);
    data = {"draw":"2","recordsTotal":"10","recordsFiltered":"1","data":[{"identifier":"C49484","notation":"NOT DONE","synonym":"","definition":"Indicates a task, process or examination that has either not been initiated or completed. (NCI)","preferredTerm":"Not Done","topLevel":false,"parentIdentifier":"C66789","children":[],"rdf_type":"http://www.assero.co.uk/ISO25964#ThesaurusConcept","id":"CLI-C66789_C49484","namespace":"http://www.assero.co.uk/MDRThesaurus/CDISC/V49","label":"","properties":[],"links":[],"extension_properties":[],"triples":{}}]}
    $('#searchTable thead tr:eq(1) th:eq(3) input').val("NOT DONE");
    keyUpReturn('#searchTable thead tr:eq(1) th:eq(3) input');
    server.respond([200, {"Content-Type":"application/json"}, JSON.stringify(data) ]);
    expect($("#searchTable tbody tr:nth-child(1) td:nth-child(1)").text()).to.eq("C66789");

    data = {"draw":"3","recordsTotal":"10","recordsFiltered":"2","data":[{"identifier":"C66789","notation":"ND","synonym":"Not Done","definition":"Indicates a task, process or examination that has either not been initiated or completed. (NCI)","preferredTerm":"CDISC SDTM Not Done Terminology","topLevel":true,"parentIdentifier":"C66789","children":[],"rdf_type":"http://www.assero.co.uk/ISO25964#ThesaurusConcept","id":"CL-C66789","namespace":"http://www.assero.co.uk/MDRThesaurus/CDISC/V49","label":"","properties":[],"links":[],"extension_properties":[],"triples":{}},{"identifier":"C49484","notation":"NOT DONE","synonym":"","definition":"Indicates a task, process or examination that has either not been initiated or completed. (NCI)","preferredTerm":"Not Done","topLevel":false,"parentIdentifier":"C66789","children":[],"rdf_type":"http://www.assero.co.uk/ISO25964#ThesaurusConcept","id":"CLI-C66789_C49484","namespace":"http://www.assero.co.uk/MDRThesaurus/CDISC/V49","label":"","properties":[],"links":[],"extension_properties":[],"triples":{}}]};
    $('#searchTable tbody tr:nth-child(1)').dblclick();
    $('#searchTable thead tr:eq(1) th:eq(3) input').val("");
    $('#searchTable thead tr:eq(1) th:eq(1) input').val("C66789");
    keyUpReturn('#searchTable thead tr:eq(1) th:eq(1) input');
    server.respond([200, {"Content-Type":"application/json"}, JSON.stringify(data) ]);
    expect($("#searchTable tbody tr:nth-child(1) td:nth-child(1)").text()).to.eq("C66789");
    expect($("#searchTable tbody tr:nth-child(1) td:nth-child(2)").text()).to.eq("C66789");
    expect($("#searchTable tbody tr:nth-child(2) td:nth-child(1)").text()).to.eq("C66789");
    expect($("#searchTable tbody tr:nth-child(2) td:nth-child(2)").text()).to.eq("C49484");
  });

  it("Clearing overall search input", function(){
    var id = $('#thesaurus_id').val();
    var namespace = $('#thesaurus_namespace').val();
    var tsp = new ThesauriSearchPanel(id, namespace);
    expect($("#searchTable_filter input").val()).to.eq("");
    $("#searchTable_filter input").val("bpi");
    expect($("#searchTable_filter input").val()).to.eq("bpi");
    $('#clearbutton').click();
    expect($("#searchTable_filter input").val()).to.eq("");
  });

  it("Clearing column search input", function(){
    var id = $('#thesaurus_id').val();
    var namespace = $('#thesaurus_namespace').val();
    var tsp = new ThesauriSearchPanel(id, namespace);
    expect($("#searchTable thead input").val()).to.eq("");
    $("#searchTable thead input").val("bpi");
    expect($("#searchTable thead input").val()).to.eq("bpi");
    $('#clearbutton').click();
    expect($("#searchTable thead input").val()).to.eq("");
  });

  it("Clearing both overall search input and column input", function(){
    var id = $('#thesaurus_id').val();
    var namespace = $('#thesaurus_namespace').val();
    var tsp = new ThesauriSearchPanel(id, namespace);
    expect($("#searchTable_filter input").val()).to.eq("");
    expect($("#searchTable thead input").val()).to.eq("");
    $("#searchTable_filter input").val("basic");
    $("#searchTable thead input").val("bpi");
    expect($("#searchTable_filter input").val()).to.eq("basic");
    expect($("#searchTable thead input").val()).to.eq("bpi");
    $('#clearbutton').click();
    expect($("#searchTable_filter input").val()).to.eq("");
    expect($("#searchTable thead input").val()).to.eq("");
  });

  it("single I, page length changed", function() {
    var id = $('#thesaurus_id').val();
    var namespace = $('#thesaurus_namespace').val();
    var tsp = new ThesauriSearchPanel(id, namespace);
  	pageSettings = [[5, 10, 15, 20, 50, 100, -1], ["5", "10", "15", "20", "50", "100", "All"]]
  	pageLength = -1;
  	tsp.filterOutAll();
  	var expected = [[5, 10, 15, 20, 50, 100], ["5", "10", "15", "20", "50", "100"]]
  	expect(pageSettings).to.eql(expected);
  	expect(pageLength).to.equal(100);
  });

  it("single II, page length not changed", function() {
    var id = $('#thesaurus_id').val();
    var namespace = $('#thesaurus_namespace').val();
    var tsp = new ThesauriSearchPanel(id, namespace);
  	pageSettings = [[5, 10, 15, 20, -1, 50, 100], ["5", "10", "15", "20", "All", "50", "100"]]
  	pageLength = 5;
  	tsp.filterOutAll();
  	var expected = [[5, 10, 15, 20, 50, 100], ["5", "10", "15", "20", "50", "100"]]
  	expect(pageSettings).to.eql(expected);
  	expect(pageLength).to.equal(5);
  });

  it("multiple I, page length changed", function() {
    var id = $('#thesaurus_id').val();
    var namespace = $('#thesaurus_namespace').val();
    var tsp = new ThesauriSearchPanel(id, namespace);
  	pageSettings = [[5, 10, 15, 20, -1, 50, 100, -1], ["5", "10", "15", "20", "All", "50", "100", "All"]]
  	pageLength = -1;
  	tsp.filterOutAll();
  	var expected = [[5, 10, 15, 20, 50, 100], ["5", "10", "15", "20", "50", "100"]]
  	expect(pageSettings).to.eql(expected);
  	expect(pageLength).to.equal(100);
  });

  it("multiple II, page length not changed", function() {
    var id = $('#thesaurus_id').val();
    var namespace = $('#thesaurus_namespace').val();
    var tsp = new ThesauriSearchPanel(id, namespace);
  	pageSettings = [[5, 10, 15, 20, -1, 50, 100, -1], ["5", "10", "15", "20", "All", "50", "100", "All"]]
  	pageLength = 10;
  	tsp.filterOutAll();
  	var expected = [[5, 10, 15, 20, 50, 100], ["5", "10", "15", "20", "50", "100"]]
  	expect(pageSettings).to.eql(expected);
  	expect(pageLength).to.equal(10);
  });

  it("none present", function() {
    var id = $('#thesaurus_id').val();
    var namespace = $('#thesaurus_namespace').val();
    var tsp = new ThesauriSearchPanel(id, namespace);
  	pageSettings = [[5, 10, 15, 20, 50, 100], ["5", "10", "15", "20", "50", "100"]]
  	pageLength = 100;
  	tsp.filterOutAll();
  	var expected = [[5, 10, 15, 20, 50, 100], ["5", "10", "15", "20", "50", "100"]]
  	expect(pageSettings).to.eql(expected);
  	expect(pageLength).to.equal(100);
  });

});