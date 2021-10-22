module ArtNet::IO::Callbacks
    
  attr_reader :callbacks

  def on?(name, &block)
    @callbacks&.any? { |blk| blk == block }
  end
  def on(name, &block)
    (@callbacks[name] ||= []) << block
    # TODO: maybe
    # all blocks, no uniq fix
    # [1,2,1,2,3,1] -> [1,2,1,2,3,1]
    # @callbacks[name] = @callbacks[name]
    # OR
    # all blocks, uniq fix, only first run (remove new blocks)
    # [1,2,1,2,3,1] -> [1,2,3]
    # @callbacks[name] = @callbacks[name].uniq
    # OR
    # all blocks, uniq fix, only last run (remove old blocks)
    # [1,2,1,2,3,1] -> [2,3,1]
    @callbacks[name] = @callbacks[name].reverse.uniq.reverse 
  end
  def off(name, &block)
    if block
      @callbacks[name]&.delete(block)
    else
      @callbacks[name]&.shift
    end
  end
  
end