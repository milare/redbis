module Redbis
  module Callbacks

    CALLBACKS = [:before_create, :after_create]

    def self.included(base)
      base.extend(ClassMethods)
    end

    def run_callback(kind)
      begin
        methods = instance_eval "#{self.class}.#{kind}_callback_methods"
        methods.each do |method|
          self.send(method.to_s)
        end
      rescue
      end
    end
    
    module ClassMethods
      
      CALLBACKS.each do |callback|
      self.class_eval <<-CALLBACK, __FILE__, __LINE__ + 1
          def #{callback}(*methods)
            methods ||= []
            cattr_accessor :#{callback}_callback_methods
            self.#{callback}_callback_methods = methods
          end
      CALLBACK
      end
    end
  end
end
