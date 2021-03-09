import ExtensionEditor from 'shared/custom/thesauri/managed_concepts/extensions/editor'

import TokenTimer from 'shared/custom/tokens/token_timer'

import PropertiesEditor from 'shared/custom/thesauri/managed_concepts/properties_editor'
import UpgradeHandler from 'shared/custom/thesauri/managed_concepts/upgrade/upgrade_handler'

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

  // Init Rank, TODO: Update to ES6
  let rankModal = new RankModal( () => tt.extend() );

  // Extension Properties Editor 
  let pe = new PropertiesEditor({
    data: JSON.parse( editItemPropertiesData )
  }); 

  // Upgrade button handler
  new UpgradeHandler();

  /**
   * Asynchronously load additional modules
   */
  ( async () => {

    // Import and init PairHandler
    let PairHandler = await import('shared/custom/thesauri/managed_concepts/pair_handler'),

        ph = new PairHandler.default({
          ...pairOptions
        })

  }) ();

});
