require_relative '03_associatable'
require 'byebug'

# Phase IV
module Associatable
  # Remember to go back to 04_associatable to write ::assoc_options

  def has_one_through(name, through_name, source_name)
    define_method(name) do
      through_options = self.class.assoc_options[through_name]

      source_options =
        through_options.model_class.assoc_options[source_name]

      through_id = send(through_options.foreign_key)
      through = through_options.model_class.find(through_id)

      source_id = through.send(source_options.foreign_key)
      result = source_options.model_class.find(source_id)

    end


  end
end
