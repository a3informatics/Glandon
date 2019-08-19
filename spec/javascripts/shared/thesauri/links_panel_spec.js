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
    data = {"data": {
              "Acylglycine":
                {
                  "description": "Acylglycine",
                   "references":
                      {
                        "parent":
                          {
                            "identifier": "C67154",
                            "notation": "notation parent"
                          }, 
                        "child":
                          {
                            "identifier": "C156534",
                            "notation": "notation child"
                          },
                        "id": "aHR0cDovL3d3dy5jZGlzYy5vcmcvQzY3MTU0L1Y1NyNDNjcxNTRfQzE1NjUzNA",
                        "show_path":"xxx"
                      }
                }
            }
          };
    server.respondWith("GET", "url", [200, {"Content-Type":"application/json"}, JSON.stringify(data)]);
    links_panel.getData();
    server.respond();
    expect(display_stub.calledTwice).to.be.true;
    display_stub.restore();
  });

    it("get data error", function() {
    display_stub = sinon.stub(LinksPanel.prototype , "display");
    var links_panel = new LinksPanel ("url", "panel-id");
    data = {"data": {
              "Acylglycine":
                {
                  "description": "Acylglycine",
                   "references":
                      {
                        "parent":
                          {
                            "identifier": "C67154",
                            "notation": "notation parent"
                          }, 
                        "child":
                          {
                            "identifier": "C156534",
                            "notation": "notation child"
                          },
                        "id": "aHR0cDovL3d3dy5jZGlzYy5vcmcvQzY3MTU0L1Y1NyNDNjcxNTRfQzE1NjUzNA",
                        "show_path":"xxx"
                      }
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
          {"data": 
              {
                "Acylglycine":
                  {
                    "description": "Acylglycine",
                    "id": "aHR0cDovL3d3dy5jZGlzYy5vcmcvQzY3MTU0L1Y1NyNDNjcxNTRfQzE1NjUzNA",
                    "show_path": "Agly",
                    "references":
                      {
                        "parent":
                          {
                            "identifier": "C67154",
                            "notation": "notation parent"
                          }, 
                        "child":
                          {
                            "identifier": "C156534",
                            "notation": "notation child"
                          },
                      }
                }
            }
        });

    expect(document.getElementById("linkspanel").innerHTML).to.equal(
        '<div class="welll">'+
          '<strong><p id="description">Acylglycine</p></strong>'+
          '<ul class="list-inline">'+
            '<li><strong>C67154</strong></li>'+
            '<li><strong>notation parent</strong></li>'+
            '<li><a href="Agly" class="btn btn-primary btn-xs" role="button"><i class="fa fa-arrow-circle-right fa-lg" aria-hidden="true"></i></a></li>'+
          '</ul>'+    
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
          {"data": 
              {
                "Acylglycine":
                  {
                    "description": "Acylglycine",
                    "id": "aHR0cDovL3d3dy5jZGlzYy5vcmcvQzY3MTU0L1Y1NyNDNjcxNTRfQzE1NjUzNA",
                    "show_path": "Agly",
                    "references":
                      {
                        "parent":
                          {
                            "identifier": "C67154",
                            "notation": "notation parent"
                          }, 
                        "child":
                          {
                            "identifier": "C156534",
                            "notation": "notation child"
                          },
                      }
                }
            }
        });
  });


});