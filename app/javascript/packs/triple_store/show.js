import TableInitializer from 'shared/base/table_initializer'

$(document).ready( () => {

  TableInitializer.initTable({
    tableOpts: {
      autoWidth: true,
      scrollX: true
    }
  });

});