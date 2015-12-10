// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or any plugin's vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require d3 
//= require jquery
//= require jquery_ujs
//= require bootstrap-sprockets
//= require dataTables/jquery.dataTables
//= require dataTables/bootstrap/3/jquery.dataTables.bootstrap
//= require morris.min
//= require raphael

/*
* General Alert handling functions
*/
function alertError(text) {
    html = '<div class="alert alert-danger alert-dismissible" role="alert">' + 
            '<button type="button" class="close" data-dismiss="alert"><span>&times;</span></button>' + 
            text + 
            '</div>'
    return html
}

function alertSuccess(text) {
    html = '<div class="alert alert-success alert-dismissible" role="alert">' + 
            '<button type="button" class="close" data-dismiss="alert"><span>&times;</span></button>' + 
            text + 
            '</div>'
    return html
}

function alertWarning(text) {
    html = '<div class="alert alert-warning alert-dismissible" role="alert">' + 
            '<button type="button" class="close" data-dismiss="alert"><span>&times;</span></button>' + 
            text + 
            '</div>'
    return html
}

function alertInfo(text) {
    html = '<div class="alert alert-info alert-dismissible" role="alert">' + 
            '<button type="button" class="close" data-dismiss="alert"><span>&times;</span></button>' + 
            text + 
            '</div>'
    return html
}

function displayAlerts(html) {
    var alertsId = document.getElementById("alerts")
  	alertsId.innerHTML = html;
    window.setTimeout(function() 
      {
        alertsId.innerHTML = "";
      }, 
      5000);
}