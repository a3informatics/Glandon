import TableInitializer from 'shared/base/table_initializer'
import ConfirmableButtons from 'shared/ui/confirmable_buttons'

$(document).ready( () => {

  TableInitializer.initTable();

  ConfirmableButtons.init({
    outerSelector: '#main',
    buttonSelector: '.remove-ra',
    dangerous: true
  });

});
