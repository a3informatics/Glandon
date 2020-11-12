import TagsManager from 'shared/custom/iso_concept_systems/tags_manager'
import ConceptTagsEditor from 'shared/custom/iso_concept/concept_tags_editor'

$(document).ready( () => {

  // Tags Manager (tree) in View-only mode
  let tm = new TagsManager({
    editable: false,
    urls: {
      data: tagsDataUrl,
    }
  });

  // Concept Tags Editor
  let cte = new ConceptTagsEditor({
    urls: {
      data: conceptTagsUrl,
      add: conceptAddTagUrl,
      remove: conceptRemoveTagUrl
    },
    manager: tm
  })

});
