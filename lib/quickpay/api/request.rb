
module QuickPay
  module API
    class Request
      include HTTParty

      def initialize (options = {})
        @secret = options[:secret]
        self.class.base_uri(options[:base_uri] || BASE_URI)
      end

      def request method, path, data = {}
        raw = data.delete(:raw)
        req_headers = headers.merge(data.delete(:headers) || {})

        options = case method
                  when :get, :delete
                    { query: data }
                  when :post, :patch, :put
                    { body: data }
                  end || {}
        
        options = options.merge(:headers => headers.merge(req_headers))
        QuickPay.logger.debug { "#{method.to_s.upcase} #{base_uri}#{path} #{options}" }
        create_response(raw, self.class.send(method, path, options))
      end

      def create_response raw, res
        if raw
          [res.code, res.body, res.headers]
        else
          response = res.parsed_response
          raise_error(response, res.code) if res.code >= 400
          response
        end
      end

      def raise_error body, status
        code = API_STATUS_CODES[status].to_s
        args = [code, status, body]

        klass =
          begin
            require "quickpay/api/errors/#{code}"
            class_name = code.split('_').map(&:capitalize).join('')
            QuickPay::API.const_get(class_name)
          rescue LoadError, NameError
            QuickPay::API::Error
          end

        fail klass.new(*args), error_description(body)
      end

      private

      def base_uri
        self.class.default_options[:base_uri]
      end

      def error_description msg
        msg
      end

      def headers
        heads = {
          'User-Agent'     => user_agent,
          'Accept-Version' => "v#{QuickPay::API_VERSION}"
        }
        heads['Authorization'] = "Basic #{authorization}" if @secret != nil
        heads
      end

      def user_agent
        user_agent = "quickpay-ruby-client, v#{QuickPay::VERSION}"
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
end
