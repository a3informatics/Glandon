module TokenHelpers

  def token_ui_check(user)
    cache_warning_time = user.read_setting 'edit_lock_warning'
    user.write_setting 'edit_lock_warning', 6
    Token.set_timeout 8

    yield # This block should navigate to the target edit page   

    sleep 2

    expect( find('#imh_header')[:class] ).to include 'warning'

    find( '#timeout' ).click
    wait_for_ajax 10

    expect( find('#imh_header')[:class] ).not_to include 'warning'

    sleep 4

    expect( find('#imh_header')[:class] ).to include 'danger'

    sleep 4

    expect( find('#timeout')[:class] ).to include 'disabled'
    expect( find('#imh_header')[:class] ).not_to include 'danger'

    Token.restore_timeout
    user.write_setting('edit_lock_warning', cache_warning_time)
  end

  def token_expired_check(go_to_edit, do_an_edit)
    Token.set_timeout 2

    go_to_edit.call
    sleep 2

    do_an_edit.call
    expect(page).to have_content 'The edit lock has timed out.'
    
    Token.restore_timeout
  end

  def token_clear_check
    Token.delete_all
    yield # This block should navigate to the target edit page   

    expect(Token.all.count).to eq 1
    click_on 'Return'
    wait_for_ajax 10
    expect(Token.all.count).to eq 0
  end

end
