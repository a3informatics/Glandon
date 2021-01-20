import ManagedCollectionPanel from 'shared/custom/iso_managed/managed_collection_panel'
import TokenTimer from 'shared/custom/tokens/token_timer'

$(document).ready( () => {

  let tt = new TokenTimer({
    tokenId: tokenTimerId,
    warningTime: tokenTimerWarning
  });

  let mcp = new ManagedCollectionPanel({
    urls: { data: 'aaa', add: 'bbb', remove: 'ccc', removeAll: 'ddd' },
    param: 'sdtm_sponsor_domain',
    allowedTypes: ['biomedical_concept_instance'],
    onEdited: () => tt.extend()
  })

});
