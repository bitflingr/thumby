SimpleNavigation::Configuration.run do |navigation|
  navigation.auto_highlight = true
  navigation.selected_class = 'active'
  navigation.items do |primary|
    primary.dom_class = 'nav'
    primary.item :root, 'Home', "/"
    primary.item :docs, 'Docs', "/docs/"
  end
end
