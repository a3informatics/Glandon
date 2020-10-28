import { renderSpinnerIn$, removeSpinnerFrom$ } from 'shared/ui/spinners'

/**
 * Tabs Layout
 * @description Allows swapping tabs in mulitple tab layouts
 * @requires .tabs-layout one or more HTML Tab Layouts containing respective .tab-options and .tab-wraps
 * @author Samuel Banas <sab@s-cubed.dk>
 */
export default class TabsLayout {

  /**
   * Initialize all Tab Layouts in DOM
   * @param {string} whichTab selector to specify the exact layout element to initialize, otherwise initializes all layouts in page
   * @static
   */
  static initialize(whichTab) {
    $(document).ready(() => {
      if (whichTab)
        TabsLayout._setTabListeners(whichTab)
      else
        TabsLayout._eachLayout( (tab) => TabsLayout._setTabListeners(tab) )
    });
  }

  /**
   * Toggle processing state and style on a specific tab
   * @param {string} tabLayout Selector of the tab layout to which the tab belongs, optional
   * @param {string} name Name of the target tab in the format 'tab-%name%'
   * @param {boolean} enable Value representing desired loading state enabled / disabled
   * @static
   */
  static tabLoading(tabLayout, name, enable) {
    let tab;

    if (tabLayout)
      tab = $(tabLayout).find(`.tab-wrap[data-tab='${name}']`);
    else
      tab = $(`.tab-wrap[data-tab='${name}']`);

    tab.toggleClass('processing', enable);

    if (enable)
      renderSpinnerIn$(tab, 'small');
    else
      removeSpinnerFrom$(tab);
  }

  /**
   * Set an event listener & handler on tab-option switch to a Tab Layout
   * @param {string} tabId Element Id of a Tab Layout to set the listener to
   * @param {function} action Function to be called, passes the tab-option id as the argument
   * @static
   */
  static onTabSwitch(tabId, action) {
    $(`${tabId}`).off('tab-switch').on('tab-switch', (e, optionId) => action(optionId) );
  }


  /** Private **/


  /**
   * Set click listeners to tab-options in a single Tab Layout
   * @param {JQuery Element} tab Reference to a single Tab Layout element
   * @static
   */
  static _setTabListeners(tab) {
    $(tab).find('.tab-option').off('click').on('click', function(e) {

      $(tab).find('.tab-option').removeClass('active').filter(this).addClass('active');
      $(tab).find('.tab-wrap').addClass('closed').filter(`.tab-wrap[data-tab='${this.id}']`).removeClass('closed');

      $(tab).trigger('tab-switch', [this.id]);

    });
  }

  /**
   * Execute a function for each Tab Layout in DOM
   * @param {function} action Function to be called, passes the Tab element as the argument
   * @static
   */
  static _eachLayout(action) {
    $('.tabs-layout').each( (i, tab) => action(tab) )
  }

}
