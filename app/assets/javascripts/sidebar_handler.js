var sidebar = "#sidebar",
  sidebarArrow = "#sidebar-arrow",
  sidebarVerArrow = "#sidebar-v-toggle",
  sidebarCollapseHorClass = "sidebar-collapsed",
  sidebarCollapseVerClass = "collapsed-vertical",
  arrowClass = "arrow-rotate";


function isSidebarHorizontal(){
  return $(document).width() > 767;
}

function isSidebarOpen(){
  if (isSidebarHorizontal() && $(sidebar).hasClass(sidebarCollapseHorClass))
    return false;
  else if(!isSidebarHorizontal() && $(sidebar).hasClass(sidebarCollapseVerClass))
    return false;
  else
    return true;
}

function openSidebar(){
  $(sidebar).removeClass((isSidebarHorizontal() ? sidebarCollapseHorClass : sidebarCollapseVerClass));
  getArrow().removeClass(arrowClass);
  handleContentWidth();
}

function closeSidebar(){
  $(sidebar).addClass((isSidebarHorizontal() ? sidebarCollapseHorClass : sidebarCollapseVerClass));
  getArrow().addClass(arrowClass);
  handleContentWidth();
}

function toggleSidebar(){
  if(isSidebarOpen())
    closeSidebar();
  else
    openSidebar();

  setTimeout(function(){$(window).trigger('resize');}, 500);
}

function getArrow(){
  if($(sidebarVerArrow).is(":visible"))
    return $(sidebarVerArrow);
  else
    return $(sidebarArrow);
}

/*
* Expands / collapses a menu category
*/
function sidebarCategoryHandler(item){
  if (!isSidebarOpen())
    openSidebar();

  $(item).find('.arrow').toggleClass('arrow-rotate');
  $(item).parent().toggleClass('collapsed');
}

function handleContentWidth(){
  if (!isSidebarHorizontal())
    return;
  // Animate main_area width
  $('#main_area').toggleClass('col-sm-10');
  $('#main_area').toggleClass('col-sm-11');
  $('#sidebar').toggleClass('col-sm-2');
  $('#sidebar').toggleClass('col-sm-1');

  $('#main_area').toggleClass('ma-sb-col');
  $('#main_area').toggleClass('ma-sb-exp');
}

function swapMenuTypes(item) {
  $(item).addClass("active");
  $(item).siblings().removeClass("active");
  switch ($(item).attr("id")) {
    case "button-mdr":
      $("#menu-type-mdr").show();
      $("#menu-type-swb").hide();
      break;
    case "button-swb":
      $("#menu-type-swb").show();
      $("#menu-type-mdr").hide();
      break;
  }
}
