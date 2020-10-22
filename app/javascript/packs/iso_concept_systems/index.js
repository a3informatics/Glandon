import TagsManager from 'shared/iso_concept_systems/tags_manager'

$(document).ready( () => {

  let tm = new TagsManager({
    editable: true,
    urls: {
      data: tagsDataUrl,
      update: tagUpdateUrl,
      create: tagCreateUrl
    }
  });

});
