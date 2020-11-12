function spRemoveSpinner(field_id) {
  $(field_id + " > span").removeClass('glyphicon-spin');
}

function spAddSpinner(field_id) {
  $(field_id + " > span").addClass('glyphicon-spin');
}