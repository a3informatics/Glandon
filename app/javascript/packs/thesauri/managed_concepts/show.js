import ChildrenPanel from 'shared/custom/iso_managed/children_panel'
import SubsetsManager from 'shared/custom/thesauri/managed_concepts/subsets/manager'

$(document).ready( () => {

  let customPropsEnabled = typeof customPropsOpts !== 'undefined';

  // Code List Children show panel
  let cp = new ChildrenPanel({
    url: childrenDataUrl,
    param: "managed_concept",
    count: 1000,
    cache: false,
    customPropsEnabled
  });

  // Subsets Index and Create manager
  let sm = new SubsetsManager({
    conceptId,
    userEditPolicy
  });

  /**
   * Asynchronously load additional required for Edit actions
   */
  if ( userEditPolicy )
    ( async () => {

      // Import and init ItemsPicker for Thesaurus selection (create Subset, Extension actions)
      let ItemsPicker = await import('shared/ui/items_picker/items_picker'),

          thPicker = new ItemsPicker.default({
            id: 'thesaurus',
            multiple: false,
            types: [ 'thesauri' ]
          });

      // Import and init ExtensionManager
      let ExtensionManager = await import('shared/custom/thesauri/managed_concepts/extensions/manager'),

          em = new ExtensionManager.default({
            conceptId,
            userEditPolicy,
            options: JSON.parse( extendOpts ),
          });

      // Set ItemsPicker reference to Subset & Extension Managers
      sm.thPicker = thPicker;
      em.thPicker = thPicker;

  }) ();

});
