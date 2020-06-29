import { dtInlineEditColumn, dtIndicatorsColumn, dtTagsColumn } from 'shared/helpers/dt_columns'
import { editIconInline, removeIconInline } from 'shared/ui/buttons'

/**
 * Column definitions for a Code List Editor table
 * @return {Array} DataTables Code List Edit column definitions collection
 */
function dtCLEditColumns() {
  return [
    { data: "identifier" },
    dtInlineEditColumn("notation", "notation", "16%"),
    dtInlineEditColumn("preferred_term", "preferred_term", "18%"),
    dtInlineEditColumn("synonym", "synonym", "18%"),
    dtInlineEditColumn("definition", "definition", "40%"),
    dtTagsColumn("8%", 'editable edit-tags'),
    dtIndicatorsColumn(),
    {
      className: "fit",
      render: (data, type, r, m) => {
        // const editingDisabled = _.isEmpty(r.edit_path);
        // editIconInline({ disabled: editingDisabled })
        const actionIcons = removeIconInline({ ttip: true, ttipText: "Remove / unlink item" });

        return type === 'display' ? actionIcons : '';
      }
    }
  ];
};

export { dtCLEditColumns }
