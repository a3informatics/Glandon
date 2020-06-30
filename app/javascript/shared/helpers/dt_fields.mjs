/**
 * Editable Field definitions for a Code List Editor table
 * @return {Array} DataTables Code List Edit column definitions collection
 */
function dtCLEditFields() {
  return [
    { name: "notation", type: "textarea" },
    { name: "preferred_term", type: "textarea" },
    { name: "synonym", type: "textarea" },
    { name: "definition", type: "textarea" }
  ];
};

export { dtCLEditFields }
