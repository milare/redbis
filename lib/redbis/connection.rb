module Redbis
  module Connection
  
    REDIS_HOST = 'localhost'
    REDIS_PORT = 6379

    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods
      def connection
        Redis.new(:host => REDIS_HOST, :port => REDIS_PORT)
      end
    end

  end
end
