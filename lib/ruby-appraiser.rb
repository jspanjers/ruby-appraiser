# encoding: utf-8

require 'ruby-appraiser/version'

class RubyAppraiser

  autoload :Adapter,    'ruby-appraiser/adapter'
  autoload :Appraisal,  'ruby-appraiser/appraisal'
  autoload :CLI,        'ruby-appraiser/cli'
  autoload :Defect,     'ruby-appraiser/defect'
  autoload :Git,        'ruby-appraiser/git'

  def initialize(options)
    @options = options.dup
  end

  def options
    @options.dup
  end


  def appraisal
    unless @appraisal
      @appraisal = Appraisal.new(options)

      unless @appraisal.relevant_files.empty?
        appraisers(@appraisal).each(&:appraise)
      end
    end

    @appraisal
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
          file.readline(20).chomp =~ /\A#\!.+ruby/
        end
      rescue EOFError      # file was empty
      rescue ArgumentError # invalid byte sequence
      end

      false
    end
  end
end
