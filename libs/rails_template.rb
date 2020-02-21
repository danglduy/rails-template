require 'pathname'
require_relative 'helpers'

module Libs
  class RailsTemplate < Thor::Group
    include Thor::Actions
    include Rails::Generators::Actions
    include Libs::Helpers

    RSPEC_VER = 3.9
    SHOULDA_VER = 4.2
    CAPYBARA_VER = 3.31
    FACTORY_BOT_VER = 5.1

    def self.source_root
      File.join(__dir__, '../templates')
    end

#     def initialize(current_dir)
#       self.destination_root = current_dir
#     end

		def create_initial_commit
			run 'bundle install'
			run 'bundle binstubs bundler'
			add_commit 'Init'
		end

    def add_test_gem_group
      return unless api?
      # remove existing group test created by rails
      # gsub_file('Gemfile', /^(group :test)[\s\S]*?[\n\r]end\n/, '')
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
      add_commit 'Add shoulda-matchers'
    end

    def install_capybara
      insert_into_file 'Gemfile', "  gem 'capybara', '~> #{CAPYBARA_VER}'\n", after: "group :test do\n" if api?
      run 'bundle install'
      copy_file 'spec/support/capybara.rb'
      insert_into_file 'spec/rails_helper.rb', "require 'support/capybara'\n", after: "require 'spec_helper'\n"
      add_commit 'Add capybara'
    end

    def install_factory_bot
      insert_into_file 'Gemfile', "  gem 'factory_bot_rails', '~> #{FACTORY_BOT_VER}'\n", after: "group :test do\n"
      run 'bundle install'
      copy_file 'spec/support/factory_bot.rb'
      insert_into_file 'spec/rails_helper.rb', "require 'support/factory_bot'\n", after: "require 'spec_helper'\n"
      add_commit 'Add factory_bot_rails'
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
      add_commit 'Add rubocop'
    end

    private
    def api?
      options[:api]
    end
  end
end
