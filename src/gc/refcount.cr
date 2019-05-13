module GC
  module RefCount
    macro included 
      # TODO: check if atomic is already atomic on x86? Does llvm generate optimal code?
      @reference_count = Atomic.new(1_u32)
    end

    @[AlwaysInline]
    def reference_count
      @reference_count.get
    end

    @[AlwaysInline]
    def add_reference
      # TODO: use release memory order
      @reference_count.add(1)
    end

    @[AlwaysInline]
    def dereference
      # TODO: use acquire memory ordering
      count = @reference_count.sub(1)
      raise "Negative amount of references for #{self}: #{count}" if count < 0
      GC.free(self) if count.zero?
    end

    @[AlwaysInline]
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
end
