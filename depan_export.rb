#!/usr/bin/ruby

require_relative "analyze/analyze_ruby"
require_relative "writer/depan_writer"
require "optparse"

class DepanExporter
  attr_reader :builder

  def initialize
    @builder = GraphBuilder.new
    @reqs = []
    @class_syms = []
    @recurse = true
  end

  def import_options(args)
    opts = OptionParser.new
    opts.banner = "Usage: depan_export.rb [options] [require-files]"
    opts.on("-c", "--class", '=MANDATORY', "Analyze the named class") do |sym|
      @class_syms << sym
    end
    opts.on("-r", "--require", '=MANDATORY', "Require the named file, '.rb. implied") do |reqd|
      @reqs << reqd
    end
    opts.on("--explicit", "Restrict analysis to explicit symbols, no recursive analysis") do |recurse|
      @recurse = false
    end

    # Assume any leftovers are files that should be required.
    @reqs.concat(opts.parse(args))
  end

  def import_requires
    @reqs.each do |reqd|
      require "#{reqd}.rb"
    end
  end

  def build_types(symbols)
    result = []
    symbols.each do |symbol|
      type = Kernel.const_get(symbol)
      if type.nil?
        puts "Unrecognized symbol #{symbol}"
        break
      end
      result << type
    end
    return result
  end

  def analyze_types(types)
    types.each do |type|
      puts "Analyzing class #{type}"
      analyzer = AnalyzeClass.new(@builder, type)
      analyzer.analyze
    end
  end

  def analyze_symbols
    symbol_types = build_types(@class_syms)
    analyze_types(symbol_types)
    return unless @recurse

    deps = @builder.read_deps
    until deps.nil? || deps.empty?
      analyze_types(deps)

      deps = @builder.read_deps
    end
  end

  def export_depan
    writer = DepanWriter.new(builder)
    writer.export
  end

end

exporter = DepanExporter.new
exporter.import_options(ARGV)
exporter.import_requires
exporter.analyze_symbols
exporter.export_depan
