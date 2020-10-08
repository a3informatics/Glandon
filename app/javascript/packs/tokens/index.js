import TableInitializer from 'shared/base/table_initializer'
import ConfirmableButtons from 'shared/ui/confirmable_buttons'

$(document).ready( () => {

  TableInitializer.initTable();

  ConfirmableButtons.init({
    outerSelector: '#main',
    buttonSelector: '.release-lock',
    subtitle: 'Releasing the lock will prevent the user editing the item from making any further changes to it.',
    dangerous: true
  });
  
});
