require 'yaml'

class Db

  FILE_DB = './db/db.yml'
  COUNT_ROWS = 10_000

  def initialize
    @db = begin
      YAML.load(File.read(FILE_DB))
    rescue Errno::ENOENT => e
      self.create
    end
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
end