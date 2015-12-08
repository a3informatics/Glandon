$(document).ready( function() {
	
	$('#main').DataTable({
        columnDefs: [ ]
    } );
				
	$('#cl').DataTable({
        columnDefs: [ ]
    } );

} );

$(function(){
    $('a.has-spinner, button.has-spinner').click(function() {
        $(this).toggleClass('active');
    });
});

