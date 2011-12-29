require 'digest/sha1'
require 'rack/utils'
require 'rack/cache/key'

class Rack::Cache::MetaStore
  class RedisBase < self
    extend Rack::Utils

    # The Redis::Store object used to communicate with the Redis daemon.
    attr_reader :cache

    def self.resolve(uri)
      new ::Redis::Factory.convert_to_redis_client_options(uri.to_s)
    end
  end

  class Redis < RedisBase
    # The Redis instance used to communicated with the Redis daemon.
    attr_reader :cache

    def initialize(server, options = {})
      options[:redis_server] ||= server
      @cache = ::Redis::Factory.create options
    end

    def read(key)
      cache.get(hexdigest(key)) || []
    end

    def write(key, entries)
      cache.set(hexdigest(key), entries)
    end

    def purge(key)
      cache.del(hexdigest(key))
      nil
    end
  end

  REDIS = Redis
end