require_relative 'libs/rails_template'

g = Libs::RailsTemplate.new
g.destination_root = Dir.pwd

g.create_initial_commit
g.install_rspec
g.install_capybara
g.install_factory_bot
g.install_shoulda_matchers
g.install_rubocop

