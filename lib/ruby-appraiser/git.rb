# encoding: utf-8
require 'open3'

class RubyAppraiser
  module Git
    extend self

    def authored_lines(options = {})
      diff_command = ['git', 'diff']
      if options[:range]
        diff_command << options[:range]
      else
        diff_command << (options[:staged] ? '--cached' : 'HEAD')
      end

      stdin, stdout, stderr = Open3.popen3(*diff_command)
      stdin.close

      case stderr.read
      when /^fatal: Not a git/i
        then raise 'ruby-appraiser only works in git repos.'
      when /^fatal: ambiguous argument 'HEAD'/i
        then raise 'this ruby-appraiser mode only works with previous ' +
                   'commits, and your repository doesn\t appear to have ' +
                   'any. Make some commits first, or try a different mode.'
      end

      current_path, current_line = nil, nil
      authored_lines = Hash.new { |hash, key| hash[key] = [] }

      stdout.each_line do |line|
        case line
        when /^---/ then next
        when /^\+\+\+ (?:b\/)?(.*)/
          current_path = Regexp::last_match(1)
        when /-[0-9]+(?:,[0-9]+)? \+([0-9]+)((,[0-9]+)?)/
          current_line = Regexp::last_match(1).to_i
        else
          next if line.start_with? '-'
          authored_lines[current_path] << current_line if line[0] == '+'
          current_line += 1 unless current_line.nil?
        end
      end

      authored_lines.default_proc = Proc.new { [] }
      authored_lines.reject do |filepath, lines|
        not File::file? filepath or
        not RubyAppraiser::rubytype? filepath
      end
    end
  end
end
