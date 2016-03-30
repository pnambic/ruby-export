require_relative "../graph/relation_ruby"

class AnalyzeBytecode

  # Do these bytecodes ever yield() to a block?
  attr_reader :yields

  # Do these bytecodes include unknown (not analyzed) behaviors?
  attr_reader :unknowns

  def initialize(builder, method, iseq)
    @builder = builder
    @method = method
    @iseq = iseq

    # Primitive symbolic execution state.
    # Only tracks getconstant execution to guess at dependent classes
    # and methods.
    @receiver = nil
  end

  def analyze
    begin
      analyze_instructions(@iseq.to_a[13])
      @builder.logger.info "#{@iseq.disassemble}" if unknowns

    rescue Exception => err
      trace = err.backtrace.join("\n  ")
      @builder.logger.error "Failure #{err.class}: #{err}" \
          "\n  #{trace}\n#{@iseq.disassemble}"
    end
  end

  def analyze_instructions(instructions)
    instructions.each do |instr|
      case instr
      when Fixnum
        # Ignore line markers
      when Symbol
        # Ignore branch targets
      when Array
        analyze_instruction(instr)
      else
        @builder.logger.info "Unrecognized code #{instr}"
      end
    end
  end

  def analyze_instruction(instr)
    opcode = instr[0]
    case opcode
    when :getconstant
      @receiver = calc_getconstant(instr[1])
    when :invokeblock
      @yields = true
    when :opt_send_without_block
      # Dynamic receiver or ..
      return if @receiver.nil?

      # Call links for static receivers
      method = instr[1][:mid]
      dest_node = build_method_node(method)
      return if dest_node.nil?
      @method.add_dest_depend(dest_node, RubyStaticCall)

    when :invokesuper
      method = instr[1][:mid]
      if method.nil?
        @builder.logger.info "Call super.#{@method}"
      else
        @builder.logger.info "Call super.#{method}"
      end
    when :send
      details = instr[1]
      method = details[:mid]
      block = details[:blockptr]
      analyze_instructions(block[13]) unless block.nil?

    # get/set
    when :getglobal
    when :getlocal_OP__WC__1
    when :setlocal_OP__WC__1
    when :setglobal
    when :getinstancevariable
    when :setinstancevariable
    when :setinlinecache
    when :getinlinecache
    when :getlocal
    when :setlocal
    when :getlocal_OP__WC__0
    when :setlocal_OP__WC__0
    when :getspecial
    when :setn

    # type stuff: strings, array, hash ..
    when :concatstrings
    when :tostring
    when :concatarray
    when :duparray
    when :expandarray
    when :newarray
    when :newrange
    when :splatarray
    when :newhash

    # misc
    when :adjuststack
    when :checkmatch
    when :defined
    when :dup
    when :dupn
    when :pop
    when :swap
    when :topn
    when :toregexp
    when :trace

    # opt_s
    when :opt_aref
    when :opt_aref_with
    when :opt_aset
    when :opt_case_dispatch
    when :opt_empty_p
    when :opt_eq
    when :opt_ge
    when :opt_gt
    when :opt_length
    when :opt_le
    when :opt_lt
    when :opt_ltlt
    when :opt_minus
    when :opt_mult
    when :opt_neq
    when :opt_not
    when :opt_plus
    when :opt_regexpmatch1
    when :opt_regexpmatch2
    when :opt_size

    # puts
    when :putnil
    when :putobject
    when :putobject_OP_INT2FIX_O_0_C_
    when :putobject_OP_INT2FIX_O_1_C_
    when :putself
    when :putstring

    # control flow
    when :branchif
    when :branchunless
    when :jump
    when :leave
    when :nop
    when :throw
    else
      @unknowns = true
      @builder.logger.warn "Unrecognized instruction #{instr}"
    end
  end

  private

  def build_method_node(sym)

    dest = calc_method(sym)
    return if dest.nil? || dest.owner.nil?

    owner = first_concrete_class(dest.owner)
    dest_node = RubyClassMethod.new(owner, dest)
  end

  def first_concrete_class(method)
    method.ancestors.each do |elder|
      return elder unless elder.singleton_class?
    end
  end

  def calc_method(sym)
    scope = @receiver
    @receiver = nil

    # Ignore unresolvable methods.
    # This only works for dispatch directly to a class object,
    # i.e. a Ruby "class" method (approx a Java static method).
    # A better Ruby interpretter might be able to deduce the
    # receiving object for general method dispatch.
    begin
      scope.method(sym)
    rescue NameError
      nil
    end
  end

  def calc_getconstant(sym)
    result = eval_getconstant(sym)
    @builder.add_for_analysis(result)
    result
  end

  def eval_getconstant(sym)
    scope = @receiver
    @receiver = nil

    return lookup_scope_symbol(scope, sym) unless scope.nil?
    @method.lookup_receiver(sym)
  end

  def lookup_scope_symbol(scope, sym)
    begin
      scope.const_get(sym, true)
    rescue NameError
      nil
    end
  end
end