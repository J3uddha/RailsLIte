require 'uri'
require 'byebug'

module Phase5
  class Params
    # use your initialize to merge params from
    # 1. query string
    # 2. post body
    # 3. route params
    #
    # You haven't done routing yet; but assume route params will be
    # passed in as a hash to `Params.new` as below:

    def initialize(req, route_params = {})
      @params = route_params
      unless req.query_string.nil?
        q_s = parse_www_encoded_form(req.query_string)
        @params.merge!(q_s)
      end

      unless req.body.nil?
        r_b = parse_www_encoded_form(req.body)
        @params.merge!(r_b)
      end
    end

    def [](key)
      if @params[key.to_s].nil?
        @params[key.to_sym]
      else
        @params[key.to_s]
      end
    end

    # this will be useful if we want to `puts params` in the server log
    def to_s
      @params.to_s
    end

    class AttributeNotFoundError < ArgumentError; end;

    private
    # this should return deeply nested hash
    # argument format
    # user[address][street]=main&user[address][zip]=89436
    # should return
    # { "user" => { "address" => { "street" => "main", "zip" => "89436" } } }
    def parse_www_encoded_form(www_encoded_form)
      levels = {}

      tuples =  URI::decode_www_form(www_encoded_form)
      #tuples #=> [ ["user[address][street]", "main"], ["user[address][zip]", "10012"] ]

      tuples.each do |(www_key, value)|
        level = levels
        keys = parse_key(www_key)
        #p keys
        keys.each do |key|
          if keys.last != key
            level[key] ||= {}
            level = level[key]
          else
            level[key] = value
          end
        #puts level
          #puts levels
        end

      end

      levels
    end

    # this should return an array
    # user[address][street] should return ['user', 'address', 'street']
    def parse_key(key)
      key.split(/\]\[|\[|\]/)
    end
  end
end
