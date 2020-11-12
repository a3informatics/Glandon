var panel;

$(document).ready(function() {
  
  panel = new IsoManagedSelect(addCallBack);
  panel.buttonEnable();

  validatorDefaults ();
  $('#main_form').validate({
    rules: 
    {  
    	"biomedical_concept[identifier]": {required: true, identifier: true },
      "biomedical_concept[label]": {required: true, label: true }
    },
    submitHandler: function(form) {
    	if ($("#biomedical_concept_uri").val() === "") {
    		displayError("A Biomedical Concept Template must be selected.");
    	} else {
	      return true;
    	}
    }
  });

});

function addCallBack(data) {
	$("#biomedical_concept_uri").val(toUri(data.namespace, data.id));
	$("#biomedical_concept_template").val(data.scoped_identifier.identifier + " (V" + data.scoped_identifier.semantic_version + ")");
}
