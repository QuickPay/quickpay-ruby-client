
module Quickpay
  class Client  
    attr_accessor :credential
    
    def initialize credential
      @credential = credential
    end
    
    [:get, :post, :patch, :put, :delete].each do |method|
      define_method(method) do |*args|
        Request.new(@credential).request(method, *args)
      end
    end
      
  end
end
