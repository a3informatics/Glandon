import TableInitializer from 'shared/base/table_initializer'
import ConfirmableButtons from 'shared/ui/confirmable_buttons'

$(document).ready( () => {

  TableInitializer.initTable();

  ConfirmableButtons.init({
    outerSelector: '#user-roles',
    buttonSelector: '.update-role',
    subtitle: 'This will change the access rights of the user.'
  });

});