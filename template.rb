require_relative 'libs/rails_template'

g = Libs::RailsTemplate.new
g.destination_root = Dir.pwd
g.options = options.merge(app_name: app_name, rails_generator: self)

g.create_initial_commit
g.install_rspec 3.9
g.add_test_gem_group
g.install_capybara
g.install_factory_bot 5.1
g.install_shoulda_matchers 4.2
g.install_rubocop
