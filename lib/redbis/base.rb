module Redbis
  
  class Base
    include Attributes
    include Callbacks

    def self.inherited(child)
      self.prepare_attributes(child)
      child.cattr_accessor :table_key
      child.table_key = child.to_s.downcase.pluralize
    end 
    
    def initialize(attributes = {})
      run_callback(:before_create)
      self.instance_attributes = attributes
      run_callback(:after_create)
    end

    class << self
      
      def use_key(name)
        self.table_key = name.to_s.downcase
      end

      def field(name, args = {})
        create_attribute(name, args)
      end
    
    end
  end

end
