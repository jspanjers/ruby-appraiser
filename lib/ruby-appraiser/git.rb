# encoding: utf-8

class RubyAppraiser
  module Git
    extend self

    def authored_lines(options = {})
      diff_command = ['git diff']
      if options[:range]
        diff_command << options[:range]
      else
        diff_command << (options[:staged] ? '--cached' : 'HEAD')
      end

      diff_output = IO.popen(diff_command.join(' ')) { |io| io.read }

      current_path, current_line = nil, nil
      authored_lines = Hash.new { |hash, key| hash[key] = [] }

      diff_output.lines do |line|
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
        not File::file? filepath and
        not RubyAppraiser::rubytype? filepath
      end
    end
  end
end
