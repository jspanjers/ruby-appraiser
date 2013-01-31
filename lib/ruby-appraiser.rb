require "ruby-appraiser/version"

class RubyAppraiser

  autoload :Adapter,    'ruby-appraiser/adapter'
  autoload :Appraisal,  'ruby-appraiser/appraisal'
  autoload :CLI,        'ruby-appraiser/cli'
  autoload :Defect,     'ruby-appraiser/defect'

  def initialize(options)
    @options = options.dup
  end

  def options
    @options.dup
  end

  def add_adapter(name)
    Adapter::get(name).tap do |adapter|
      adapter and self.adapters << adapter
    end
  end

  def appraisal
    unless @appraisal
      @appraisal = Appraisal.new(options)

      appraisers(appraisal).each(&:appraise)
    end

    @appraisal
  end

  def adapters
    @adapters ||= Set.new
  end

  def appraisers(appraisal)
    adapters.map do |adapter|
      adapter.new(appraisal, options)
    end
  end

  class << self
    def rubytypes
      %w(
        *.rb
        *.gemspec
        Capfile
        Gemfile
        Rakefile
      )
    end

    def rubytype?(filepath)
      # true if the extension matches
      filename = File::basename(filepath)
      return true if rubytypes.any? do |rubytype|
        File::fnmatch(rubytype, filename)
      end

      # true if file has a ruby shebang
      begin
        return true if File.open(filepath) do |file| 
          file.readline.chomp =~ /#\!.+ruby/
        end
      rescue Errno::ENOENT
      end

      false
    end
  end
end
