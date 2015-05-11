# encoding: utf-8

require 'ruby-appraiser'
require 'ruby-appraiser-rubocop/version'
require 'rubocop'
require 'shellwords'

module RubyAppraiserRubocop
  class RubocopAdapter < RubyAppraiser::Adapter

    def appraise
      file_args = Shellwords::join(relevant_files)
      file_args = '**/*.rb' if file_args.length > 250_000

      rubocop_command = ['rubocop --format emacs --force-exclusion',
                         file_args].flatten.join(' ')
      puts rubocop_command if @options[:verbose]

      rubocop_output = IO.popen(rubocop_command) { |io| io.read }

      file_line_desc_pattern = /^([^:]+):([0-9]+)(\:[0-9]+\:?)?(.*)/
      rubocop_output.lines.each do |rubocop_output_line|
        next unless rubocop_output_line.match(file_line_desc_pattern)
        file = Regexp::last_match(1)
        line = Regexp::last_match(2).to_i
        # column = Regexp::last_match(3).to_i # currently throw-away :(
        desc = Regexp::last_match(4).strip
        add_defect(file, line, desc)
      end
    end
  end
end
