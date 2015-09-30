require_relative 'db_connection'
require 'active_support/inflector'

class SQLObject
  def self.columns
    table_info = DBConnection.execute2(<<-SQL)
      SELECT
        *
      FROM
        #{self.table_name}
    SQL
    table_info[0].map(&:to_sym)
  end

  def self.finalize!
    self.columns.each do |col_name|
      define_method("#{col_name}=") do |val|
        attributes[col_name.to_sym] = val
      end

      define_method("#{col_name}") do
        attributes[col_name.to_sym]
      end
    end
  end

  def self.table_name=(table_name)
    @table_name = table_name
  end

  def self.table_name
    @table_name = self.to_s.tableize unless @table_name
    @table_name
  end

  def self.all
    results = DBConnection.execute(<<-SQL)
      SELECT
        #{self.table_name}.*
      FROM
        #{self.table_name}
    SQL
    self.parse_all(results)
  end

  def self.parse_all(results)
    results.map do |obj_hash|
      self.new(obj_hash)
    end
  end

  def self.find(id)
    matches = DBConnection.execute(<<-SQL, id)
      SELECT
        #{self.table_name}.*
      FROM
        #{self.table_name}
      WHERE
        #{self.table_name}.id = ?
    SQL
    parse_all(matches).first
  end

  def initialize(params = {})
    params.each do |attr_name, val|
      raise "unknown attribute '#{attr_name}'" unless self.class.columns.include?(attr_name.to_sym)
      self.send("#{attr_name}=", val)
    end

  end

  def attributes
    @attributes = {} if @attributes.nil?
    @attributes
  end

  def attribute_values
    self.class.columns.map { |col| self.send(col) }
  end

  def insert
    col_names = self.class.columns.drop(1).join(",")
    q_marks = (["?"] * (self.class.columns.length - 1)).join(",")

    DBConnection.execute(<<-SQL, *attribute_values.drop(1))
      INSERT INTO
        #{self.class.table_name} (#{col_names})
      VALUES
        (#{q_marks})
    SQL
    self.id = DBConnection.last_insert_row_id
  end

  def update
    set_line = self.class.columns.join(" = ?,").concat(" = ?")
    DBConnection.execute(<<-SQL, *attribute_values, id)
      UPDATE
        #{self.class.table_name}
      SET
        #{set_line}
      WHERE
        #{self.class.table_name}.id = ?
    SQL

  end

  def save
    id.nil? ? self.insert : self.update
  end
end
