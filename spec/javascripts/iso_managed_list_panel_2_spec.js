//= require application
//= require colour
//= require d3_graph
//= require iso_managed_list_panel
//= require rspec_helper
//= require sinon

var pageLength = 5;
var pageSettings = [[5,10,15,25,50,100,-1], ["5","10","15","25","50","100","All"]];
var html;
var server

describe("ISO Managed List Panel, table", function() {
	
	beforeEach(function() {
  	html = 
  	'<div id="alerts"></div>' +
		'<div class="panel-body">' +
		'  <table id="managed_item_table" class="table table-striped table-bordered table-condensed">' +
		'    <thead>' +
		'      <tr>' +
		'    	   <th>Identifier</th>' +
	  '  		   <th>Label</th>' +
	  '  		   <th>Version</th>' +
	  '  		   <th>Version Label</th>' +
	  '  		   <th></th>' +
		'  	   </tr>' +
		'		 </thead>' +
		'		 <tbody>' +
		'	   </tbody>' +
		'  </table>' +
		'</div>';
  	fixture.set(html);
  	server = sinon.fakeServer.create();
    server.autoRespond = true;
    server.respondWith('GET', '/iso_managed/TH-CDISC_CDISCTerminology?namespace=http%3A%2F%2Fwww.assero.co.uk%2FMDRThesaurus%2FCDISC%2FV40', 
    	[ 200, 
    		{ 'Content-Type': 'application/json' },
        '{ "label": "Item 1",' +
        '  "scoped_identifier": ' +
        '  { ' +
        '	   "identifier": "Identifier 1", ' +
        '	   "semantic_version": "40.0.0", ' +
        '    "version": 40, ' +
        '    "version_label": "2015-01-01" ' +
        '  }' + 
        '}'  
    	]);
    server.respondWith('GET', '/iso_managed/TH-CDISC_CDISCTerminology?namespace=http%3A%2F%2Fwww.assero.co.uk%2FMDRThesaurus%2FCDISC%2FV41', 
    	[ 200, 
    		{ 'Content-Type': 'application/json' },
        '{ "label": "Item 2",' +
        '  "scoped_identifier": ' +
        '  { ' +
        '	   "identifier": "Identifier 1", ' +
        '	   "semantic_version": "41.0.0", ' +
        '    "version": 41, ' +
        '    "version_label": "2015-02-02" ' +
        '  }' + 
        '}'  
    	]);
    server.respondWith('GET', '/iso_managed/TH-CDISC_CDISCTerminology?namespace=http%3A%2F%2Fwww.assero.co.uk%2FMDRThesaurus%2FCDISC%2FV42', 
    	[ 200, 
    		{ 'Content-Type': 'application/json' },
        '{ "label": "Item 3",' +
        '  "scoped_identifier": ' +
        '  { ' +
        '	   "identifier": "Identifier 1", ' +
        '	   "semantic_version": "42.0.0", ' +
        '    "version": 42, ' +
        '    "version_label": "2015-03-03" ' +
        '  }' + 
        '}'  
    	]);
    server.respondWith('GET', '/iso_managed/TH-CDISC_CDISCTerminology?namespace=http%3A%2F%2Fwww.assero.co.uk%2FMDRThesaurus%2FCDISC%2FV43', 
    	[ 200, 
    		{ 'Content-Type': 'application/json' },
        '{ "label": "Item 4",' +
        '  "scoped_identifier": ' +
        '  { ' +
        '	   "identifier": "Identifier 1", ' +
        '	   "semantic_version": "43.0.0", ' +
        '    "version": 43, ' +
        '    "version_label": "2015-04-04" ' +
        '  }' + 
        '}'  
    	]);
    server.respondWith('GET', '/iso_managed/TH-CDISC_CDISCTerminology?namespace=http%3A%2F%2Fwww.assero.co.uk%2FMDRThesaurus%2FCDISC%2FV44', 
    	[ 200, 
    		{ 'Content-Type': 'application/json' },
        '{ "label": "Item 5",' +
        '  "scoped_identifier": ' +
        '  { ' +
        '	   "identifier": "Identifier 1", ' +
        '	   "semantic_version": "44.0.0", ' +
        '    "version": 44, ' +
        '    "version_label": "2015-05-05" ' +
        '  }' + 
        '}'  
    	]);
    server.respondWith('GET', '/iso_managed/TH-CDISC_CDISCTerminology?namespace=http%3A%2F%2Fwww.assero.co.uk%2FMDRThesaurus%2FCDISC%2FV45', 
    	[ 200, 
    		{ 'Content-Type': 'application/json' },
        '{ "label": "Item 6",' +
        '  "scoped_identifier": ' +
        '  { ' +
        '	   "identifier": "Identifier 1", ' +
        '	   "semantic_version": "45.0.0", ' +
        '    "version": 45, ' +
        '    "version_label": "2015-06-06" ' +
        '  }' + 
        '}'  
    	]);
  })
  
  afterEach(function() {
    server.restore();
  })

	it("highlight entry", function() {
  	var panel = new IsoManagedListPanel();
  	panel.add("http://www.assero.co.uk/MDRThesaurus/CDISC/V40#TH-CDISC_CDISCTerminology", 1);
  	panel.add("http://www.assero.co.uk/MDRThesaurus/CDISC/V41#TH-CDISC_CDISCTerminology", 2);
  	panel.add("http://www.assero.co.uk/MDRThesaurus/CDISC/V42#TH-CDISC_CDISCTerminology", 3);
  	panel.add("http://www.assero.co.uk/MDRThesaurus/CDISC/V43#TH-CDISC_CDISCTerminology", 4);
  	panel.add("http://www.assero.co.uk/MDRThesaurus/CDISC/V44#TH-CDISC_CDISCTerminology", 5);
  	panel.add("http://www.assero.co.uk/MDRThesaurus/CDISC/V45#TH-CDISC_CDISCTerminology", 6);
  	panel.highlight(1);
  	panel.highlight(2);
 	});

});