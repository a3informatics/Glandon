import SubsetEditor from 'shared/custom/thesauri/managed_concepts/subsets/editor'
import TokenTimer from 'shared/custom/tokens/token_timer'
import TabsLayout from 'shared/ui/tabs_layout'
import PropertiesEditor from 'shared/custom/thesauri/managed_concepts/properties_editor'

$(document).ready(() => {

  // Tabs layout inititalize (once)
  TabsLayout.initialize();

  // Edit Lock timer start
  let tt = new TokenTimer({
    tokenId: timerTokenId,
    warningTime: timerWarning
  });

  // Subset Editor init
  let se = new SubsetEditor({
    urls: subsetEditorUrls,
    onEdit: () => tt.extend()
  })

  // Rank Handler init TODO: Convert to module
  let rank = new RankModal( () => tt.extend() );

  // Subset Properties Editor
  let pe = new PropertiesEditor({
    data: JSON.parse( editItemPropertiesData )
  });

});
