require 'yaml'

module Libs
  module Helpers
    include Thor::Actions

    Dir[File.join(__dir__, 'helpers/*.yaml'), File.join(__dir__, 'steps/*.yaml')].each do |file|
      file_content = File.read(file)
      step = YAML.load(file_content)
      define_method(step["name"]) do |*args, **kwargs|
        step["cmds"].each do |cmd|
          cmd.each do |fn, fn_args|
            if args.present?
              send(fn, *fn_args.map{|a| a.is_a?(Hash) ? a : a % Hash[step['args'].map(&:to_sym).zip(args)] % kwargs})
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
