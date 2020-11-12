import TagsManager from 'shared/custom/iso_concept_systems/tags_manager'

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
