# encoding: utf-8
require 'open3'

class RubyAppraiser
  module Git
    extend self

    def project_root
      run('rev-parse', '--show-toplevel', &:read).chomp
    end

    def authored_lines(options = {})
      diff_command = ['diff']
      if options[:range]
        diff_command << options[:range]
      else
        diff_command << (options[:staged] ? '--cached' : 'HEAD')
      end

      diff_out = run(*diff_command)

      current_path, current_line = nil, nil
      authored_lines = Hash.new { |hash, key| hash[key] = [] }

      diff_out.each_line do |line|
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

    def run(*git_command)
      stdin, stdout, stderr = Open3.popen3('git', *git_command)
      stdin.close

      case stderr.read
      when /^fatal: Not a git/i
        then raise 'ruby-appraiser only works in git repos.'
      when /^fatal: ambiguous argument 'HEAD'/i
        then raise 'this ruby-appraiser mode only works with previous ' +
                   'commits, and your repository doesn\'t appear to have ' +
                   'any. Make some commits first, or try a different mode.'
      end

      return yield(stdout) if block_given?
      stdout
    end
  end
end
