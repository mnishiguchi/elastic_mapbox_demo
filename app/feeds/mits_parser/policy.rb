# Represents the policy related fields of a mits feed.
class MitsParser::Policy
  include MitsParser::Mixin

  def initialize(property_hash)
    @property_hash = property_hash
    set_data
  end

  def formatted_hash
    @formatted_hash ||= begin
      Hash.new.tap do |hash|
        hash.merge!(pet: pet) if pet.present?
        hash.merge!(general: general) if general.present?
      end
    end
  end

  private

    def set_data
      @raw_policy_data = deep_find_first(@property_hash, ["Policy"])
    end

    def format_hash(hash)
      hash = transform_boolean_string_values_of_hash(hash)
      transform_numeric_string_values_of_hash(hash)
    end

    def pet
      @pet ||= begin
        data = deep_find_all(@raw_policy_data, ["Pet"])
        # Content is of array or string types.
        if data.is_a?(Array)
          data.map { |hash| format_hash(hash) }.reject(&:empty?)
        else
          data
        end
      end
    end

    def general
      @general ||= begin
        # String.
        deep_find_first(@raw_policy_data, ["General"])
      end
    end
end
