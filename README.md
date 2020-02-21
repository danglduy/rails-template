# rails-template

Generate a Rails project with: RSpec, Capybara, FactoryBot, Shoulda-matchers & Rubocop

Instruction:

  - `railsrc`: Get options from `rails new --help`.
  - `template.rb`:  Update gems' version if needed.
  - Run
  ```shell
  gem install rails

  # use railsrc
  rails new project_name --rc=railsrc --template=template.rb

  # or if you do not want to use railsrc
  # rails new project_name --database=mysql --template=template.rb
  ```
