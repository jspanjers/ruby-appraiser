# encoding: utf-8

require 'ruby-appraiser'
require 'optparse'
require 'set'

class RubyAppraiser
  class CLI
    def initialize(args = ARGV)
      @argv = ARGV.dup
      args = @argv.dup # needed for --git-hook
      @options = {}

      OptionParser.new do |opts|
        opts.banner = "Usage: #{$0} [inspector...] [options]"
        opts.on('-v', '--[no-]verbose', 'Run verbosely') do |verbose|
          @options[:verbose] = verbose
        end
        opts.on('--list', 'List available adapters') do |list|
          puts RubyAppraiser::Adapter::all.map(&:adapter_type)
          exit 1
        end
        opts.on('--silent', 'Silence output') do |silent|
          @options[:silent] = true
        end
        opts.on('--mode=MODE', 
                "Set the mode. "+
                '[staged,authored,touched,all]') do |mode|
          @options[:mode] = mode
        end
        opts.on('--git-hook') do
          command = $0
          if (`which #{File::basename(command)}`).chomp == command
            command = File::basename(command)
          end
          be = 'bundle exec'
          hook_args = @argv.select { |arg| arg != '--git-hook' }
          
          git_hook = []
          git_hook << "\#!/usr/bin/env ruby"
          git_hook << "IO.popen('#{be} #{command} #{hook_args.join(' ')}')"
          git_hook << "exit($?)"

          puts git_hook.join($/)
          exit 1
        end
      end.parse!(args)

      @appraiser = RubyAppraiser.new(options)
      while arg = args.pop
        @appraiser.add_adapter(arg) or raise "Unknown adapter '#{arg}'"
      end
    end

    def options
      @options.dup
    end

    def run
      appraisal = @appraiser.appraisal
      puts appraisal unless @options[:silent]
      puts appraisal.summary if @options[:verbose]
      appraisal.success?
    rescue Object
      puts "#{@appraiser.class.name} caught #{$!} at #{$!.backtrace.first}."
    end
  end
end
