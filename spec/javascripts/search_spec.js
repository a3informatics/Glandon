//= require thesauri/search
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
  })

  afterEach(function() {
    server.restore();
  })




  it("Initialises the object", function() {
    var id = $('#thesaurus_id').val();
    var namespace = $('#thesaurus_namespace').val();
    expect(id).to.eq("aaa");
    expect(namespace).to.eq("bbb");
    var tsp = new ThesauriSearchPanel(id, namespace);
  })

  it("Setup text input to each header cell", function(){
    var id = $('#thesaurus_id').val();
    var namespace = $('#thesaurus_namespace').val();
    expect(id).to.eq("aaa");
    expect(namespace).to.eq("bbb");
    var tsp = new ThesauriSearchPanel(id, namespace);
    if($('#searchTable thead tr:eq(1) th').text() == "Extensible") {
    } else if($('#searchTable thead tr:eq(1) th').text() == "Definition") {
      expect($('#searchTable thead tr:eq(1) th').html()).to.eq('<input id="searchTable_csearch_definition" type="text" class="form-control" size="20" placeholder="Search ...">');
    } else if($('#searchTable thead tr:eq(1) th').text() == "Code List") {
      expect($('#searchTable thead tr:eq(1) th').html()).to.eq('<input id="searchTable_csearch_cl" type="text" class="form-control" size="10" placeholder="Search ...">');
    }
  });

  it("Search from input header cell", function() {
    var id = $('#thesaurus_id').val();
    var namespace = $('#thesaurus_namespace').val();
    expect(id).to.eq("aaa");
    expect(namespace).to.eq("bbb");
    var tsp = new ThesauriSearchPanel(id, namespace);
    data = {"draw":"2","recordsTotal":"10","recordsFiltered":"1","data":[{"identifier":"C49484","notation":"NOT DONE","synonym":"","definition":"Indicates a task, process or examination that has either not been initiated or completed. (NCI)","preferredTerm":"Not Done","topLevel":false,"parentIdentifier":"C66789","children":[],"rdf_type":"http://www.assero.co.uk/ISO25964#ThesaurusConcept","id":"CLI-C66789_C49484","namespace":"http://www.assero.co.uk/MDRThesaurus/CDISC/V49","label":"","properties":[],"links":[],"extension_properties":[],"triples":{}}]}
    $('#searchTable thead tr:eq(1) th:eq(3) input').val("NOT DONE");
    keyUpReturn('#searchTable thead tr:eq(1) th:eq(3) input');
    // server.respondWith("GET", "/^\/thesauri\/search_results?draw.*$/", [200, {"Content-Type":"application/json"}, JSON.stringify(data) ]);
    server.respond([200, {"Content-Type":"application/json"}, JSON.stringify(data) ]);
    expect($("#searchTable tbody tr:nth-child(1) td:nth-child(1)").text()).to.eq("C66789");
  })

  it("Overall search", function(){
    var id = $('#thesaurus_id').val();
    var namespace = $('#thesaurus_namespace').val();
    expect(id).to.eq("aaa");
    expect(namespace).to.eq("bbb");
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
    expect(id).to.eq("aaa");
    expect(namespace).to.eq("bbb");
    var tsp = new ThesauriSearchPanel(id, namespace);
    data = {"draw":"2","recordsTotal":"10","recordsFiltered":"1","data":[{"identifier":"C49484","notation":"NOT DONE","synonym":"","definition":"Indicates a task, process or examination that has either not been initiated or completed. (NCI)","preferredTerm":"Not Done","topLevel":false,"parentIdentifier":"C66789","children":[],"rdf_type":"http://www.assero.co.uk/ISO25964#ThesaurusConcept","id":"CLI-C66789_C49484","namespace":"http://www.assero.co.uk/MDRThesaurus/CDISC/V49","label":"","properties":[],"links":[],"extension_properties":[],"triples":{}}]}
    $('#searchTable thead tr:eq(1) th:eq(3) input').val("NOT DONE");
    keyUpReturn('#searchTable thead tr:eq(1) th:eq(3) input');
    server.respond([200, {"Content-Type":"application/json"}, JSON.stringify(data) ]);
    expect($("#searchTable tbody tr:nth-child(1) td:nth-child(1)").text()).to.eq("C66789");
    $('#searchTable tbody tr').click();
    expect($('#searchTable tbody tr').hasClass('success')).to.eq(true);
  })


  it("Doubleclick on table row", function(){
    var id = $('#thesaurus_id').val();
    var namespace = $('#thesaurus_namespace').val();
    expect(id).to.eq("aaa");
    expect(namespace).to.eq("bbb");
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
  })

  it("Empty table on load using deferLoading", function(){
    var id = $('#thesaurus_id').val();
    var namespace = $('#thesaurus_namespace').val();
    expect(id).to.eq("aaa");
    expect(namespace).to.eq("bbb");
    var tsp = new ThesauriSearchPanel(id, namespace);
    expect($('#searchTable').DataTable().data().length == 0).to.eq(true);
  })


  it("single I, page length changed", function() {
    var id = $('#thesaurus_id').val();
    var namespace = $('#thesaurus_namespace').val();
    expect(id).to.eq("aaa");
    expect(namespace).to.eq("bbb");
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
    expect(id).to.eq("aaa");
    expect(namespace).to.eq("bbb");
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
    expect(id).to.eq("aaa");
    expect(namespace).to.eq("bbb");
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
    expect(id).to.eq("aaa");
    expect(namespace).to.eq("bbb");
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
    expect(id).to.eq("aaa");
    expect(namespace).to.eq("bbb");
    var tsp = new ThesauriSearchPanel(id, namespace);
  	pageSettings = [[5, 10, 15, 20, 50, 100], ["5", "10", "15", "20", "50", "100"]]
  	pageLength = 100;
  	tsp.filterOutAll();
  	var expected = [[5, 10, 15, 20, 50, 100], ["5", "10", "15", "20", "50", "100"]]
  	expect(pageSettings).to.eql(expected);
  	expect(pageLength).to.equal(100);
  });

});