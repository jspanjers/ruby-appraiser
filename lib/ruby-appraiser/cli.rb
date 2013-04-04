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
      adapters = Set.new

      OptionParser.new do |opts|
        opts.banner = "Usage: #{File::basename($0)} [inspector...] [options]"
        opts.on('-v', '--[no-]verbose', 'Run verbosely') do |verbose|
          @options[:verbose] = verbose
        end
        opts.on('--list', 'List available adapters') do |list|
          puts available_adapters
          exit 1
        end
        opts.on('--silent', 'Silence output') do |silent|
          @options[:silent] = true
        end
        opts.on('--mode=MODE',
                'Set the mode. ' +
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

          indented_git_hook = <<-EOGITHOOK
            #!/bin/bash
            echo -e "\\033[0;36mRuby Appraiser: running\\033[0m"

            bundle exec #{command} #{hook_args.join(' ')}

            result_code=$?
            if [ $result_code > "0" ]; then
              echo -en "\\033[0;31m" # RED
              echo "[✘] Ruby Appraiser found newly-created defects and "
              echo "    has blocked your commit."
              echo "    Fix the defects and commit again."
              echo "    To bypass, commit again with --no-verify."
              echo -en "\\033[0m" # RESET
              exit $result_code
            else
              echo -en "\\033[0;32m" # GREEN
              echo "[✔] Ruby Appraiser ok"
              echo -en "\\033[0m" #RESET
            fi
          EOGITHOOK

          indent = indented_git_hook.scan(/^\s*/).map(&:length).min
          puts indented_git_hook.lines.map {|l| l[indent..-1]}.join
          exit 1
        end
        opts.on('--all', 'Run all available adapters.') do
          adapters += available_adapters
        end
      end.parse!(args)

      @appraisal = RubyAppraiser::Appraisal.new(options)
      adapters += args
      adapters.each do |adapter|
        @appraisal.add_adapter(adapter) or
          raise "Unknown adapter '#{adapter}'"
      end
      Dir::chdir((`git rev-parse --show-toplevel`).chomp)
    end

    def options
      @options.dup
    end

    def run
      @appraisal.run!
      puts @appraisal unless @options[:silent]
      puts @appraisal.summary if @options[:verbose]
      @appraisal.success?
    rescue Object
      puts "#{@appraisal.class.name} caught #{$!} at #{$!.backtrace.first}."
    end

    def available_adapters
      @available_adapters ||= RubyAppraiser::Adapter::all.map(&:adapter_type)
    end
  end
end
