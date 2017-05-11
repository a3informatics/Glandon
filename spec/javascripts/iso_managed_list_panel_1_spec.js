//= require application
//= require colour
//= require d3_graph
//= require iso_managed_list_panel
//= require rspec_helper
//= require sinon

var pageLength = 5;
var pageSettings = [[5,10,15,25,50,100,-1], ["5","10","15","25","50","100","All"]];
var html;

describe("ISO Managed List Panel, AJAX", function() {
	
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
  	sinon.spy($, 'ajax');
	});

  afterEach(function() { 
    $.ajax.restore();
  })

  it("initialises the object", function() {
  	var panel = new IsoManagedListPanel();
  });

 	it("add entry", function() {
  	var panel = new IsoManagedListPanel();
  	panel.add("http://www.assero.co.uk/MDRThesaurus/CDISC/V42#TH-CDISC_CDISCTerminology", 1);
  	expect($.ajax.calledOnce).to.be.true; // AJAX call expected
  	expect($.ajax.getCall(0).args[0].url).to.equal("/iso_managed/TH-CDISC_CDISCTerminology");
    expect($.ajax.getCall(0).args[0].dataType).to.equal("json");
 	});

	it("add multiple entries", function() {
  	var panel = new IsoManagedListPanel();
  	panel.add("http://www.assero.co.uk/MDRThesaurus/CDISC/V40#TH-CDISC_CDISCTerminology", 1);
  	panel.add("http://www.assero.co.uk/MDRThesaurus/CDISC/V41#TH-CDISC_CDISCTerminology", 2);
  	panel.add("http://www.assero.co.uk/MDRThesaurus/CDISC/V42#TH-CDISC_CDISCTerminology", 3);
  	panel.add("http://www.assero.co.uk/MDRThesaurus/CDISC/V43#TH-CDISC_CDISCTerminology", 4);
  	panel.add("http://www.assero.co.uk/MDRThesaurus/CDISC/V44#TH-CDISC_CDISCTerminology", 5);
  	panel.add("http://www.assero.co.uk/MDRBCs/V1#BC-ACME_BC_C49677", 6);
 		expect($.ajax.callCount).to.equal(6); // AJAX call expected
  });

});