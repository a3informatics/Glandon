import EditMCPanel from 'shared/custom/managed_collections/edit_panel'
import TokenTimer from 'shared/custom/tokens/token_timer'

$(document).ready( () => {

  let tt = new TokenTimer({
    tokenId: tokenTimerId,
    warningTime: tokenTimerWarning
  });

  let emcp = new EditMCPanel({
    allowedTypes: ['biomedical_concept_instance'],
    order: [[3, 'asc']],
    onEdited: () => tt.extend()
  })

});
