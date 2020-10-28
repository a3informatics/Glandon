import TableInitializer from 'shared/base/table_initializer'
import ConfirmableButtons from 'shared/ui/confirmable_buttons'

$(document).ready( () => {

  TableInitializer.initTable();

  ConfirmableButtons.init({
    outerSelector: 'body',
    buttonSelector: '.remove-job',
    dangerous: true
  });

  // Refresh page periodically
  setTimeout( () => location.reload(), 10000 );

});
