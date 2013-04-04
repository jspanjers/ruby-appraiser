# encoding: utf-8

require 'ruby-appraiser'
require 'ruby-appraiser-reek/version'
require 'reek'
require 'shellwords'

module RubyAppraiserReek
  class ReekAdapter < RubyAppraiser::Adapter

    def appraise
      return false if relevant_files.empty?
      file_args = Shellwords::join(relevant_files)
      file_args = '**/*.rb' if file_args.length > 250_000

      reek_command = ['reek',
                      '--yaml',
                      file_args].flatten.join(' ')
      puts reek_command if @options[:verbose]

      reek_yaml = IO.popen(reek_command) { |io| io.read }
      return false if reek_yaml.chomp.empty?
      reek_output = YAML.load(reek_yaml)
      reek_output.each do |smell|
        Array(smell.lines).each do |line|
          add_defect(relative_path(smell.source),
                     line,
                     "#{smell.context} #{smell.message}")
        end
      end
    end
  end
end
