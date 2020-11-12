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
    panelTitle="panelTitle";
    get_data_stub = sinon.stub(LinksPanel.prototype , "getData");
    var links_panel = new LinksPanel(url, panelId, panelTitle);
    expect(links_panel.url).to.equal(url);            
    expect(links_panel.panelId).to.equal(panelId);
    expect(links_panel.panelTitle).to.equal(panelTitle);
    expect(get_data_stub.calledOnce).to.be.true;
    get_data_stub.restore();        
  });


  it("get data", function() {
    display_stub = sinon.stub(LinksPanel.prototype , "display");
    var links_panel = new LinksPanel ("url", "panel-id", "panelTitle");
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
    expect(display_stub.called).to.be.true;
    display_stub.restore();
  });


  it("display content", function() {
    html =
    '<div id="linkspanel">'+  
    '</div>';
    fixture.set(html);
    var linkspanel = new LinksPanel ("url", "linkspanel", "Shared Synonym");
    linkspanel.display(
{
  "Ehrlich Units": {
    "description": "Ehrlich Units",
    "references": [
      {
        "parent": {
          "identifier": "C71620",
          "notation": "UNIT",
          "date": "2012-08-03T00:00:00+00:00"
        },
        "child": {
          "identifier": "C96599",
          "notation": "EU"
        },
        "id": "aHR0cDovL3d3dy5jZGlzYy5vcmcvQzcxNjIwL1YyNiNDNzE2MjBfQzk2NTk5",
        "show_path": "/thesauri/unmanaged_concepts/aHR0cDovL3d3dy5jZGlzYy5vcmcvQzcxNjIwL1YyNiNDNzE2MjBfQzk2NTk5?"
      },
      {
        "parent": {
          "identifier": "C71620",
          "notation": "UNIT",
          "date": "2012-06-29T00:00:00+00:00"
        },
        "child": {
          "identifier": "C96599",
          "notation": "EU"
        },
        "id": "aHR0cDovL3d3dy5jZGlzYy5vcmcvQzcxNjIwL1YyNiNDNzE2MjBfQzk2NTk5",
        "show_path": "/thesauri/unmanaged_concepts/aHR0cDovL3d3dy5jZGlzYy5vcmcvQzcxNjIwL1YyNiNDNzE2MjBfQzk2NTk5?"
      },
      {
        "parent": {
          "identifier": "C71620",
          "notation": "UNIT",
          "date": "2012-03-23T00:00:00+00:00"
        },
        "child": {
          "identifier": "C96599",
          "notation": "EU"
        },
        "id": "aHR0cDovL3d3dy5jZGlzYy5vcmcvQzcxNjIwL1YyNiNDNzE2MjBfQzk2NTk5",
        "show_path": "/thesauri/unmanaged_concepts/aHR0cDovL3d3dy5jZGlzYy5vcmcvQzcxNjIwL1YyNiNDNzE2MjBfQzk2NTk5?"
      },
      {
        "parent": {
          "identifier": "C71620",
          "notation": "UNIT",
          "date": "2011-12-09T00:00:00+00:00"
        },
        "child": {
          "identifier": "C96599",
          "notation": "EU"
        },
        "id": "aHR0cDovL3d3dy5jZGlzYy5vcmcvQzcxNjIwL1YyNiNDNzE2MjBfQzk2NTk5",
        "show_path": "/thesauri/unmanaged_concepts/aHR0cDovL3d3dy5jZGlzYy5vcmcvQzcxNjIwL1YyNiNDNzE2MjBfQzk2NTk5?"
      },
      {
        "parent": {
          "identifier": "C71620",
          "notation": "UNIT",
          "date": "2011-07-22T00:00:00+00:00"
        },
        "child": {
          "identifier": "C96599",
          "notation": "EU"
        },
        "id": "aHR0cDovL3d3dy5jZGlzYy5vcmcvQzcxNjIwL1YyNiNDNzE2MjBfQzk2NTk5",
        "show_path": "/thesauri/unmanaged_concepts/aHR0cDovL3d3dy5jZGlzYy5vcmcvQzcxNjIwL1YyNiNDNzE2MjBfQzk2NTk5?"
      },
      {
        "parent": {
          "identifier": "C71620",
          "notation": "UNIT",
          "date": "2011-06-10T00:00:00+00:00"
        },
        "child": {
          "identifier": "C96599",
          "notation": "EU"
        },
        "id": "aHR0cDovL3d3dy5jZGlzYy5vcmcvQzcxNjIwL1YyNiNDNzE2MjBfQzk2NTk5",
        "show_path": "/thesauri/unmanaged_concepts/aHR0cDovL3d3dy5jZGlzYy5vcmcvQzcxNjIwL1YyNiNDNzE2MjBfQzk2NTk5?"
      }
    ]
  },
  "EU/dL": {
    "description": "EU/dL",
    "references": []
  }
}
    );

     expect(document.getElementById("linkspanel").innerHTML).to.equal(           
'<div class="card">'+
    '<h3 class="card-header">Shared Synonym: Ehrlich Units</h3>'+
    '<div class="list-group">'+
        '<a href="/thesauri/unmanaged_concepts/aHR0cDovL3d3dy5jZGlzYy5vcmcvQzcxNjIwL1YyNiNDNzE2MjBfQzk2NTk5?" class="list-group-item">'+
            '<p class="list-group-item-text"><small>UNIT (C71620), EU (C96599)</small></p>'+
        '</a>'+
        '<a href="/thesauri/unmanaged_concepts/aHR0cDovL3d3dy5jZGlzYy5vcmcvQzcxNjIwL1YyNiNDNzE2MjBfQzk2NTk5?" class="list-group-item">'+
            '<p class="list-group-item-text"><small>UNIT (C71620), EU (C96599)</small></p>'+
        '</a>'+
        '<a href="/thesauri/unmanaged_concepts/aHR0cDovL3d3dy5jZGlzYy5vcmcvQzcxNjIwL1YyNiNDNzE2MjBfQzk2NTk5?" class="list-group-item">'+
            '<p class="list-group-item-text"><small>UNIT (C71620), EU (C96599)</small></p>'+
        '</a>'+
        '<a href="/thesauri/unmanaged_concepts/aHR0cDovL3d3dy5jZGlzYy5vcmcvQzcxNjIwL1YyNiNDNzE2MjBfQzk2NTk5?" class="list-group-item">'+
            '<p class="list-group-item-text"><small>UNIT (C71620), EU (C96599)</small></p>'+
        '</a>'+
        '<a href="/thesauri/unmanaged_concepts/aHR0cDovL3d3dy5jZGlzYy5vcmcvQzcxNjIwL1YyNiNDNzE2MjBfQzk2NTk5?" class="list-group-item">'+
            '<p class="list-group-item-text"><small>UNIT (C71620), EU (C96599)</small></p>'+
        '</a>'+
        '<a href="/thesauri/unmanaged_concepts/aHR0cDovL3d3dy5jZGlzYy5vcmcvQzcxNjIwL1YyNiNDNzE2MjBfQzk2NTk5?" class="list-group-item">'+
            '<p class="list-group-item-text"><small>UNIT (C71620), EU (C96599)</small></p>'+
        '</a>'+
    '</div>'+
'</div>'+
'<div class="card">'+
    '<h3 class="card-header">Shared Synonym: EU/dL</h3>'+
    '<div class="list-group">'+
    '<span class="list-group-item"><p class="list-group-item-text">None</p></span>'+
    '</div>'+
'</div>'
    );
  });


    it("display content empty", function() {
    html =
    '<div id="linkspanel">'+ 
        
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