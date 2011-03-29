module Redbis
  module Associations

    ASSOCIATIONS = [:has_many, :belongs_to]

    def self.included(base)
      base.extend(ClassMethods)
    end
   
    def set_associations
      self.class.associations.keys.each do |association_key|
        if association_key == :belongs_to
          parameters = self.class.associations[association_key]
          parameters.each do |params|
            singular =  params[:table_key].to_s.singularize
            singular_id = instance_eval "self.#{singular}_id"
            association_instance = singular.titleize.constantize.find(singular_id)
            association_table_key = association_instance.class.table_key
            key = ''
            self.instance_eval <<-ASSOCIATE, __FILE__, __LINE__ + 1
              key = "#{MASTER_KEY}/#{association_table_key}/#{association_instance.id}/#{self.class.table_key}/#{self.id}"
            ASSOCIATE
            self.class.connection.set(key, Marshal.dump(self))
          end
        end
      end
    end


    module ClassMethods
      
      def has_many(association, args={})
        if args[:class_name]
          table_key = args[:class_name].constantize.table_key
        else
          table_key = association
        end
        args.delete(:class_name)
        self.associations[:has_many] ||= []
        self.associations[:has_many] += [{:method_name => association, 
                                          :table_key => table_key,
                                          :other_attributes => args}]

        establish_get_associations
      end
      
      def belongs_to(association, args={})
        if args[:class_name]
          table_key = args[:class_name].constantize.table_key
        else
          table_key = association
        end
        create_attribute "#{table_key.to_s.singularize}_id".to_sym, :default => nil
        args.delete(:class_name)
        self.associations[:belongs_to] ||= []
        self.associations[:belongs_to] += [{:method_name => association, 
                                            :table_key => table_key,
                                            :other_attributes => args}]

        establish_get_associations
      end


      def establish_get_associations
        self.associations.keys.each do |association|
          if ASSOCIATIONS.include? association
            if association == :has_many
              parameters = self.associations[association]
              parameters.each do |params|
                has_many_association_method(params[:method_name], params[:table_key])
              end
            elsif association == :belongs_to
              parameters = self.associations[association]
              parameters.each do |params|
                belongs_to_association_method(params[:method_name], params[:table_key])
              end
            end
          end
        end  
      end

      def belongs_to_association_method(method_name, assoc_table_key)
        assoc_table_key = assoc_table_key.to_s.titleize.constantize.table_key
        class_eval <<-ASSOC_METHOD, __FILE__, __LINE__ + 1
            def #{method_name.to_s}
              instance_id = self.#{method_name.to_s.singularize}_id
              key = "#{MASTER_KEY}/#{assoc_table_key.to_s}/" + instance_id.to_s
              Marshal.load(self.class.connection.get(key))
            end
        ASSOC_METHOD
      end

      def has_many_association_method(method_name, assoc_table_key)
        class_eval <<-ASSOC_METHOD, __FILE__, __LINE__ + 1
            def #{method_name.to_s}
              instance_id = self.id
              str = "#{MASTER_KEY}/#{self.table_key}/" + instance_id.to_s + "/#{method_name.to_s}/*"
              keys = self.class.connection.keys(str)
              contents = []
              keys.each do |key|
                contents << Marshal.load(self.class.connection.get(key))
              end
              contents
            end
        ASSOC_METHOD
      end

    end

  end
end

