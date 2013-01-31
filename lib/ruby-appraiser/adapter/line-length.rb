require 'ruby-appraiser'

class RubyAppraiser::Adapter::LineLength < RubyAppraiser::Adapter
  adapter_type 'line-length'

  def appraise
    source_files.each do |source_file|
      File.open(source_file) do |source|
        source.lines.each_with_index do |line, number|
          line_length = line.chomp.length
          if line_length > 80
            add_defect(source_file, number, "Line too long [#{line_length}/80]")
          end
        end
      end
    end
  end

  def multiglob(globs)
    globs.map do |glob|
      Dir::glob(glob)
    end.flatten.uniq
  end

  def source_files
    multiglob(['**/*.rb',
               '**/*.gemspec',
               '**/Capfile',
               '**/Gemfile',
               '**/Rakefile'])
  end
end
