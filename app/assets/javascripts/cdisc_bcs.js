$(document).ready(function() {
  $('#bct_button').click(function() {
  	element = document.getElementById("bct_status");
  	value = element.value;
  	//alert("value=" + value);
  	parts = value.split("|");
      $.ajax({
        url: "bct_select",
        data: {
          id: parts[0],
          namespace: parts[1]
        },
        dataType: "json",
        success: function(data) { 
          //$('#d3').innerHTML(data);
          element = document.getElementById("d3");
          element.innerHTML = JSON.stringify(data)  + "<br/>";
          //element.innerHTML = data.name + data.properties;
          //alert("data=" + data.name);
          for (var prop in data.properties)
          {
            for (var key in prop) {
              element.innerHTML = element.innerHTML + "Key:" + key + ", Value:" + prop[key] + "<br/>";
            }
          }
        }
      });
  });
});