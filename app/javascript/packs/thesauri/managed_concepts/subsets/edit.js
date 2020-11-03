import TokenTimer from 'shared/custom/tokens/token_timer'
import TabsLayout from 'shared/ui/tabs_layout'
import SubsetEditor from 'shared/custom/thesauri/managed_concepts/subsets/editor'

$(document).ready(() => {

  TabsLayout.initialize();

  let tt = new TokenTimer({
    tokenId: timerTokenId,
    warningTime: timerWarning
  });

  let set = new SubsetEditor({
    urls: subsetEditorUrls
  })

});
