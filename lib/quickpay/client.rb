
module QuickPay
  
  class << self
    attr_accessor :base_uri
  end

  class Client  
    attr_accessor :options
    
    def initialize(secret = nil, opts = {})
      opts[:secret]   ||= secret
      opts[:base_uri] ||= (QuickPay.base_uri || QuickPay::BASE_URI)

      @options = opts.dup
    end
    
    def credential
      options[:secret]
    end

    [:get, :post, :patch, :put, :delete].each do |method|
      define_method(method) do |*args|
        Request.new(@options).request(method, *args)
      end
    end
      
  end
end
