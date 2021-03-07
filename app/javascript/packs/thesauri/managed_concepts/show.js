import ChildrenPanel from 'shared/custom/iso_managed/children_panel'
import SubsetsManager from 'shared/custom/thesauri/managed_concepts/subsets/manager'

$(document).ready( () => {

  // Code List Children show panel
  let cp = new ChildrenPanel({
    url: childrenDataUrl,
    param: "managed_concept",
    count: 1000,
    cache: false,
    customPropsEnabled: true
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
      let ItemsPicker = await import('shared/ui/items_picker/v2/items_picker'),

          thPicker = new ItemsPicker.default({
            id: 'thesaurus',
            multiple: false,
            types: [ ItemsPicker.default.allTypes.TH ],
            description: `Select the Terminology in which the newly created item be should be included.
                          Click on 'Do not select' to skip selecting a Terminology.`
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
