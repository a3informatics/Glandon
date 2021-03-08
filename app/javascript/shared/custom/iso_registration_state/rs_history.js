import { $put } from 'shared/helpers/ajax'

/**
 * Registration State functions in History Panel helpers
 */
 
 const registrationStateHelper = {

   /**
    * Renders item's Registration State column HTML
    * @param {Object} data Compatible item data format to be rendered in the DataTable
    * @returns {string} formatted RS HTML
    */
   renderRS(data) {
     if (_isRSEditable(data)) {
       let text = `${data.has_state.multiple_edit ? "Disable" : "Enable"} multiple edits`,
           icon = data.has_state.multiple_edit ? "icon-lock-open text-secondary-clr" : "icon-lock text-accent-2";

       return `<span class="clickable registration-state ttip">` +
                 `<span class="ttip-text ttip-left text-small shadow-small"> ${text} </span>` +
                 `<span class="${icon} text-small"></span> ` +
                  data.has_state.registration_status +
              `</span>`;
     }

     return data.has_state.registration_status;
   },

   /**
    * Updates RS multiple_edit on the server
    * @param {Object} data Row item data
    */
   updateRS(data) {
     const url = rsUpdateUrl.replace("rsId", data.id);

     $put({
       url: url,
       data: {
         iso_registration_state: {
           multiple_edit: !data.has_state.multiple_edit
         }
       },
       done: () => location.reload()
     });
   }
 }

 /**
  * Check if RS should be possible to edit
  * @param {Object} data Item data
  * @returns {boolean} true if RS editable
  */
 function _isRSEditable(data) {
   const state = data.has_state.registration_status.toLowerCase();

   return (
     (state === "not_set" ||
      state === "recorded" ||
      state === "qualified") &&
      !_.isEmpty(data.edit_path) )
 }

 export default registrationStateHelper
