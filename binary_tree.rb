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
  def put(key, value)
    @root = node_put(@root, key, value)
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
end