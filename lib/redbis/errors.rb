module Redbis

  module Errors
    def add_error(error)
      begin 
        self.errors = self.errors + [error]
      rescue NoMethodError 
        self.append_instance_attribute(:errors)
        self.errors = [error]
      end
    end

    def has_errors?
      begin
        instance_errors = self.errors
      rescue NoMethodError
        return false
      end
      instance_errors.size > 0 ? true : false
    end
  end

  module Validations
    class EmptyFieldError < Exception; end
    class NilFieldError < Exception; end
    class ValidationNotFound < Exception; end
  end


end


