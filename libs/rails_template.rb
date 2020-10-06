# frozen_string_literal: true

require 'pathname'

module Libs
  class RailsTemplate < Thor::Group
    include Thor::Actions
    include Rails::Generators::Actions

    attr_accessor :options

    def self.source_root
      File.join(__dir__, '../templates')
    end

    def create_initial_commit
      add_commit 'Init'
    end

    def exclude_database_yml
      inside(destination_root) do
        run 'git rm --cached config/database.yml'
        run 'cp config/database.yml config/database.yml.example'
      end

      append_to_file '.gitignore', '/config/database.yml'
      add_commit 'Exclude database.yml'
    end

    def install_rspec(version)
      insert_into_file 'Gemfile',
                       "  gem 'rspec-rails', '~> #{version}'\n",
                       after: "group :development, :test do\n"
      run 'bundle install'
      rails_command 'generate rspec:install'
      add_commit 'Add rspec'
    end

    def install_capybara(version)
      if api? || skip_test? || skip_system_test?
        add_test_gem_group
        insert_into_file 'Gemfile',
                         "  gem 'capybara', '~> #{version}'\n",
                         after: "group :test do\n"
      end

      run 'bundle install'
      copy_file 'spec/support/capybara.rb'
      insert_into_file 'spec/rails_helper.rb',
                       "require 'support/capybara'\n",
                       after: "require 'spec_helper'\n"
      add_commit 'Add capybara'
    end

    def install_factory_bot(version)
      insert_into_file 'Gemfile',
                       "  gem 'factory_bot_rails', '~> #{version}'\n",
                       after: "group :test do\n"
      run 'bundle install'
      copy_file 'spec/support/factory_bot.rb'
      insert_into_file 'spec/rails_helper.rb',
                       "require 'support/factory_bot'\n",
                       after: "require 'spec_helper'\n"
      add_commit 'Add factory_bot_rails'
    end

    def install_shoulda_matchers(version)
      insert_into_file 'Gemfile',
                       "  gem 'shoulda-matchers', '~> #{version}'\n",
                       after: "group :test do\n"
      run 'bundle install'
      copy_file 'spec/support/shoulda_matchers.rb'
      insert_into_file 'spec/rails_helper.rb',
                       "require 'support/shoulda_matchers'\n",
                       after: "require 'spec_helper'\n"
      add_commit 'Add shoulda-matchers'
    end

    def install_rubocop
      copy_file '.editorconfig'
      copy_file '.rubocop.yml'

      # remove Gemfile comments
      gsub_file('Gemfile', /(^#|(^\s+#))(?! gem).*\n/, '')
      # insert fake blank lines for rubocop to clean
      gsub_file('Gemfile', /end$|^ruby(.*)$\n/) { |match| match << "\n" }

      insert_into_file 'Gemfile', after: "group :development, :test do\n" do
        <<~RUBY
          gem 'rubocop', require: false
          gem 'rubocop-performance', require: false
          gem 'rubocop-rails', require: false
        RUBY
      end

      run 'bundle install'
      run 'bundle exec rubocop --auto-correct'
      add_commit 'Add rubocop and editorconfig'
    end

    private

    def add_test_gem_group
      # remove existing group test created by rails
      # gsub_file('Gemfile', /^(group :test)[\s\S]*?[\n\r]end\n/, '')
      insert_into_file 'Gemfile', after: /group :development do[^\0]*?end\n/ do
        <<~RUBY
          group :test do
          end
        RUBY
      end
    end

    def api?
      options[:api]
    end

    def skip_test?
      options[:skip_test]
    end

    def skip_system_test?
      options[:skip_system_test]
    end

    def add_commit(message)
      git add: '.'
      git commit: "-m '#{message}'"
    end
  end
end
