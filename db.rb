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
  # db.search({:age => 20..40, :height => 150})
  def search(condition={})
    return @db if condition.nil? || !condition.is_a?(Hash) || condition.empty?
    keys = []

    first_key, first_value = condition.first

    keys = if first_value.is_a?(Range)
      send("#{first_key}_index").range(first_value.begin, first_value.end).reduce(:|)
    else
      send("#{first_key}_index").get(first_value)
    end

    result = Hash.new
    keys.each{|idx| result[idx] = @db[idx] }

    condition.reject{|k,v| k == first_key}.each do |key, value|
      result.select!{|idx, row| value.is_a?(Range) ? value.include?(row[key]) : row[key] == value }
    end

    result
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
