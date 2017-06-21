require "pathname"

class ::RailsTemplate < Thor::Group
  include Thor::Actions
  include Rails::Generators::Actions

  attr_accessor :options

  def self.source_root
    File.join(__dir__, "templates")
  end

  def copy_gemfile
    remove_file "Gemfile"
    template "Gemfile.erb", "Gemfile"
    copy_file "Gemfile.dev", "Gemfile.dev"
  end

  def copy_sample_files
    controller = "app/controllers/pages_controller.rb"
    copy_file controller, controller

    view = "app/views/pages/home.html.erb"
    copy_file view, view

    script = "app/assets/javascripts/application/controllers/pages/home.es6"
    copy_file script, script
  end

  def copy_rc_files
    copy_file ".eslintrc"
    copy_file ".editorconfig"
    template ".rubocop.yml.erb", ".rubocop.yml"
  end

  def copy_routes
    remove_file "config/routes.rb"
    template "config/routes.erb", "config/routes.rb"
  end

  def copy_assets_manifest
    copy_file "app/assets/config/manifest.js"
  end

  def configure_javascript
    return if skip_javascript?

    template "package.json.erb", "package.json"
    remove_file "app/assets/javascripts/application.js"
    copy_file "app/assets/javascripts/application.js"
    copy_file "app/assets/javascripts/application/boot.es6"
    create_file "app/assets/javascripts/application/routes/.keep"
  end

  def configure_action_cable
    return if options[:skip_action_cable]
    file = "app/assets/javascripts/cable.js"
    copy_file file
  end

  def configure_env
    template ".env.development.erb", ".env.development"
    template ".env.test.erb", ".env.test"
    template "config/config.erb", "config/config.rb"
    append_file "config/boot.rb", <<-RUBY.strip_heredoc

      # Load configuration
      require "env_vars/dotenv"
      require File.expand_path("../config", __FILE__)
    RUBY
  end

  def configure_database
    return if skip_active_record?

    remove_file "config/database.yml"
    template "config/database.erb", "config/database.yml"
  end

  def configure_test
    return if skip_test_unit?

    remove_file "test/test_helper.rb"
    copy_file "test/test_helper.rb"
    copy_file "test/support/minitest.rb"
    copy_file "test/support/fixtures.rb"
  end

  def configure_generators
    template "config/initializers/generators.erb",
             "config/initializers/generators.rb"
  end

  def configure_localization
    file = "config/initializers/localization.rb"
    template file, file
  end

  def configure_gitignore
    remove_file ".gitignore"
    copy_file ".gitignore"
  end

  def configure_layout
    layout_path = "app/views/layouts/application.html.erb"
    remove_file layout_path
    template layout_path, layout_path
  end

  def configure_secure_headers
    copy_file "config/initializers/secure_headers.rb"
  end

  def configure_lograge
    copy_file "config/initializers/lograge.rb"
  end

  def configure_assets
    remove_file "config/initializers/assets.rb"
    template "config/initializers/assets.erb",
             "config/initializers/assets.rb"
  end

  def copy_setup_scripts
    remove_file "bin/setup"
    copy_file "bin/setup"
    copy_file "bin/setup.Darwin"
    run "chmod +x bin/*"
  end

  def configure_test_squad
    run "bundle install"
    generate "test_squad:install", "--framework", "qunit", "--skip-source"
  end

  private

  def edge?
    options[:edge]
  end

  def dev?
    options[:dev]
  end

  def skip_active_record?
    options[:skip_active_record]
  end

  def skip_test_unit?
    options[:skip_test_unit]
  end

  def postgresql?
    !skip_active_record? && database_adapter == "postgresql"
  end

  def app_const
    options[:app_name].camelize
  end

  def database_adapter
    {
      "mysql"      => "mysql2",
      "postgresql" => "pg",
      "postgres"   => "pg",
      "sqlite3"    => "sqlite3"
    }.fetch(options[:database])
  end

  def skip_javascript?
    options[:skip_javascript]
  end

  def database_url(env)
    database_name = "#{options[:app_name]}_#{env}"

    case database_adapter
    when "sqlite3"
      %[sqlite3:db/#{env}.sqlite3]
    when "mysql"
      %[mysql2://root@localhost/#{database_name}]
    else
      %[postgres:///#{database_name}]
    end
  end

  def ruby_version
    {
      full: RUBY_VERSION,
      major: RUBY_VERSION[/^(\d+\.\d+)\..*?$/, 1]
    }
  end

  def rails_version
    [Rails::VERSION::MAJOR, Rails::VERSION::MINOR].join(".")
  end
end

generator = ::RailsTemplate.new
generator.shell = shell
generator.options = options.merge(app_name: app_name, rails_generator: self)
generator.destination_root = Dir.pwd
generator.invoke_all
