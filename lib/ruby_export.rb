#!/usr/bin/ruby

require_relative "analyze/analyze_class"
require_relative "analyze/graph_builder"
require_relative "writer/depan_writer"

require "logger"
require "optparse"

class RubyExport

  def initialize
    @builder = nil
    @logger = nil
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
    opts.on('-l', '--logger', '=MANDATORY', 'Output for logger data (.log expected)') do |log_name|
      @log_name = log_name
    end
    opts.on('-o', '--output', '=MANDATORY', 'Output for dependency data (.dgi expected)') do |out_name|
      @out_name = out_name
    end
    opts.on("-r", "--require", '=MANDATORY', "Require the named file, '.rb. implied") do |reqd|
      @reqs << reqd
    end
    opts.on("--explicit", "Restrict analysis to explicit symbols, no recursive analysis") do |recurse|
      @recurse = false
    end

    # Assume any leftovers are files that should be required.
    @reqs.concat(opts.parse(args))

    # Configure based on options
    @logger = build_logger
    @builder = build_builder
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
    @logger.info "New Cycle:: #{types}"
    types.each do |type|
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
    begin
      out_file = build_output
      writer = DepanWriter.new(out_file, @builder)
      writer.export
    ensure
      out_file.close unless @out_name.nil?
    end
  end

  def execute_export(argv)
    import_options(argv)
    import_requires
    analyze_symbols
    export_depan
  end

  private

  def build_logger
    return Logger.new(STDERR) if @log_name.nil?
    Logger.new(@log_name)
  end

  def build_builder
    GraphBuilder.new(@logger)
  end

  def build_output
    return STDOUT if @out_name.nil?
    File.new(@out_name, 'w')
  end
end

exporter = RubyExport.new
exporter.execute_export(ARGV)
