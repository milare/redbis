module Redbis
  module Finders

    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods
      
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
