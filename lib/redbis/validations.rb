module Redbis
  module Validations

    VALIDATIONS = [:presence]

    class EmptyFieldError < Exception; end
    class NilFieldError < Exception; end
    class ValidationNotFound < Exception; end

    def self.included(base)
      base.extend(ClassMethods)
    end

    def perform_validation
      run_callback(:before_validation)
      begin
        self.class.validations.keys.each do |kind|
          if kind == :presence
            self.class.validations[kind].each do |column|
              value = self.send(column.to_sym)
              raise NilFieldError if !value
              raise EmptyFieldError if value.empty?
            end
          else
          end
        end
      rescue Exception => e
        self.add_error e
        return false
      end
      run_callback(:after_validation)
      self.has_errors?
    end

    module ClassMethods
      
      def validates(kind, *columns)
        if VALIDATIONS.include? kind
          self.validations[kind.to_sym] = columns
        else
          raise ValidationNotFound
        end
      end

      def validations
        @@validations ||= {}
        @@validations
      end
    
      def add_validation(kind, cols)
        @@validations[kind] += cols
      end

    end
  end
end


