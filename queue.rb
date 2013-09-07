class Queue

  attr_reader :size

  class Node
    attr_accessor :item, :next

    def initialize(item)
      @item, @next = item, nil
    end
  end

  def initialize
    @first, @last, @size = nil, nil, 0
  end

  def empty?
    @first.nil?
  end


  def enqueue!(item)
    oldlast = @last
    @last = Node.new(item)
    self.empty? ? @first = @last : oldlast.next = @last
    @size += 1
  end

  def dequeue!
    return nil if @first.nil?
    item, @first = @first.item, @first.next
    @last = nil if self.empty?
    @size -= 1
    item
  end

  def to_a
    Array.new(@size) {|idx| self.dequeue! }
  end

end