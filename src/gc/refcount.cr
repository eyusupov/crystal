{% unless flag?(:win32) %}
  @[Link("pthread")]
  lib LibC
  end
{% end %}

module GC
  module RefCount
    macro included 
      # TODO: check if atomic is already atomic on x86? Does llvm generate optimal code?
      @reference_count = Atomic.new(0_u32)
    end

    def reference_count
      @reference_count.get
    end

    def add_reference
      # TODO: use release memory order
      @reference_count.add(1)
    end

    def dereference
      # TODO: use acquire memory ordering
      count = @reference_count.sub(1)
      raise "Negative amount of references for #{self}: #{count}" if count < 0
      GC.free(self) if count.zero?
    end

    def free
      # other client 
      count = @reference_count.get
      puts "Was asked to dereference still alive object #{self} (#{count} refrences)"
      # TODO: put a fence with release memory ordering
      {% for ivar in @type.instance_vars.select(&.is_a? Reference) %}
        puts "Dereferencing {{ ivar }}"
        @{{ ivar }}.dereference
      {% end %}
      # TODO: add fence
      GC.free(self)
    end
  end

  struct Stats
  end

  def self.init
  end

  # :nodoc:
  def self.malloc(size : LibC::SizeT)
    LibC.malloc(size)
  end

  # :nodoc:
  def self.malloc_atomic(size : LibC::SizeT)
    LibC.malloc(size)
  end

  # :nodoc:
  def self.realloc(pointer : Void*, size : LibC::SizeT)
    LibC.realloc(pointer, size)
  end

  def self.collect
  end

  def self.enable
  end

  def self.disable
  end

  def self.free(pointer : Void*)
    LibC.free(pointer)
  end

  def self.is_heap_ptr(pointer : Void*)
    false
  end

  def self.add_finalizer(object)
  end

  def self.stats
  end

  {% unless flag?(:win32) %}
    # :nodoc:
    def self.pthread_create(thread : LibC::PthreadT*, attr : LibC::PthreadAttrT*, start : Void* -> Void*, arg : Void*)
      LibC.pthread_create(thread, attr, start, arg)
    end

    # :nodoc:
    def self.pthread_join(thread : LibC::PthreadT) : Void*
      ret = LibC.pthread_join(thread, out value)
      raise Errno.new("pthread_join") unless ret == 0
      value
    end

    # :nodoc:
    def self.pthread_detach(thread : LibC::PthreadT)
      LibC.pthread_detach(thread)
    end
  {% end %}

  @@stack_bottom = Pointer(Void).null

  # :nodoc:
  def self.current_thread_stack_bottom
    @@stack_bottom
  end

  # :nodoc:
  {% if flag?(:preview_mt) %}
    def self.set_stackbottom(thread : Thread, stack_bottom : Void*)
      # NOTE we could store stack_bottom per thread,
      #      and return it in `#current_thread_stack_bottom`,
      #      but there is no actual use for that.
    end
  {% else %}
    def self.set_stackbottom(stack_bottom : Void*)
    end
  {% end %}

  # :nodoc:
  def self.lock_read
  end

  # :nodoc:
  def self.unlock_read
  end

  # :nodoc:
  def self.lock_write
  end

  # :nodoc:
  def self.unlock_write
  end

  # :nodoc:
  def self.push_stack(stack_top, stack_bottom)
  end
end
