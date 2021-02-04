import EditMCPanel from 'shared/custom/managed_collections/edit_panel'
import TokenTimer from 'shared/custom/tokens/token_timer'

$(document).ready( () => {

  let tt = new TokenTimer({
    tokenId: tokenTimerId,
    warningTime: tokenTimerWarning
  });

  let emcp = new EditMCPanel({
    allowedTypes: [
      'managed_concept', 
      'biomedical_concept_instance',
      'form',
      'sdtm_sponsor_domain'
    ],
    order: [[3, 'asc']],
    onEdited: () => tt.extend()
  })

});
