// *** DEPRECATED ***
// A reusable html generator for context menus. Also defined in a partial: views/shared/context_menu/. If you change one, you have to change the other too !

// ID: String id for the menu itself
// items: an array of objects with data, containing the fields: link_path, disabled (string 'true' or 'false'), icon (string icon class), text
// Returns HTML code as a string.
function generateContextMenu(id, items, color, side){
  var html = '';
  side = side != null ? side : "";
  color = color != null ? color : "";
  html += '<span id="' + id + '" class="icon-context-menu text-normal" tabindex="1">';
  html +=   '<div class="context-menu ' + color + ' ' + side + ' shadow-small collapsed scroll-styled">';
  $.each(items, function(i, e){
    html += generateContextItem(e.link_path, e.disabled, e.icon, e.text, e.dt_toggle);
  });
  html +=   '</div>';
  html += '</span>';

  return html;
}

function generateContextItem(link_path, disabled, icon, text, dt_toggle, id){
  var item_html = '';
  id = (id != null ? "id='"+id+"'" : "");
  item_html += '<a href="' + link_path + '" '+id+' class="option ' + (disabled === 'true' ? 'disabled' : '')  + '" ' + (dt_toggle != null ? 'data-toggle="'+dt_toggle+'"' : '') + ' >';
  item_html +=  '<span class="' + icon + ' text-small"></span>';
  item_html +=  '<span class="text-small">' + text + '</span>';
  item_html += '</a>';

  return item_html;
}
