require_relative '02_searchable'
require 'active_support/inflector'

# Phase IIIa
class AssocOptions
  attr_accessor(
    :foreign_key,
    :class_name,
    :primary_key
  )

  def model_class
    self.class_name.constantize
    # ...
  end

  def table_name
    self.class_name.downcase + 's'
    # ...
  end
end

class BelongsToOptions < AssocOptions
  def initialize(name, options = {})
    @foreign_key = "#{name}_id".to_sym
    @primary_key = :id
    @class_name = name.to_s.camelcase
    options.each do |name, val|
      case name
      when :foreign_key
        @foreign_key = val
      when :class_name
        @class_name = val
      when :primary_key
        @primary_key = val
      end
    end

    # ...
  end
end

class HasManyOptions < AssocOptions
  def initialize(name, self_class_name, options = {})
    @foreign_key = (self_class_name.to_s.downcase + "_id").to_sym
    @primary_key = :id
    @class_name = name.to_s.singularize.camelcase
    options.each do |name, val|
      case name
      when :foreign_key
        @foreign_key = val
      when :class_name
        @class_name = val
      when :primary_key
        @primary_key = val
      end
    end
    # ...
  end
end

module Associatable
  # Phase IIIb
  def belongs_to(name, options = {})
    assoc_options[name] = BelongsToOptions.new(name, options)
    define_method("#{name}"){
      fk = self.send(assoc_options[name].foreign_key)
      tc = assoc_options[name].model_class
      tc.where(id: fk).first
    }

    # ...
  end

  def has_many(name, options = {})
    options = HasManyOptions.new(name, self, options)
    define_method("#{name}"){
      tc = options.model_class
      fk = options.foreign_key
      tc.where(fk => id)
    }
    # ...
  end

  def assoc_options
    @assoc_options ||= {}# Wait to implement this in Phase IVa. Modify `belongs_to`, too.
  end
end

class SQLObject
  extend Associatable
  # Mixin Associatable here...
end
