# encoding: utf-8

class RubyAppraiser
  class Defect
    def initialize(file, line, description)
      @location = [file, line].freeze
      @description = description.dup.freeze
    end

    attr_reader :location
    attr_reader :description

    def file
      @location[0]
    end

    def line
      @location[1]
    end

    def to_s
      "#{file}:#{line} #{description}"
    end

    def ==(other)
      self.to_s == other.to_s
    end

    def <=>(other)
      self.to_s <=> other.to_s
    end
  end
end
