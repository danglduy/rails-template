require 'yaml'

module Libs
  module Helpers
    include Thor::Actions

    Dir[File.join(__dir__, 'helpers/*.yaml'), File.join(__dir__, 'steps/*.yaml')].each do |fname|
      yaml_content = File.read(fname)
      yaml_parsed = YAML.load(yaml_content)
      define_method(yaml_parsed["function_name"]) do |*args, **kwargs|
        yaml_parsed["steps"].each do |step|
          step.each do |fn, fn_args|
            if args.present?
              send(fn, *fn_args.map{|a| a.is_a?(Hash) ? a : a % Hash[yaml_parsed['args'].map(&:to_sym).zip(args)] % kwargs})
            else
              send(fn, *fn_args.map{|a| a.is_a?(Hash) ? a : a % kwargs})
            end
          end
        end
      end
    end

    extend self
  end
end
