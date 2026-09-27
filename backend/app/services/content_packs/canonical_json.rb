require "digest"
require "json"

module ContentPacks
  class CanonicalJson
    def self.dump(value)
      JSON.generate(normalize(value))
    end

    def self.normalize(value)
      case value
      when Hash
        value.to_h.transform_keys(&:to_s).sort.to_h do |key, item|
          [key, normalize(item)]
        end
      when Array
        value.map { |item| normalize(item) }
      else
        value
      end
    end

    private_class_method :normalize
  end
end
