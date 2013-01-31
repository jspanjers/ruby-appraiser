# encoding: utf-8

class RubyAppraiser
  class Appraisal
    def initialize(options)
      @options = options.dup
    end

    def mode
      @options.fetch(:mode) { 'defect' }
    end

    def success?
      defects.empty?
    end

    def defects
      @defects ||= Set.new
    end

    def add_defect( defect )
      raise ArgumentError unless defect.kind_of? Defect
      defects << defect
    end
    
    def to_s
      defects.to_a.sort.map(&:to_s).join($/)
    end

    def summary
      "#{defects.count} defects detected."
    end

    def source_files
      Dir::glob('**/*').select do |filepath|
        File::file? filepath and RubyAppraiser::rubytype? filepath
      end
    end
  end
end
