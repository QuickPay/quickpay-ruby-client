require "excon"
require "json"
require "quickpay/api/error"
require "quickpay/api/version"

module QuickPay
  module API
    class Client
      DEFAULT_HEADERS = {
        "User-Agent" => "quickpay-ruby-client, v#{QuickPay::API::VERSION}",
        "Accept-Version" => "v10"
      }.freeze

      def initialize(username: nil, password: nil, base_uri: "https://api.quickpay.net", options: {})
        opts = {
          read_timeout: options.fetch(:read_timeout, 60),
          write_timeout: options.fetch(:write_timeout, 60),
          connect_timeout: options.fetch(:connect_timeout, 60),
          json_opts: options.fetch(:json_opts, nil)
        }

        opts[:username] = Excon::Utils.escape_uri(username) if username
        opts[:password] = Excon::Utils.escape_uri(password) if password

        @connection = Excon.new(base_uri, opts)
      end

      %i[get post patch put delete head].each do |method|
        define_method(method) do |path, **options, &block|
          headers = DEFAULT_HEADERS.merge(options.fetch(:headers, {}))
          body    = begin
            data = options.fetch(:body, "")
            if headers["Content-Type"] == "application/json" && data.instance_of?(Hash)
              data.to_json
            else
              data
            end
          end

          res = @connection.request(
            method: method,
            path: path,
            body: body,
            headers: headers,
            query: options.fetch(:query, {})
          )

          return [res.status, res.body, res.headers] if options.fetch(:raw, false)

          error = QuickPay::API::Error.by_status_code(res.status, res.body, res.headers)
          body  =
            if res.headers["Content-Type"] == "application/json"
              JSON.parse(res.body, options[:json_opts] || @connection.data[:json_opts])
            else
              res.body
            end

          if block
            return block.call(
              res.status, body, res.headers, error
            )
          end

          raise error if error

          body
        end
      end
    end
  end
end
