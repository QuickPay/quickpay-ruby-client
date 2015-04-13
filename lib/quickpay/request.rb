
module Quickpay
  class Request
    include HTTParty
    
    def initialize secret
      @secret = secret
      self.class.base_uri(BASE_URI)
    end
    
    def request method, path, data = {}
      raw = data.delete(:raw)
      options = case method
                when :get
                  { query: data }
                when :post, :patch
                  { body: data }
                end || {}
      
      options = options.merge(:headers => headers)
      Quickpay.logger.debug { "#{method.to_s.upcase} #{BASE_URI}#{path} #{options}" }
      create_response(raw, self.class.send(method, path, options))
    end
    
    def create_response raw, res
      response = res.parsed_response      
      if raw
        [res.code, response, res.headers]
      else
        raise_error(response, res.code) if res.code.to_s =~ /4\d\d/
        
        response.kind_of?(String) ? 
          JSON.parse(response) : 
          response
      end
    end
    
    def raise_error body, status
      code = API_STATUS_CODES[status].to_s
      args = [code, status, body]
      
      klass =
        begin
          require "quickpay/errors/#{code}"
          class_name = code.split('_').map(&:capitalize).join('')
          Quickpay.const_get(class_name)
        rescue LoadError, NameError
          Quickpay::Error
        end
        
      fail klass.new(*args), error_description(body)
    end
    
    private
    
      def error_description msg
        msg
      end
      
      
      def headers
        {
          'User-Agent'     => user_agent,
          'Authorization'  => "Basic #{authorization}",
          'Accept-Version' => "v#{Quickpay::API_VERSION}"
        }
      end
      
      def user_agent
        user_agent = "quickpay-ruby-client, v#{Quickpay::VERSION}"
        user_agent += ", #{RUBY_VERSION}, #{RUBY_PLATFORM}, #{RUBY_PATCHLEVEL}"
        if defined?(RUBY_ENGINE)
          user_agent += ", #{RUBY_ENGINE}"
        end
        user_agent  
      end
      
      def authorization
        Base64.strict_encode64(@secret)
      end
      
  end
    
end
