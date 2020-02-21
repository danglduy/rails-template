require_relative 'libs/rails_template'

rspec_version = 3.9

g = Libs::RailsTemplate.new
g.destination_root = Dir.pwd

g.create_initial_commit
g.install_rspec rspec_version
g.install_capybara
g.install_factory_bot
g.install_shoulda_matchers
g.install_rubocop

