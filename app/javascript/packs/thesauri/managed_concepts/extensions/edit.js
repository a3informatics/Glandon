import TokenTimer from 'shared/custom/tokens/token_timer'
import PairHandler from 'shared/custom/thesauri/managed_concepts/pair_handler'
import ExtensionEditor from 'shared/custom/thesauri/managed_concepts/extensions/editor'
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

  // Edit Properties on click handler TODO: Convert to module
  $( '#edit-properties-button' ).on( 'click', () =>
    new EditProperties( epItemextension, 'extension', 'ManagedConcept', null).show()
  );

  // Init Pairing handler
  let ph = new PairHandler({
    pairUrl: pairSelectPath,
    unpairUrl: unpairPath,
    isPaired: isItemPaired
  });

});
