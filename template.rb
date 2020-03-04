# frozen_string_literal: true

require_relative 'libs/rails_template'

g = Libs::RailsTemplate.new
g.destination_root = Dir.pwd
g.options = options.merge(app_name: app_name, rails_generator: self)

after_bundle do
  g.create_initial_commit
  g.exclude_database_yml
  g.install_rspec 3.9
  g.install_capybara 3.31
  g.install_factory_bot 5.1
  g.install_shoulda_matchers 4.2
  g.install_rubocop
end
