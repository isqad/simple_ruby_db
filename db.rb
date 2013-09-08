require 'yaml'
require './binary_tree'

class Db

  attr_reader :db, :age_index, :amount_index, :height_index, :weight_index

  FILE_DB = './db/db.yml'
  COUNT_ROWS = 10_000

  def initialize
    @db = begin
      YAML.load(File.read(FILE_DB))
    rescue Errno::ENOENT => e
      self.create
    end
    self.create_indexes
  end

  # Search in db
  # param condition Hash
  # the condition can be a hash whose keys define the selection criteria
  # The key can contain conditions more or less for the search ranges in values
  # An example of the sample on the Range:
  # db.search({"age.gt" => 20, "age.lt" => 25})
  def search(condition={})
    return @db if condition.nil? || !condition.is_a?(Hash) || condition.empty?
    keys = []

    condition = parse condition

    condition.each do |key, value|
      if value.is_a?(Array)
        self.send("#{key}_index".to_sym).range(value[0], value[1]).each do |v|
          keys |= v
        end
      else
        keys |= self.send("#{key}_index".to_sym).get(value)
      end
    end
    result = Hash.new
    keys.each{|idx| result[idx] = @db[idx] }
    result
  end

  def valid_criteria(condition)
    keys = %w(age amount height weight)

    valid_keys = keys + keys.map{|v| v + '.gt'} + keys.map{|v| v + '.lt' }

    condition = condition.keys.uniq & valid_keys
    keys.each do |k|
      condition.reject!{|v| v == k && (condition.include?("#{k}.lt") || condition.include?("#{k}.gt"))  }
    end
    condition
  end

  def parse(condition)
    condition = condition.each_with_object({}){|(k,v), h| h[k.to_s] = v}

    criteria = valid_criteria(condition)

    ranges = {}

    criteria.each do |v|
      cond = v.split('.')
      key = cond[0].to_sym
      ranges[key] = [nil, nil] unless ranges.has_key?(key)
      if cond[1] == 'gt'
        ranges[key][0] = condition[v]
      elsif cond[1] == 'lt'
        ranges[key][1] = condition[v]
      end
    end
    ranges.each_with_object({}){|(k,v), h| h[k] = (v == [nil, nil] ? condition[k.to_s] : v) }
  end

  def create
    r = Random.new

    @db = Array.new(COUNT_ROWS) do |idx|
      {
        :age => r.rand(0..100),
        :amount => r.rand(0.0..1_000_000.0),
        :height => r.rand(0..200),
        :weight => r.rand(0..200)
      }
    end

    File.write(FILE_DB, @db.to_yaml)

    @db
  end

  def create_indexes
    @age_index = BinaryTree.new
    @amount_index = BinaryTree.new
    @height_index = BinaryTree.new
    @weight_index = BinaryTree.new

    @db.each_with_index do |row, i|
      @age_index.put!(row[:age], i)
      @amount_index.put!(row[:amount], i)
      @height_index.put!(row[:height], i)
      @weight_index.put!(row[:weight], i)
    end
  end
end
