import ExtensionEditor from 'shared/custom/thesauri/managed_concepts/extensions/editor'

import TokenTimer from 'shared/custom/tokens/token_timer'

import PairHandler from 'shared/custom/thesauri/managed_concepts/pair_handler'
import PropertiesEditor from 'shared/custom/thesauri/managed_concepts/properties_editor'
import UpgradeHandler from 'shared/custom/thesauri/managed_concepts/upgrade/upgrade_handler'
//TODO: Convert dependencies to ES6 modules

$(document).ready(() => {

  // Init TokenTimer
  let tt = new TokenTimer({
    tokenId: timerTokenId,
    warningTime: timerWarning
  });

  // Extension Editor
  let ee = new ExtensionEditor({
    id: extensionId,
    urls: extensionEditorUrls,
    onEdited: () => tt.extend()
  });

  // Init Rank
  let rankModal = new RankModal( () => tt.extend() );

  // Extension Properties Editor 
  let pe = new PropertiesEditor({
    data: JSON.parse( editItemPropertiesData )
  });

  // Init Pairing handler
  let ph = new PairHandler({
    pairUrl: pairSelectPath,
    unpairUrl: unpairPath,
    isPaired: isItemPaired
  });

  // Upgrade button handler
  new UpgradeHandler()

});
