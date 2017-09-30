$(document).ready(function () {

  panel ("main1", "forms", "");
  panel ("main2", "thesauri", "");
  panel ("main3", "biomedical_concepts", "biomedical_concept");
  panel ("main4", "biomedical_concept_templates", "biomedical_concept_template");
  panel ("main5", "sdtm_user_domains", "");

  var x  = $("#barGraph").html();
  var barData = $.parseJSON(x);
  Morris.Bar({
    element: 'bar-example',
    data: barData,
    xkey: 'y',
    ykeys: ['a'],
    labels: ['Items']
  });

  function panel(control, url, safe_parameter) {
    $("#" + control).DataTable({
      "pagingType": "full",
      "ajax": {
        "url": url,
        "dataSrc": "data"  
      },
      "language": {
        "infoFiltered": "",
        "processing": "<img src='/assets/processing-9034d5d34015e4b05d2c1d1a8dc9f6ec9d59bd96d305eb9e24e24e65c591a645.gif'>"
      },
      "bProcessing": true,
      "pageLength": 5,
      "lengthMenu": [[5, 10, 25, 50], [5, 10, 25, 50]],
      "columns": [ 
        {"data" : "owner", "width" : "10%"},
        {"data" : "label", "width" : "70%"},
        {"data" : "identifier", "render": function(data,type,full,meta) { 
          var query_string = 'identifier='+ data +'&scope_id=' + full.owner_id;
          if(safe_parameter !== "") {
            query_string = safe_parameter + '[identifier]=' + data + '&' + safe_parameter + '[scope_id]=' + full.owner_id;
          }
          return '<a href="' + url + '/history?' + query_string  + '"><button type="button" class="btn btn-primary btn-xs">History</button></a>';
        }}
      ]
    });
  }
});
