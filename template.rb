# frozen_string_literal: true

require_relative 'libs/rails_template'

g = Libs::RailsTemplate.new
g.destination_root = Dir.pwd
g.options = options.merge(app_name: app_name, rails_generator: self)

after_bundle do
  g.create_initial_commit
  g.exclude_database_yml
  g.install_rspec
  g.install_capybara
  g.install_factory_bot
  g.install_shoulda_matchers
  g.install_rubocop
end
