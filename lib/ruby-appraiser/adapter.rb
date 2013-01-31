# encoding: utf-8

require 'set'

class RubyAppraiser::Adapter
  class << self
    def inherited(base)
      registry << base
    end

    def registry
      @registry ||= Set.new
    end

    def adapter_type(type = nil)
      @adapter_type = type.to_s unless type.nil?
      
      @adapter_type or
        self.name.split('::').last.downcase
    end

    def find(query)
      registry.detect do |adapter|
        adapter.adapter_type == query
      end
    end

    def get(query)
      find(query) or
        attempt_require_adapter(query, "ruby-appraiser/adapter/#{query}") or
        attempt_require_adapter(query, "ruby-appraiser/#{query}") or
        attempt_require_adapter(query, "ruby-appraiser-#{query}")
    end

    def all
      # load relevant gems
      scanner_pattern = /^ruby-appraiser-([a-zA-Z0-9_\-])+/
      (`gem list --local`).scan scanner_pattern do |gem_name, adapter_type|
        attempt_require_adapter(adapter_type, gem_name)
      end

      # look in the adapter directory
      Dir::glob(File::expand_path('../adapter/*.rb', __FILE__)) do |filepath|
        require filepath
      end

      # return the registry
      registry
    end

    def attempt_require_adapter(name, path)
      require path and find(name)
    rescue LoadError
      false
    end

    def find!(query)
      find(query) or raise ArgumentError, "Adapter '#{query}' not found."
    end
  end

  def initialize(appraisal, options)
    @appraisal = appraisal
    @options = options.dup
  end

  def appraise
    raise NotImplementedError, "#{self.class.name} does not implement appraise."
  end

  def add_defect(file, line, desc)
    @appraisal.add_defect RubyAppraiser::Defect.new(file, line, desc)
  end
end

