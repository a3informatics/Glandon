module D3TreeHelpers

  # Specific to Form Editor
  def icon_type_map
    {
      form: 59676,
      tuc_ref: 59736,
      bc: 59659,
      bc_property: 59659,
      normal_group: 59760,
      common_group: 59759,
      common_item: 59758,
      textlabel: 76,
      placeholder: 80,
      question: 81,
      mapping: 77
    }
  end

  def action_btn_map
    {
      edit: 'edit-node',
      add_child: 'add-child',
      move_up: 'move-up',
      move_down: 'move-down',
      common: 'common-node',
      restore: 'restore-node',
      remove: 'remove-node'
    }
  end

  def check_node_count(count, selector = 'g.node')
    expect( node_count(selector) ).to eq( count )
  end

  def node_count(selector = 'g.node')
    Capybara.ignore_hidden_elements = false
    count = page.all("#d3 #{selector} ").count
    Capybara.ignore_hidden_elements = true
    count
  end

  def find_node(text)
    page.all('g.node', text: text)[0]
  end

  def check_node(text, type = nil, selected = false)
    node = find_node(text)

    if selected
      expect(node[:class]).to include 'selected'
    else
      expect(node[:class]).not_to include 'selected'
    end

    return if type.nil?

    within(node) do
      icon = find('.icon').text.ord
      expect( icon ).to eq icon_type_map[type]
    end
  end

  def check_node_not_exists(text, selector = 'g.node')
    expect( page.all( "#d3 #{selector} ", text: text ).count ).to eq( 0 )
  end

  def check_actions(types)
    actions = find('#d3 .node-actions')

    types.each do |type|
        expect(actions).to have_selector( ".btn##{ action_btn_map[type] }", visible: true )
    end
  end

  def check_actions_not_present(types)
    actions = find('#d3 .node-actions')

    types.each do |type|
      expect(actions).to have_selector( ".btn##{ action_btn_map[type] }", visible: false )
    end
  end

  def click_action(action)
    find("#d3 .node-actions ##{ action_btn_map[action] }").click
  end

  def check_alert(text)
    expect( find('#graph-alerts') ).to have_content( text )
  end

end
