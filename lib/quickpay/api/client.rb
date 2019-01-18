require "excon"
require "json"

module QuickPay
  module API
    class Error < StandardError
      class BadRequest < Error; end
      class Unauthorized < Error; end
      class PaymentRequired < Error; end
      class Forbidden < Error; end
      class NotFound < Error; end
      class MethodNotAllowed < Error; end
      class NotAcceptable < Error; end
      class Conflict < Error; end
      class TooManyRequest < Error; end
      class InternalServerError < Error; end
      class BadGateway < Error; end
      class ServiceUnavailable < Error; end
      class GatewayTimeout < Error; end

      CLASS_MAP = {
        400 => "BadRequest",
        401 => "Unauthorized",
        402 => "PaymentRequired",
        403 => "Forbidden",
        404 => "NotFound",
        405 => "MethodNotAllowed",
        406 => "NotAcceptable",
        409 => "Conflict",
        429 => "TooManyRequest",
        500 => "InternalServerError",
        502 => "BadGateway",
        503 => "ServiceUnavailable",
        504 => "GatewayTimeout"
      }.freeze

      attr_reader :status, :body, :headers

      def initialize(status, body, headers)
        @status  = status
        @body    = body
        @headers = headers
      end

      def self.by_status_code(status, body, headers)
        if CLASS_MAP[status]
          klass = QuickPay::API::Error.const_get(CLASS_MAP[status])
          fail klass.new(status, body, headers)
        else
          fail QuickPay::API::Error.new(status, body, headers)
        end
      end
    end

    class Client
      APP_VERSION = "2.0.0".freeze
      API_VERSION = "v10".freeze
      DEFAULT_HEADERS = {
        "User-Agent"     => "quickpay-ruby-client, v#{APP_VERSION}",
        "Accept-Version" => API_VERSION
      }.freeze

      def initialize(username: nil, password: nil, base_uri: "https://api.quickpay.net", options: {})
        opts = {
          read_timeout: options.fetch(:read_timeout, 60),
          write_timeout: options.fetch(:write_timeout, 60),
          connect_timeout: options.fetch(:connect_timeout, 60),
        }

        opts[:username] = Excon::Utils.escape_uri(username) if username
        opts[:password] = Excon::Utils.escape_uri(password) if password

        @connection = Excon.new(base_uri, opts)
      end

      [:get, :post, :patch, :put, :delete, :head].each do |method|
        define_method(method) do |path, options = {}|
          headers = DEFAULT_HEADERS.merge(options.fetch(:headers, {}))
          body    = options.fetch(:body, "").yield_self do |data|
            if headers["Content-Type"] == "application/json" && data.instance_of?(Hash)
              data.to_json 
            else
              data
            end
          end

          res = @connection.__send__(
            method,
            path: path,
            body: body,
            headers: headers,
            query: options.fetch(:query, {})
          )

          if options.fetch(:raw, false)
            [res.status, res.body, res.headers]
          else
            if res.status >= 400
              raise QuickPay::API::Error.by_status_code(res.status, res.body, res.headers)
            end

            res.headers["Content-Type"] == "application/json" ? JSON.parse(res.body) : res.body
          end
        end
      end
    end
  end
end
