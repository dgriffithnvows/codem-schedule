Given /^a preset named "([^"]*)" exists$/ do |name|
  Preset.create!(:name => name, :parameters => 'params')
end
