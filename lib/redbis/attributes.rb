module Redbis
  module Attributes
   
    module ClassMethods
      
      def prepare_attributes(klass)
        klass.cattr_accessor :attributes, :defaults
        klass.attributes = []
        klass.defaults = {}
      end

      def create_attribute(name, args)
        args.stringify_keys!
        self.class_eval do
          attr_accessor name.to_sym
        end
        append_attribute(name)
        merge_defaults({name.to_s => args['default']}) if args['default']
      end

      def append_attribute(name)
        self.attributes << name.to_sym       
      end
      
      def merge_defaults(values={})
        self.defaults = (self.defaults || {}).merge(values)
      end

    end

    def self.included(base)
      base.extend(ClassMethods)
    end
    
    def instance_attributes=(attributes)
      attributes.stringify_keys!
      default = default_attributes
       
      self.class.attributes.each do |attribute|
        value = nil

        if attributes.keys.include? attribute.to_s
          value = attributes[attribute.to_s]
        elsif diff_attributes_keys(default, attributes).include? attribute.to_s
          value = defaults[attribute.to_s]
        end
        self.instance_eval "self.#{attribute.to_s} = value"
      end
    end

    def instance_attributes
      attrs_with_values = {}
      self.class.attributes.each do |attribute|
        attrs_with_values.merge!({attribute => self.send(attribute.to_s)})
      end
      attrs_with_values
    end

    def default_attributes
      self.defaults
    end

    def diff_attributes_keys(default = {}, new = {})
      default.keys - new.keys
    end
  end
end
