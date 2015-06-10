
module QuickPay
  class Client  
    attr_accessor :options
    
    def initialize(*args)
      if args.length > 1
        @options = args.dup
      else
        @options = { secret: args[0] }
      end
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
