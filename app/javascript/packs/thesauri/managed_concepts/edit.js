import CLEditor from 'shared/custom/thesauri/managed_concepts/code_list_editor'
import TokenTimer from 'shared/custom/tokens/token_timer'
import PairHandler from 'shared/custom/thesauri/managed_concepts/pair_handler'
import PropertiesEditor from 'shared/custom/thesauri/managed_concepts/properties_editor'

$(document).ready( () => {

  // Init TokenTimer
  let tt = new TokenTimer({
    tokenId: timerTokenId,
    warningTime: timerWarning
  });

  // Init Code List Editor
  let ep = new CLEditor({
    id: codelistId,
    urls: codelistEditorUrls,
    extendTimer: () => tt.extend()
  });

  // Init Rank
  let rm = new RankModal(tt.extend.bind(tt));

  // Extension Properties Editor
  let pe = new PropertiesEditor({
    data: JSON.parse( editItemPropertiesData )
  });

  // Init Pairing handler
  let ps = new PairHandler({
    pairUrl: pairSelectPath,
    unpairUrl: unpairPath,
    isPaired: isItemPaired
  });

});
