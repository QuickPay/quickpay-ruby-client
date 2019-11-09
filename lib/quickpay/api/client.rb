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
          connect_timeout: options.fetch(:connect_timeout, 60)
        }

        opts[:username] = Excon::Utils.escape_uri(username) if username
        opts[:password] = Excon::Utils.escape_uri(password) if password

        @connection = Excon.new(base_uri, opts)
      end

      %i[get post patch put delete head].each do |method|
        define_method(method) do |path, options = {}|
          headers = DEFAULT_HEADERS.merge(options.fetch(:headers, {}))
          body    = begin
            data = options.fetch(:body, "")
            if headers["Content-Type"] == "application/json" && data.instance_of?(Hash)
              data.to_json
            else
              data
            end
          end

          req = {
            method: method,
            path: path,
            body: body,
            headers: headers,
            query: options.fetch(:query, {})
          }

          res = @connection.request(req)

          if options.fetch(:raw, false)
            [res.status, res.body, res.headers]
          else
            if res.status >= 400
              raise QuickPay::API::Error.by_status_code(
                req,
                status: res.status,
                headers: res.headers,
                body: res.body
              )
            end

            res.headers["Content-Type"] == "application/json" ? JSON.parse(res.body) : res.body
          end
        end
      end
    end
  end
end
