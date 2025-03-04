require "json"
require "net/http"
require "quickpay/api/error"
require "quickpay/api/version"

module QuickPay
  module API
    class Client
      DEFAULT_HEADERS = {
        "User-Agent" => "quickpay-ruby-client, v#{QuickPay::API::VERSION}",
        "Accept-Version" => "v10"
      }.freeze

      CONTENT_TYPE_JSON_REGEX = %r{application/.*json}.freeze

      Request = Struct.new(:method, :path, :body, :headers, :query) # rubocop:disable Lint/StructNewOverride

      def initialize(username: nil, password: nil, base_uri: "https://api.quickpay.net", options: {})
        @read_timeout = options.fetch(:read_timeout, 60)
        @write_timeout = options.fetch(:write_timeout, 60)
        @connect_timeout = options.fetch(:connect_timeout, 60)
        @json_opts = options.fetch(:json_opts, nil)

        uri_parser = URI::Parser.new
        @username = uri_parser.escape(username) if username
        @password = uri_parser.escape(password) if password
        @base_uri = base_uri
      end

      HTTPS = "https".freeze

      [
        Net::HTTP::Get,
        Net::HTTP::Post,
        Net::HTTP::Patch,
        Net::HTTP::Put,
        Net::HTTP::Delete,
        Net::HTTP::Head
      ].each do |method_class|
        method = method_class.to_s.split("::").last.downcase
        define_method(method) do |path, **options, &block|
          headers = DEFAULT_HEADERS.merge(options.fetch(:headers, {}))
          body    = begin
            data = options.fetch(:body, "")
            if CONTENT_TYPE_JSON_REGEX.match(headers["Content-Type"]) && data.instance_of?(Hash)
              data.to_json
            else
              data
            end
          end

          req = Request.new(
            method.to_sym,
            path,
            scrub_body(body.dup, headers["Content-Type"]),
            headers,
            options[:query]
          ).freeze

          uri = URI(@base_uri)
          uri.path << req.path
          if (query = req.query) && query.any?
            uri.query = URI.encode_www_form(req.query)
          end
          net_req = method_class.new(uri, req.headers)
          net_req.basic_auth(@username, @password) if @username || @password
          net_req.body = req.body
          res = Net::HTTP.start(
            uri.hostname,
            use_ssl: uri.scheme == HTTPS,
            open_timeout: @connect_timeout,
            read_timeout: @read_timeout,
            write_timeout: @write_timeout
          ) do |http|
            http.request(net_req)
          end
          status_code = res.code.to_i
          body = res.body
          headers = res.each_header.to_h
          error = QuickPay::API::Error.by_status_code(status_code, body, headers, req)

          if !options.fetch(:raw, false) && res["content-type"] =~ CONTENT_TYPE_JSON_REGEX
            body = JSON.parse(body, options[:json_opts] || @json_opts)
          end

          if block
            # Raise error if not specified as fourth block parameter
            raise error if error && block.parameters.size < 4

            block.call(body, status_code, headers, error)
          else
            raise error if error

            [body, status_code, headers]
          end
        end
      end

      private

      def scrub_body(body, content_type)
        return "" if body.to_s.empty?

        if [CONTENT_TYPE_JSON_REGEX, %r{application/x-www-form-urlencoded}].any? { |regex| regex.match(content_type) }
          body
        else
          "<scrubbed for Content-Type #{content_type}>"
        end
      end
    end
  end
end
