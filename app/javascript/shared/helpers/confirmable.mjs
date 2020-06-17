/**
 * Executes only with user's affirmation
 * @param {Object} params Confirmable parameters
 * @param {function} params.callback Function to be executed
 * @param {string} params.title Optional confirmation dialog title prompt
 * @param {string} params.subtitle Optional confirmation dialog title prompt
 * @param {boolean} params.dangerous Optional confirmation dialog title prompt
 */
function $confirm({ callback, title, subtitle, withLoading = false, dangerous = false, confirmed = false }) {
  if (!confirmed)
    new ConfirmationDialog(
      () => $confirm({ callback, confirmed: true }),
      { title, subtitle, dangerous })
      .show();
  else
    callback();
}

export { $confirm }
