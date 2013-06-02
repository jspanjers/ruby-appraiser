#!/usr/bin/env ruby -w
# test_cli.rb: verify RubyAppraiser::CLI works as designed

require 'pathname'

# add lib to loadpath
lib_path = Pathname.new(__FILE__).join('../../lib').expand_path
$LOAD_PATH.unshift(lib_path) unless $LOAD_PATH.include? lib_path

require 'minitest/autorun'
require 'minitest/benchmark'

require 'ruby-appraiser/cli'

class TestCLI < Minitest::Test
  def test_empty_options
    cli = RubyAppraiser::CLI.new("")
    assert_equal({}, cli.options)
  end
end
