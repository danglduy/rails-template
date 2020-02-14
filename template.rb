require 'pathname'

class ::RailsTemplate < Thor::Group
  include Thor::Actions
  include Rails::Generators::Actions

  RSPEC_VER = 3.9
  SHOULDA_VER = 4.2
  CAPYBARA_VER = 3.31
  FACTORY_BOT_VER = 5.1

  attr_accessor :options

  def self.source_root
    File.join(__dir__, 'templates')
  end

  def init
    run 'bundle install'
    run 'bundle binstubs bundler'
    git_add_commit 'Init'
  end

  def install_rspec
    insert_into_file 'Gemfile', "  gem 'rspec-rails', '~> #{RSPEC_VER}'\n", after: "group :development, :test do\n"
    run 'bundle install'
    run 'rails generate rspec:install'
    git_add_commit 'Add rspec'
  end

  def create_gem_group_test
    # remove existing group test created by rails
    gsub_file('Gemfile', /^(group :test)[\s\S]*?[\n\r]end\n/, '')
    insert_into_file 'Gemfile', before: "group :development, :test do\n" do
      <<~RUBY
        group :test do
        end
      RUBY
    end
  end

  def install_shoulda_matchers
    insert_into_file 'Gemfile', "  gem 'shoulda-matchers', '~> #{SHOULDA_VER}'\n", after: "group :test do\n"
    run 'bundle install'
    copy_file 'spec/support/shoulda_matchers.rb'
    insert_into_file 'spec/rails_helper.rb', "require 'support/shoulda_matchers'\n", after: "require 'spec_helper'\n"
    git_add_commit 'Add shoulda-matchers'
  end

  def install_capybara
    insert_into_file 'Gemfile', "  gem 'capybara', '~> #{CAPYBARA_VER}'\n", after: "group :test do\n"
    run 'bundle install'
    copy_file 'spec/support/capybara.rb'
    insert_into_file 'spec/rails_helper.rb', "require 'support/capybara'\n", after: "require 'spec_helper'\n"
    git_add_commit 'Add capybara'
  end

  def install_factory_bot
    insert_into_file 'Gemfile', "  gem 'factory_bot_rails', '~> #{FACTORY_BOT_VER}'\n", after: "group :test do\n"
    run 'bundle install'
    copy_file 'spec/support/factory_bot.rb'
    insert_into_file 'spec/rails_helper.rb', "require 'support/factory_bot'\n", after: "require 'spec_helper'\n"
    git_add_commit 'Add factory_bot_rails'
  end

  def install_rubocop
    copy_file '.editorconfig'
    copy_file '.rubocop.yml'

    # remove Gemfile comments
    gsub_file('Gemfile', /(^#|(^\s+#))(?! gem).*\n/, '')

    insert_into_file 'Gemfile', after: "group :development, :test do\n" do
      <<~RUBY
        gem 'rubocop', require: false
        gem 'rubocop-performance', require: false
        gem 'rubocop-rails', require: false
      RUBY
    end

    run 'bundle install'
    run 'bundle exec rubocop --auto-correct --disable-uncorrectable'
    git_add_commit 'Add rubocop'
  end

  private
  def git_add_commit(message)
    run 'git add -A'
    run "git commit -m '#{message}'"
  end
end

generator = ::RailsTemplate.new
generator.shell = shell
generator.options = options.merge(app_name: app_name, rails_generator: self)
generator.destination_root = Dir.pwd
generator.invoke_all
