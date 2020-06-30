import CLEditor from "shared/thesauri/managed_concepts/code_list_editor"
import TokenTimer from "shared/tokens/token_timer"

$(document).ready( () => {

  // Init TokenTimer
  let tt = new TokenTimer({
    tokenId: timerTokenId,
    warningTime: timerWarning
  });

  // Init Code List Editor
  let ep = new CLEditor({
    id: codeListId,
    urls: {
      data: editorSrcDataUrl,
      update: editorUpdateDataUrl,
      newChild: editorNewChildUrl,
      addChildren: editorAddChildrenUrl
    },
    extendTimer: () => {tt.extend() }
  });

  // Init Rank
  let rm = new RankModal(tt.extend.bind(tt));
  
  // Init Edit Properties
  $("#edit-properties-button").on("click", () => {
    new EditProperties(epItemcodelist, "codelist", "ManagedConcept", null).show();
  });

});
