import TokenTimer from 'shared/tokens/token_timer'
import PairHandler from 'shared/thesauri/managed_concepts/pair_handler'
//TODO: Convert dependencies to ES6 modules

$(document).ready(() => {

  // Init TokenTimer
  let tt = new TokenTimer({
    tokenId: timerTokenId,
    warningTime: timerWarning
  });

  // Extension Editor
  const editUrls = {
    loadUrl: showDataUrl,
    updateUrl: extensionUrl,
    newChildUrl: newChildUrl,
    newSynChildUrl: newChildFromSynUrl,
    destroyChildUrl: destroyChildUrl
  };

  let eep = new EditExtensionPanel(editUrls, extensionId, 1000, () => tt.extend() );

  // Search and select
  let sm = new TermSearchModal(eep.addToExtension.bind(eep), searchUrl);
  let mis = new ManagedItemsSelect( (v) => setTimeout(sm.initAndShow.bind(sm, v), 600) );

  // Init Rank
  let rankModal = new RankModal( () => tt.extend() );

  // Edit Extension Properties
  $("#edit-properties-button").on("click", () => {
    new EditProperties(epItemextension, "extension", "ManagedConcept", null).show();
  });

  // Init Pairing handler
  let ps = new PairHandler({
    pairUrl: pairSelectPath,
    unpairUrl: unpairPath,
    isPaired: isItemPaired
  });

});
