# encoding: utf-8

require 'ruby-appraiser'

class RubyAppraiser::Adapter::LineLength < RubyAppraiser::Adapter
  def appraise
    source_files.each do |source_file|
      File.open(source_file) do |source|
        source.each_line do |line|
          line_length = line.chomp.length
          if line_length > 80
            add_defect(source_file, source.lineno,
                       "Line too long [#{line_length}/80]")
          end
        end
      end
    end
  end
end
