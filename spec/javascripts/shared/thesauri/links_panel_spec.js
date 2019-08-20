//= require shared/thesauri/links_panel
//= require sinon
//= require rspec_helper
describe("Links Panel", function() {

  beforeEach(function() {
    server = sinon.fakeServer.create();
    clock = sinon.useFakeTimers();
  });

  afterEach(function() {
    clock.restore();
    server.restore(); 
  })

  it("initialises the panel", function() {
    url="url";
    panelId="panelId";
    get_data_stub = sinon.stub(LinksPanel.prototype , "getData");
    var links_panel = new LinksPanel(url, panelId);
    expect(links_panel.url).to.equal(url);            
    expect(links_panel.panelId).to.equal(panelId);
    expect(get_data_stub.calledOnce).to.be.true;
    get_data_stub.restore();        
  });


  it("get data", function() {
    display_stub = sinon.stub(LinksPanel.prototype , "display");
    var links_panel = new LinksPanel ("url", "panel-id");
    data = {"data":               {
                "umol/g":
                        {
                          "description": "umol/g",
                          "references": [
                                        {
                                          "parent": {
                                                    "identifier": "C71620",
                                                    "notation": "UNIT",
                                                    "date": "2019-06-28T00:00:00+00:00"
                                          },
                                          "child": {
                                                    "identifier": "C85752",
                                                    "notation": "nmol/g"
                                          },
                                          "id": "aHR0cDovL3d3dy5jZGlzYy5vcmcvQzcxNjIwL1Y0MyNDNzE2MjBfQzg1NzUy",
                                          "show_path": "/thesauri/unmanaged_concepts/aHR0cDovL3d3dy5jZGlzYy5vcmcvQzcxNjIwL1Y0MyNDNzE2MjBfQzg1NzUy?"
                          }
                          ]
                        }
            }
          };
    server.respondWith("GET", "url", [200, {"Content-Type":"application/json"}, JSON.stringify(data)]);
    links_panel.getData();
    server.respond();
    expect(display_stub.calledTwice).to.be.true;
    display_stub.restore();
  });


  it("display content", function() {
    html =
    '<div class="panel-body" id="linkspanel">'+  
    '</div>';
    fixture.set(html);
    var linkspanel = new LinksPanel ("url", "linkspanel");
    expect(document.getElementById("linkspanel").innerHTML).to.equal("");
    linkspanel.display(
              {
                "umol/g":
                        {
                          "description": "umol/g",
                          "references": [
                                        {
                                          "parent": {
                                                    "identifier": "C71620",
                                                    "notation": "UNIT",
                                                    "date": "2019-06-28T00:00:00+00:00"
                                          },
                                          "child": {
                                                    "identifier": "C85752",
                                                    "notation": "nmol/g"
                                          },
                                          "id": "aHR0cDovL3d3dy5jZGlzYy5vcmcvQzcxNjIwL1Y0MyNDNzE2MjBfQzg1NzUy",
                                          "show_path": "/thesauri/unmanaged_concepts/aHR0cDovL3d3dy5jZGlzYy5vcmcvQzcxNjIwL1Y0MyNDNzE2MjBfQzg1NzUy?"
                          }
                          ]
                        }
            }
    );

    expect(document.getElementById("linkspanel").innerHTML).to.equal(
        '<div class="panel panel-default">'+
    '<div class="panel-heading">'+
        '<h4 class="panel-title">umol/g</h4></div>'+
    '<div class="panel-body">'+
        '<div class="list-group">'+
            '<a href="/thesauri/unmanaged_concepts/aHR0cDovL3d3dy5jZGlzYy5vcmcvQzcxNjIwL1Y0MyNDNzE2MjBfQzg1NzUy?" class="list-group-item">'+
                '<p class="list-group-item-text"><small>2019-06-28 UNIT (C71620), nmol/g (C85752)</small></p>'+
            '</a>'+
        '</div>'+
    '</div>'+
'</div>');
  });


    it("display content empty", function() {
    html =
    '<div class="panel-body" id="linkspanel">'+ 
        
      '</div>';
    fixture.set(html);

    var linkspanel = new LinksPanel ("url", "linkspanel");
    expect(document.getElementById("linkspanel").innerHTML).to.equal("");
    linkspanel.display(
              {
                "umol/g":
                        {
                          "description": "umol/g",
                          "references": [
                                        {
                                          "parent": {
                                                    "identifier": "C71620",
                                                    "notation": "UNIT",
                                                    "date": "2019-06-28T00:00:00+00:00"
                                          },
                                          "child": {
                                                    "identifier": "C85752",
                                                    "notation": "nmol/g"
                                          },
                                          "id": "aHR0cDovL3d3dy5jZGlzYy5vcmcvQzcxNjIwL1Y0MyNDNzE2MjBfQzg1NzUy",
                                          "show_path": "/thesauri/unmanaged_concepts/aHR0cDovL3d3dy5jZGlzYy5vcmcvQzcxNjIwL1Y0MyNDNzE2MjBfQzg1NzUy?"
                          }
                          ]
                        }
            });
  });


});