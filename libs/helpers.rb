require 'yaml'

module Libs
  module Helpers
    include Thor::Actions

    Dir[File.join(__dir__, 'helpers/*.yaml'), File.join(__dir__, 'steps/*.yaml')].each do |fname|
      yaml_content = File.read(fname)
      yaml_parsed = YAML.load(yaml_content)
      define_method(yaml_parsed["function_name"]) do |*args, **kwargs|
        yaml_parsed["steps"].each do |step|
          step.each do |k, v|
            if yaml_parsed["arguments"] && args.present?
              send(k, v % Hash[yaml_parsed["arguments"].map(&:to_sym).zip(args)] % kwargs)
            else
              send(k, v % kwargs)
            end
          end
        end
      end
    end

    extend self
  end
end
