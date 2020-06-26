import { $get, $post } from 'shared/helpers/ajax'

/**
 * Token Timer
 * @description Countdown for Token (edit lock) and its extension.
 * @requires button Lock button in the item header [@id = 'timeout']
 * @author Samuel Banas <sab@s-cubed.dk>
 * @author Dave Iberson-Hurst <dih@s-cubed.dk>
 */
export default class TokenTimer {

  /**
   * Create a Token Timer instance
   * @param {Object} params Instance parameters
   * @param {string} params.tokenId ID of the Token (edit lock)
   * @param {int} params.warningTime User-defined time (in seconds) to be warned about the lock expiry
   * @param {string} params.parentId ID of the parent card in which the Lock button is present
   * @param {int} params.reqInterval Check Token status interval in ms [default = 10sec]
   */
  constructor({
    tokenId,
    warningTime,
    parentId = "#imh_header",
    reqInterval = 10000,
  }) {
    Object.assign(this, { tokenId, warningTime, parentId, reqInterval });

    this._initTokenTimer(this.reqInterval);
    this._setListeners();
  }

  /**
   * Send request to extend the Token Timer
   */
  extend() {
    if (this.isExpired)
      return;

    this._loading(true);

    $get({
      url: `/tokens/${this.tokenId}/extend_token`,
      error: () => displayError("An error has occurred extending the edit lock timeout."),
      done: (r) => this._initTokenTimer(this.reqInterval),
      always: () => this._loading(false)
    });
  }

  /**
   * Send request to release the Token, handle local updates
   */
  release() {
    this._loading(true);

    $post({
      url: `/tokens/${this.tokenId}/release`,
      done: (r) => {
        this.timeRemaining = 0;
        this.expire();
        this._render();
      },
      always: () => this._loading(false)
    });
  }

  /**
   * Expire the Token *locally*
   */
  expire() {
    this.state = this._states.expired;
    clearInterval(this.countdown);
    clearInterval(this.tokenTimer);
  }

  /**
   * Check whether the current state is expired
   * @return {boolean} Token expiry state
   */
  get isExpired() {
    return this.state === this._states.expired;
  }

  /** Private **/

  /**
   * Set event listeners, handlers
   */
  _setListeners() {
    // Release token on window unload
    window.onbeforeunload = () => this.release();
    // Extend Token with click
    $(`${this.parentId} #timeout`).on('click', () => this.extend());
  }

  /**
   * Initializes a new interval to update TokenTimer every second
   */
  _initCountdown() {
    if(this.countdown)
      clearInterval(this.countdown);

    // Clear time
    this._renderTime();

    this._onCountdown();
    this.countdown = setInterval( () => this._onCountdown(), 1000);
  }

  /**
   * Initializes a new interval to check Token Status periodically
   * @param {int} period check Token status request interval in seconds
   */
  _initTokenTimer(period) {
    if(this.tokenTimer)
      clearInterval(this.tokenTimer);

    this._checkToken();
    this.tokenTimer = setInterval( () => this._checkToken(), period);
  }

  /**
   * Updates timeRemaining, Token state and renders UI changes
   */
  _onCountdown() {
    this.timeRemaining = this.timeRemaining < 1 ? 0 : this.timeRemaining - 1;
    this._updateState();
    this._render();
  }

  /**
   * Updates instance's Token state based on the timeRemaining
   */
  _updateState() {
    if (this.timeRemaining < 1)
      this.expire();
    else if (this.timeRemaining > this.warningTime)
      this.state = this._states.normal;
    else if (this.timeRemaining > (this.warningTime / 2))
      this.state = this._states.warning;
    else
      this.state = this._states.danger
  }

  /**
   * Makes a request to the server to check the Token status, updates instance with server-data
   */
  _checkToken() {
    $get({
      url: `/tokens/${this.tokenId}/status`,
      error: () => displayError("An error has occurred obtaining the edit lock timeout information."),
      done: (r) => {
        // Align instance's timeRemaining with server's
        this.timeRemaining = r.remaining;

        if (r.running)
          this._initCountdown(r.remaining);
        else
          this._expire();
      }
    });
  }

  /**
   * Renders the timeString in the Timer HTML
   * @param {string} timeString Time to be displayed, optional, defaults to empty string
   */
  _renderTime(timeString = '') {
    $(`${this.parentId} #timeout`)
      .find(".ico-btn-sec-text")
      .html(timeString);
  }

  /**
   * Renders changes based on instance data
   */
  _render() {
    // Update parent element CSS class
    $(this.parentId)
      .removeClass(this._states.warning + " " + this._states.danger)
      .addClass(this.state);

    // Show the remaining time
    if (this.timeRemaining <= this.warningTime)
      this._renderTime(this._formattedTime);

    // Show expired UI
    if (this.isExpired)
      $(`${this.parentId} #timeout`).addClass(this.state);
  }

  /**
   * Converts timeRemaining in seconds into a MM:SS format
   * @return {string} seconds in MM:SS format
   */
  get _formattedTime() {
    let minutes = Math.floor(this.timeRemaining/60);
    let seconds = this.timeRemaining % 60;

    return `${pad(minutes, 2, '0')}:${pad(seconds, 2, '0')}`;
  }

  /**
   * Converts seconds into a MM:SS format
   * @param {int} seconds amount to be converted
   * @return {string} seconds in MM:SS format
   */
  _loading(enable) {
    $(`${this.parentId} #timeout`).toggleClass("processing", enable);
  }

  /**
   * Gets object representing all the states that the TokenTimer can be in
   * @return {object} all states with css class names as values
   */
  get _states() {
    return {
      normal: "",
      warning: "warning",
      danger: "danger",
      expired: "disabled"
    }
  }

}
