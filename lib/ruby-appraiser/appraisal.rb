# encoding: utf-8

class RubyAppraiser
  class Appraisal
    def initialize(options = {})
      @options = options.dup.freeze
    end

    def mode
      @options.fetch(:mode) { 'all' }
    end

    def options
      @options.dup
    end

    def run!
      appraisers.each do |appraiser|
        appraiser.appraise
      end unless relevant_files.empty?

      @has_run = true
    end

    def success?
      run! unless @has_run

      defects.empty?
    end

    def defects
      @defects ||= Set.new
    end

    def adapters
      @adapters ||= Set.new
    end

    def appraisers
      adapters.map do |adapter|
        adapter.new(self, options)
      end
    end

    def add_adapter(name)
      Adapter::get(name).tap do |adapter|
        adapter and self.adapters << adapter
      end
    end

    def source_files
      Dir::glob(File::expand_path('**/*', project_root)).select do |filepath|
        File::file? filepath and RubyAppraiser::rubytype? filepath
      end.map { |path| relative_path path }
    end

    def add_defect(defect, *args)
      unless defect.kind_of? Defect
        defect = Defect.new(defect, *args)
      end
      defects << defect if match?(defect.location)
    end

    def to_s
      defects.to_a.sort.map(&:to_s).join($/)
    end

    def summary
      "#{defects.count} defects detected."
    end

    def project_root
      @project_root ||= (`git rev-parse --show-toplevel`).chomp
    end

    def relative_path(path)
      full_path = File::expand_path(path, project_root)
      full_path[(project_root.length + 1)..-1]
    end

    protected

    def match?(location)
      file, line = *location
      relevant_lines[file].include? line
    end

    def relevant_files
      relevant_lines.keys
    end

    def relevant_lines
      case mode
      when 'staged'   then staged_authored_lines
      when 'authored' then authored_lines
      when 'touched'  then all_lines_in touched_files
      when 'all'      then all_lines_in source_files
      else            raise ArgumentError, "Unsupported mode #{mode}."
      end
    end

    # return a hash.
    # key is a filename
    # value is a truebot
    def all_lines_in(files)
      infinite_set = (0 .. (1.0 / 0))
      files.reduce(Hash.new { [] }) do |memo, file|
        memo.merge!(file => infinite_set)
      end
    end

    def touched_files
      @touched_files ||= authored_lines.keys
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
