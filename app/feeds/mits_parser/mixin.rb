# Here we define utility methods to be mixed into classes in the MitsParser module.
# ---
# Usage:
#   class MitsParser::Property
#     include MitsParser::Mixin
#     ...
#   end
module MitsParser::Mixin

  def self.included base
    base.send :include, InstanceMethods
    base.extend ClassMethods
  end


  TRUE_FALSE_REGEX = /^(true|false|t|f|yes|no|y|n|1|0)$/i
  TRUE_REGEX       = /^(true|t|yes|y|1)$/i

  BOOLEAN_STRING_MAP =
    {
      ""      => nil,
      "f"     => false,
      "F"     => false,
      "false" => false,
      "False" => false,
      "0"     => false,
      "t"     => true,
      "T"     => true,
      "true"  => true,
      "True"  => true,
      "1"     => true,
    }


  #========================================================
  # Instance methods
  #========================================================


  module InstanceMethods

    def dig_or_default(hash, default_value, *paths)
      paths.each do |paths|
        result = self.dig(hash, paths)
        result = result.compact.flatten if result.is_a?(Array)
        next if result.blank?
        return result
      end
      default_value
    end

    # Retrieves the value object of the specified paths. If the specified path
    # contains an array, travarses and search on all the elements.
    # - param data - hash, array or string
    # - param paths - unlimited arrays of strings ["", ""], ["", ""]
    # - return a hash of path => value
    def dig_all(hash, *paths)
      raise ArgumentError.new("paths must be an array") unless paths.is_a?(Array)

      {}.tap do |results|
        paths.each do |paths|
          result = self.dig(hash, paths)
          result = result.compact.flatten if result.is_a?(Array)
          next if result.blank?
          results[paths.join.underscore.to_sym] = result
        end
      end
    end

    # Retrieves the value object of the specified path. If the specified path
    # contains an array, travarses and search on all the elements.
    # - param data - a hash, array or string
    # - param path - an array of ["path", "to", "node"]
    # - return value if any datatype
    # ---
    # NOTE: This method does something similar to what Hash#dig does but
    # the difference is this method proceed recursively even if the path contains
    # arrays.
    def dig(data, path)
      raise ArgumentError.new("path must be an array") unless path.is_a?(Array)

      return data if path.empty?  # Base case

      # Pop a node from the path list.
      current_node, remaining_path = path[0], path[1..-1]

      # Continue the process according to the current condition.
      if current_node == "Array"
        # Recurse on all the nodes in the array.
        data.map { |h| self.dig(h, remaining_path) }
      elsif data.is_a?(Hash) && (new_data = data[current_node])
        # Recurse on the remaining path.
        self.dig(new_data, remaining_path)
      else
        []
      end
    end

    def deep_find_all(data, keys)
      data.extend Hashie::Extensions::DeepFind

      keys.reduce(Array.new) do |results, key|
        results << data.deep_find_all(key)
      end.flatten.compact.uniq
    end

    def deep_find_first(data, keys)
      deep_find_all(data, keys).first
    end

    def safe_integer(value, cutoff = 0)
      return if value.nil?
      value = value.to_i if value.is_a?(String)
      (value <= cutoff) ? nil : value
    end

    # Try freaking everything...ensures we pick up some weird keys in Floorplan
    def brute_force_keys(key)
      [key.singularize, key.pluralize].map do |r|
        [r.titleize, r.camelize, r.underscore, r.tableize, r.humanize]
      end.flatten.uniq
    end

    def minmax_from_hash_array(data)
      data.map do |hash|
        hash.to_a if hash.is_a?(Hash)
      end.flatten.select { |el| el.to_s[/\d+/] }.map(&:to_i).minmax
    end

    def minmax_from_hash(hash)
      hash.to_a.flatten.select { |el| el.to_s[/\d+/] }.map(&:to_i).minmax
    end

    # Takes a string and returns an integer if any numeric value found.
    # Returns 0 if there is no numeric value found in the string.
    def s_to_i(string)
      return nil if string.nil?
      return string.to_i if string.is_a?(Fixnum)

      # To deal with "$150.00"
      string.gsub(/[^0-9\.]/,'').to_f.to_i
    end

    # Extract URL strings from a hash array.
    def urls_from_hash_array(hash_array)
      require "uri"
      hash_array.map { |hash| hash.to_s[URI.regexp] }
    end

    # Transforms numeric string into integers within a hash.
    def transform_boolean_string_values_of_hash(hash)
      raise ArgumentError.new("argument must be a hash") unless hash.is_a?(Hash)
      transform_hash(hash, { values: BOOLEAN_STRING_MAP })
    end

    # Transforms numeric string into integers within a hash.
    def transform_numeric_string_values_of_hash(hash)
      raise ArgumentError.new("argument must be a hash") unless hash.is_a?(Hash)
      hash.keys.each do |key|
        if (true if Float(hash[key]) rescue false )
          hash[key] = s_to_i(hash[key])
        end
      end
      hash
    end

    # Takes a hash, transform_keys, transformed_values.
    # Returns a hash that were transformed as specified, {} if hash is invalid.
    # ---
    # Usage:
    #   MitsParser.transform_hash(formatted_hash, {
    #     keys:   { "hello" => "world" }
    #     values: { "N/A" => "" }
    #   })
    def transform_hash(hash, transform={})
      return {} unless hash.is_a?(Hash)
      return hash unless transform[:keys] || transform[:values]

      {}.tap do |new_hash|
        hash.each do |key, value|
          transformed_key, transformed_value = key, value

          if transform[:keys]
            transformed_key = transform[:keys].key?(key) ? transform[:keys][key] : key
            if transformed_key && transformed_key.is_a?(String)
              transformed_key = transformed_key.underscore.to_sym
            end
          end

          if transform[:values]
            transformed_value = transform[:values].key?(value) ? transform[:values][value] : value
          end

          next if [transformed_key, transformed_value].any?(&:nil?)
          next if transformed_value.is_a?(Hash) && transformed_value.blank?
          next if transformed_value.is_a?(Array) && transformed_value.blank?

          new_hash[transformed_key] = transformed_value
        end
      end
    end

    # def transform_hash(hash, transform = {})
    #   new_hash = {}.tap do |new_hash|
    #     hash.each do |key, value|
    #       transformed_key   = transform_key(key, transform[:keys])
    #       transformed_value = transform_value(value, transform[:values])
    #
    #       # Reject transformed_keys and transformed_values that are nil
    #       next if [transformed_key, transformed_value].any?(&:nil?)
    #       new_hash[transformed_key] = transformed_value
    #     end
    #   end
    # end
    #
    #
    # def transform_key(key, map)
    #   # Explicit check to ensure nil / false mappings propogate
    #   key = map.key?(key) ? map[key] : key if map
    #   # Convert strings to underscored symbols
    #   key.is_a?(String) ? key.underscore.to_sym : key
    # end
    #
    #
    # def transform_value(value, map)
    #   # Explicit check to ensure nil / false mappings propogate
    #   value = map.value?(value) ? map[value] : value if map
    #   # Convert empty hashes and arrays to nil
    #   [{}, []].include?(value) ? nil : value
    # end

    def transform_day_string(day)
      {
        "su" => :sunday,
        "m"  => :monday,
        "t"  => :tuesday,
        "w"  => :wednesday,
        "th" => :thursday,
        "f"  => :friday,
        "sa" => :saturday,
        "sunday"    => :sunday,
        "monday"    => :monday,
        "tuesday"   => :tuesday,
        "wednesday" => :wednesday,
        "thursday"  => :thursday,
        "friday"    => :friday,
        "saturday"  => :saturday
      }[day]
    end

    def transform_boolean_string(string)
      {
        ""      => nil,
        "f"     => false,
        "F"     => false,
        "false" => false,
        "False" => false,
        "0"     => false,
        "t"     => true,
        "T"     => true,
        "true"  => true,
        "True"  => true,
        "1"     => true,
      }[string]
    end

    def attributes
      instance_variables.map do |var|
        [var[1..-1], instance_variable_get(var)]
      end.to_h.delete_if { |k, _|  k = "@property_hash" }
    end
  end


  #========================================================
  # Class methods
  #========================================================


  module ClassMethods
  end

end
