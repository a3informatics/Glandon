import EditMCPanel from 'shared/custom/managed_collections/edit_panel'
import TokenTimer from 'shared/custom/tokens/token_timer'
import { rdfTypesMap } from 'shared/helpers/rdf_types' 

$(document).ready( () => {

  let tt = new TokenTimer({
    tokenId: tokenTimerId,
    warningTime: tokenTimerWarning
  });

  let emcp = new EditMCPanel({
    urls: bcAssociationsUrls,
    param: 'sdtm_sponsor_domain',
    idsParam: 'bc_id_set',
    allowedTypes: [ rdfTypesMap.BC ],
    order: [[3, 'asc']],
    onEdited: () => tt.extend()
  })

});
