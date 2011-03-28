module Redbis
  
  class Base
    include Errors
    include Attributes
    include Callbacks
    include Connection
    include Validations
    include Finders

    def self.inherited(child)
      self.prepare_attributes(child)
      child.create_attribute(:id, :default => nil)
      child.cattr_accessor :table_key
      child.table_key = child.to_s.downcase.pluralize
    end 
    
    def initialize(attributes = {})
      run_callback(:before_initialize)
      self.instance_attributes = attributes
      run_callback(:after_initialize)
    end
    
    def save
      perform_validation
      if !has_errors?

        run_callback(:before_save)
        if !self.id
          self.set_attribute(:id, Time.now.to_i)
        end

        attributes = Marshal.dump(self)
        self.class.connection.set("#{self.table_key}/#{self.id}", attributes)
        run_callback(:after_save)
      end
    end

    class << self
      
      def use_key(name)
        self.table_key = name.to_s.downcase
      end

      def field(name, args = {})
        create_attribute(name, args)
        create_finder_for(name)
      end

    end
  end

end
