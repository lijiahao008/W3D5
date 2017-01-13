require_relative 'db_connection'
require 'active_support/inflector'
require 'byebug'
# NB: the attr_accessor we wrote in phase 0 is NOT used in the rest
# of this project. It was only a warm up.

class SQLObject

  def self.columns
    @columns ||= DBConnection.execute2(<<-SQL).first.map { |el| el.to_sym }
      SELECT
        *
      FROM
        #{self.table_name}
    SQL
  end

  def self.finalize!
    self.columns.each do |column|
      define_method(column) {
        attributes[column]
      }
      define_method("#{column.to_s}=") do |val|
        attributes[column] = val
      end
    end
  end

  def self.table_name=(table_name)
    @table_name = table_name
    # ...
  end

  def self.table_name
    self.to_s.downcase + 's'
    # ...
  end

  def self.all
    results = DBConnection.execute(<<-SQL)
    SELECT
      *
    FROM
      #{self.table_name}
    SQL
    # debugger
    self.parse_all(results)

    # ...
  end

  def self.parse_all(results)
    result = []
    results.each do |options_hash|
      new_options = {}
      options_hash.each do |attr_name, val|
         new_options[attr_name.to_sym] = val
      end
      result << self.new(new_options)
    end
    result
    # ...
  end

  def self.find(id)
    result = DBConnection.execute(<<-SQL, id)
    SELECT
      *
    FROM
      #{self.table_name}
    WHERE
      id = ?
    SQL
    parse_all(result).first
    # ...
  end

  def initialize(params = {})
    params.each do |attr_name, val|

      unless self.class.columns.include?(attr_name)
        raise "unknown attribute '#{attr_name}'"
      end
      send("#{attr_name}=".to_sym, val)
    end
    # ...
  end

  def attributes
    @attributes ||= {}

    # ...
  end

  def attribute_values
    self.class.columns.map { |column| send("#{column}") }
    # ...
  end

  def insert
    columns = self.class.columns.map(&:to_s)
    col_names = columns.join(",")
    question_marks = (["?"] * columns.length).join(",")

    DBConnection.execute(<<-SQL, *attribute_values)
    INSERT INTO
      #{self.class.table_name} (#{col_names})
    VALUES
      (#{question_marks})
    SQL
    send(:id=, DBConnection.last_insert_row_id)
    # debugger
    # ...
  end

  def update
    set_line = self.class.columns.map{|column| "#{column} = ?"}.join(",")

    DBConnection.execute(<<-SQL, *attribute_values, self.id)
    UPDATE
      #{self.class.table_name}
    SET
      #{set_line}
    WHERE
      id = ?
    SQL

    # ...
  end

  def save
    if self.class.find(self.id).nil?
      self.insert
    else
      self.update
    end
    # ...
  end
end
