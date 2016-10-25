require 'httmultiparty'

module QuickPay
  module API
    class Request
      include HTTMultiParty

      attr_reader :options, :secret

      def initialize (options = {})
        @options = options.dup
        @secret  = @options.delete(:secret)
        self.class.base_uri(options[:base_uri] || BASE_URI)
      end

      def request method, path, data = {}
        raw = data.delete(:raw)
        req_headers = headers.merge(data.delete(:headers) || {})

        http_options = options.dup
        if data.any? { |_key, value| value.is_a?(File) }
          http_options[:body] = data
          http_options[:detect_mime_type] = true
        else
          case method
          when :get, :delete, :head
            http_options[:query] = data
          when :post, :patch, :put
            http_options[:body] = data.to_json
            req_headers["Content-Type"] = "application/json"
          end
        end

        http_options[:headers] = headers.merge(req_headers)
        QuickPay.logger.debug { "#{method.to_s.upcase} #{base_uri}#{path} #{http_options}" }
        create_response(raw, self.class.send(method, path, http_options))
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
        heads['Authorization'] = "Basic #{authorization}" if secret != nil
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
        Base64.strict_encode64(secret)
      end
    end
  end
end
