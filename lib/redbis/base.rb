module Redbis
  
  class Base
    include Attributes
    include Callbacks
    include Connection
    include Validations

    def self.inherited(child)
      self.prepare_attributes(child)
      child.create_attribute(:id, :default => nil)
      child.cattr_accessor :table_key
      child.table_key = child.to_s.downcase.pluralize
      child.add_errors_attribute
    end 
    
    def initialize(attributes = {})
      run_callback(:before_initialize)
      self.instance_attributes = attributes
      run_callback(:after_initialize)
    end
    
    def save
      run_callback(:before_validation)
      perform_validation
      run_callback(:after_validation)

      run_callback(:before_save)
      if !self.id
        self.set_attribute(:id, Time.now.to_i)
      end

      attributes = Marshal.dump(self)
      self.class.connection.set("#{self.table_key}/#{self.id}", attributes)
      run_callback(:after_save)
    end

    class << self
      
      def use_key(name)
        self.table_key = name.to_s.downcase
      end

      def field(name, args = {})
        create_attribute(name, args)
        create_finder_for(name)
      end

      def create_finder_for(field)
        class_eval <<-FINDER, __FILE__, __LINE__ + 1
          def self.find_by_#{field}(value)
            all.each do |content|
              if content.#{field.to_s} == value
                return content
              end
            end
            nil
          end
        FINDER
      end

      def all
        keys = connection.keys("#{self.table_key}/*")
        contents = []
        keys.each do |key|
          serialized = connection.get(key)
          contents << Marshal.load(serialized)
        end
        contents
      end

      def find(id)
        key = "#{self.table_key}/#{id.to_s}"
        Marshal.load connection.get(key)
      end

    end
  end

end
