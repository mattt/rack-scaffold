class Rack::CoreData::DataModel
  class Attribute
    attr_reader :name, :type, :identifier, :version_hash_modifier, :default_value

    def initialize(attribute)
      raise ArgumentError unless ::Nokogiri::XML::Element === attribute

      @name = attribute['name']
      @type = attribute['attributeType']
      @identifier = attribute['elementID']
      @version_hash_modifier = attribute['versionHashModifier']
      @default_value = case @type
                       when "Integer 16", "Integer 32", "Integer 64"
                         attribute['defaultValueString'].to_i
                       when "Float", "Decimal"
                         attribute['defaultValueString'].to_f
                       end if attribute['defaultValueString']

      @optional = attribute['optional'] == "YES"
      @transient = attribute['transient'] == "YES"
      @indexed = attribute['indexed'] == "YES"
      @syncable = attribute['syncable'] == "YES"
    end

    def to_s
      @name
    end

    [:optional, :transient, :indexed, :syncable].each do |symbol|
      define_method("#{symbol}?") {!!instance_variable_get(("@#{symbol}").intern)}
    end
  end
end
