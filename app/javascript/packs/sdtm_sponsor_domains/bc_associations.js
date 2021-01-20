import ManagedCollectionPanel from 'shared/custom/iso_managed/managed_collection_panel'
import TokenTimer from 'shared/custom/tokens/token_timer'

$(document).ready( () => {

  let tt = new TokenTimer({
    tokenId: tokenTimerId,
    warningTime: tokenTimerWarning
  });

  let mcp = new ManagedCollectionPanel({
    urls: bcAssociationsUrls,
    param: 'sdtm_sponsor_domain',
    idsParam: 'bc_id_set',
    allowedTypes: ['biomedical_concept_instance'],
    onEdited: () => tt.extend()
  })

});
