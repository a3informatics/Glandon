/**
 * Events Handler
 * @description Module for binding and dispatching custom events on a given element in the DOM   
 * @author Samuel Banas <sab@s-cubed.dk>
 */
export default class EventHandler {

  /**
   * Create a new EventHandler instance  
   * @param {string} selectort Element selector to which all events will be bound  
   */
  constructor({ 
    selector, 
    namespace = 'eventHandler' 
  }) {

    Object.assign( this, { 
      selector, namespace
    })

  }

  /**
   * Dispatch a custom event on instance's selector 
   * @param {string} name Name of the custom event 
   * @param {any} args Any args to pass into the handler 
   * @return {EventHandler} this instance (for chaining)
   */
  dispatch(name, ...args) {

    $( this.selector ).trigger( 
      this._eventName( name ), 
      args 
    )

    return this

  }

  /**
   * Add a custom event listener on instance's selector 
   * @param {string} name Name of the custom event
   * @param {function} handler Event handler function
   * @return {EventHandler} this instance (for chaining)
   */
  on(name, handler = () => {}) {

    $( this.selector ).on( 
      this._eventName( name ), 
      (e, ...args) => handler( ...args ) 
    )

    return this 

  }

  /**
   * Remove all listeners for a custom event on instance's selector 
   * @param {string} name Name of the custom event
   * @return {EventHandler} this instance (for chaining)
   */
  off(name) {

    $( this.selector ).off( this._eventName( name ) )
    return this 

  }

  /**
   * Remove all handlers from element attached by this EventHandler instance 
   */
  unbindAll() {
    $( this.selector ).unbind( this._eventName('') )
  }


  /*** Private ***/


  /**
   * Concat event name with this EventHandler's instance namespace
   * @param {string} eventName Name of the event without namespace
   * @return {string} Name of the event with namespace attached
   */
  _eventName(eventName) {
    return `${ eventName }.${ this.namespace }`
  }

}