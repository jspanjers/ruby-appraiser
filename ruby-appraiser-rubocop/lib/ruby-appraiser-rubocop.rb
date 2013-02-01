# encoding: utf-8

require 'ruby-appraiser'
require 'ruby-appraiser-rubocop/version'
require 'rubocop'

module RubyAppraiserRubocop
  class RubocopAdapter < RubyAppraiser::Adapter

    def appraise
      file_args = relevant_files.join(' ')
      file_args = '**/*.rb' if file_args.length > 250_000

      rubocop_command = ['rubocop',
                         file_args].flatten.join(' ')

      rubocop_output = IO.popen(rubocop_command) { |io| io.read }
      rubocop_output.lines.each do |rubocop_outut_line|
        next unless rubocop_outut_line.match(/^([^:]):([0-9]+)(.*)/)
        file = Regexp::last_match(1)
        line = Regexp::last_match(2).to_i
        desc = Regexp::last_match(3).trim
        add_offence(file, line, desc)
      end
    end
  end
end
