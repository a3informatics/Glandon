import ChildrenPanel from 'shared/custom/iso_managed/children_panel'

$(document).ready( () => {

  let cp = new ChildrenPanel({
    url: childrenDataUrl,
    param: "managed_concept",
    count: 1000,
    cache: false
  });

  // // TODO: Needs redoing
  // if ( canEdit ) {
  //
  //   let extensionCreate = new ExtensionCreate( isExtended, isExtending ),
  //       thesauriSelect = new ThesauriSelect( tcId, extensionCreate.createExtensionCallback.bind(extensionCreate) ),
  //       subsetsIndex = new IndexSubsets( tcId );
  //
  //   let startExtend = () => {
  //
  //     thesauriSelect.setCallback( extensionCreate.createExtensionCallback.bind(extensionCreate) );
  //     thesauriSelect.resetUi();
  //     $("#th-select-modal").modal("show");
  //
  //   };
  //
  //   $("#extend").click( () => {
  //     if ( canExtendUnextensible && !canBeExtended )
  //         new ConfirmationDialog(function(){ startExtend() },{subtitle: "Are you sure you want to extend an Non-Extensible code list?", dangerous: true}).show();
  //     else
  //       startExtend();
  //   });
  //
  //   $("#new_subset").click( () => {
  //
  //     thesauriSelect.setCallback( subsetsIndex.createSubsetCallback.bind(subsetsIndex) );
  //     thesauriSelect.resetUi();
  //
  //   });
  //
  // }


});
