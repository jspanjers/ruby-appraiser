# encoding: utf-8

class RubyAppraiser
  class Appraisal
    def initialize(options = {})
      @options = options.dup
    end

    def mode
      @options.fetch(:mode) { 'all' }
    end

    def success?
      defects.empty?
    end

    def defects
      @defects ||= Set.new
    end

    def source_files
      Dir::glob('**/*').select do |filepath|
        File::file? filepath and RubyAppraiser::rubytype? filepath
      end
    end

    def add_defect(defect)
      raise ArgumentError unless defect.kind_of? Defect
      defects << defect if match?(defect.location)
    end

    def to_s
      defects.to_a.sort.map(&:to_s).join($/)
    end

    def summary
      "#{defects.count} defects detected."
    end

    protected

    def match?(location)
      case mode
      when 'staged'   then staged_authored_lines.include? location
      when 'authored' then authored_lines.include? location
      when 'touched'  then touched_files.include? location[0]
      when 'all'      then true
      else            raise ArgumentError, "Unsupported mode #{mode}."
      end
    end

    def touched_files
      @touched_files ||= authored_lines.map do |file, line|
        file
      end.uniq
    end

    def authored_lines
      @authored_lines ||=
        RubyAppraiser::Git::authored_lines
    end

    def staged_authored_lines
      @staged_authored_lines ||=
        RubyAppraiser::Git::authored_lines(staged: true)
    end
  end
end
