$(document).ready( function() {
	
		$('#cl').DataTable({
        columnDefs: [ ]
    } );
				
} );

$(function(){
    $('a.has-spinner, button.has-spinner').click(function() {
        $(this).toggleClass('active');
    });
});

