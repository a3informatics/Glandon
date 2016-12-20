module WaitForAjaxHelper

  def wait_for_ajax
    page.document.should have_selector("body.ajax-completed")
  end

end