require './queue'

class BinaryTree

  attr_reader :root

  class Node
    attr_reader :key
    attr_accessor :left, :right, :value, :count

    def initialize(key, value)
      @key, @value, @count = key, value, 1
    end
  end

  def size
    node_size(@root)
  end

  # получение по ключу
  def get(key)
    node_get(@root, key)
  end

  # вставка
  def put!(key, value)
    @root = node_put(@root, key, value)
  end

  def min
    node_min(@root).key
  end

  def delete!(key)
    @root = delete_node(@root, key)
  end

  def delete_min!
    @root = delete_min_node(@root)
  end

  def keys(lo, hi)
    queue = Queue.new
    keys_node(@root, queue, lo, hi)
    queue.to_a
  end

  def range(lo, hi)
    q = keys(lo, hi)
    Array.new(q.size){|idx| self.get(q.dequeue!) }
  end

  private
  def node_size(node)
    return 0 if node.nil?
    node.count
  end

  def node_get(node, key)
    return nil if node.nil?
    case key <=> node.key
      when -1
        # поиск в левом поддереве
        node_get(node.left, key)
      when 1
        # в правом
        node_get(node.right, key)
      else
        node.value
    end
  end

  def node_put(node, key, value)
    return Node.new(key, value) if node.nil?
    case key <=> node.key
      when -1
        node.left = node_put(node.left, key, value)
      when 1
        node.right = node_put(node.right, key, value)
      else
        node.value = value
    end
    node.count = node_size(node.left) + node_size(node.right) + 1
    node
  end

  def node_min(node)
    return node if node.left.nil?
    node_min(node.left)
  end

  def delete_min_node(node)
    return node.right if node.left.nil?
    node.left = delete_min_node(node.left)
    node.count = node_size(node.left) + node_size(node.right) + 1
    node
  end

  def delete_node(node, key)
    return nil if node.nil?
    case key <=> node.key
      when -1
        node.left = delete_node(node.left, key)
      when 1
        node.right = delete_node(node.right, key)
      else
        return node.left if node.right.nil?
        return node.right if node.left.nil?
        t = node
        node = self.min(t.right)
        node.right = delete_min_node(t.right)
        node.left = t.left
    end
    node.count = node_size(node.left) + node_size(node.right) + 1
    node
  end

  def keys_node(node, queue, lo, hi)
    return nil if node.nil?
    cmplo = lo <=> node.key
    cmphi = hi <=> node.key
    keys_node(node.left, queue, lo, hi) if cmplo < 0
    queue.enqueue!(node.key) if cmplo <= 0 && cmphi >= 0
    keys_node(node.right, queue, lo, hi) if cmphi > 0
  end
end