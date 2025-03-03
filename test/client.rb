# Simplecov must be loaded and configured before anything else
require "simplecov"
require "simplecov-console"
SimpleCov.formatters = SimpleCov::Formatter::MultiFormatter.new(
  [SimpleCov::Formatter::Console]
)
SimpleCov.start do
  add_filter "/vendor/"
  minimum_coverage 100
end

require "minitest/autorun"
require "webmock/minitest"
require "quickpay/api/client"

describe QuickPay::API::Client do
  before do
    stub_request(:any, //).to_return(body: "Unknown Stub", status: 500)
  end

  it "set default headers" do
    stub_request(:get, %r{/ping}).to_return { |request| { headers: request.headers, status: 200 } }

    client = QuickPay::API::Client.new
    _, _, headers = *client.get("/ping")

    _(headers["accept-version"]).must_equal "v10"
    _(headers["user-agent"]).must_equal "quickpay-ruby-client, v#{QuickPay::API::VERSION}"
  end

  it "handles authentication" do
    stub_request(:get, %r{/ping}).to_return { |request| { headers: request.headers, status: 200 } }

    client = QuickPay::API::Client.new(password: "secret")
    _, _, headers = *client.get("/ping")

    _(headers["authorization"]).must_equal "Basic OnNlY3JldA=="
  end

  describe "JSON <=> Hash conversion of body" do
    subject { QuickPay::API::Client.new }

    it "returns JSON string if content type is not set" do
      stub_request(:post, %r{/ping}).to_return(
        body: JSON.generate({ "foo" => "bar" }),
        status: 200
      )

      # client return JSON string
      subject.post(
        "/ping",
        body: { "foo" => "bar" },
        headers: { "Content-Type" => "application/json" }
      ).tap do |response,|
        _(JSON.parse(response)).must_equal({ "foo" => "bar" })
      end
    end

    it "returns ruby Hash if content type is set" do
      stub_request(:post, %r{/ping}).to_return do |request|
        { body: request.body, headers: { "Content-Type" => "application/json" }, status: 200 }
      end

      # client returns Ruby Hash with string keys
      subject.post(
        "/ping",
        body: { "foo" => "bar" },
        headers: { "Content-Type" => "application/json" }
      ).tap do |response,|
        _(response).must_equal({ "foo" => "bar" })
      end

      # client returns Ruby Hash with symbol keys
      subject.post(
        "/ping",
        body: { "foo" => "bar" },
        headers: { "Content-Type" => "application/json" },
        json_opts: { symbolize_names: true }
      ).tap do |response,|
        _(response).must_equal({ :foo => "bar" })
      end
    end

    it "returns a ruby Hash if content type is weird application/json" do
      stub_request(:post, %r{/ping}).to_return do |request|
        { body: request.body, headers: { "Content-Type" => "application/json" }, status: 200 }
      end

      # client returns Ruby Hash with string keys
      subject.post(
        "/ping",
        body: { "foo" => "bob" },
        headers: { "Content-Type" => "application/stuff+json" }
      ).tap do |response,|
        _(response).must_equal({ "foo" => "bob" })
      end
    end
  end

  describe "request with block" do
    subject { QuickPay::API::Client.new }

    it "is called for success" do
      stub_request(:get, %r{/ping}).to_return do
        { body: %({"message":"pong"}), headers: { "Content-Type" => "application/json" }, status: 200 }
      end

      called = subject.get("/ping", json_opts: { symbolize_names: true }) do |body, status, headers, error|
        _(body[:message]).must_equal "pong"
        _(status).must_equal 200
        _(headers["content-type"]).must_equal "application/json"
        _(error).must_be :nil?

        true
      end
      _(called).must_equal true
    end

    it "is called for non success with error block param" do
      stub_request(:get, %r{/ping}).to_return(status: 404)

      called = subject.get "/ping", json_opts: { symbolize_names: true } do |_, status, _, error|
        _(status).must_equal 404
        _(error.class).must_equal QuickPay::API::Error::NotFound

        true
      end
      _(called).must_equal true
    end

    it "is not called for non success without error block param" do
      stub_request(:get, %r{/ping}).to_return(status: 404)

      assert_raises QuickPay::API::Error::NotFound do
        subject.get "/ping", json_opts: { symbolize_names: true } do |_, status|
          _(status).must_equal 405
        end
      end
    end
  end

  describe "Error handling" do
    it "raises predefined errors" do
      client = QuickPay::API::Client.new

      [
        [QuickPay::API::Error::BadRequest, 400],
        [QuickPay::API::Error::Unauthorized, 401],
        [QuickPay::API::Error::PaymentRequired, 402],
        [QuickPay::API::Error::Forbidden, 403],
        [QuickPay::API::Error::NotFound, 404],
        [QuickPay::API::Error::MethodNotAllowed, 405],
        [QuickPay::API::Error::NotAcceptable, 406],
        [QuickPay::API::Error::Conflict, 409],
        [QuickPay::API::Error::TooManyRequest, 429],
        [QuickPay::API::Error::InternalServerError, 500],
        [QuickPay::API::Error::BadGateway, 502],
        [QuickPay::API::Error::ServiceUnavailable, 503],
        [QuickPay::API::Error::GatewayTimeout, 504],
        [QuickPay::API::Error, 418]
      ].each do |error, status|
        stub_request(:get, %r{/ping}).to_return(status: status)
        assert_raises error do
          client.get("/ping")
        end
      end
    end

    it "decorates predefined errors" do
      client = QuickPay::API::Client.new

      e = assert_raises QuickPay::API::Error do
        stub_request(:post, %r{/ping}).to_return(status: 409, body: "Conflict", headers: { "Foo" => "bar" })
        client.post(
          "/ping",
          body: "foo=bar&baz=qux",
          headers: { "Content-Type" => "application/x-www-form-urlencoded" }
        )
      end
      _(e.status).must_equal 409
      _(e.body).must_equal "Conflict"
      _(e.headers).must_equal({ "foo" => "bar" })
      _(e.request.method).must_equal :post
      _(e.request.body).must_equal "foo=bar&baz=qux"
      _(e.request.headers["Accept-Version"]).must_equal "v10"
      _(e.request.headers["User-Agent"]).must_equal "quickpay-ruby-client, v#{QuickPay::API::VERSION}"
      _(e.request.query).must_equal(nil)

      e = assert_raises QuickPay::API::Error do
        stub_request(:post, %r{/upload}).to_return(status: 409, body: "Conflict", headers: { "Foo" => "bar" })
        client.post(
          "/upload",
          body: "binary data",
          headers: { "Content-Type" => "image/png" },
          query: { "foo" => "bar" }
        )
      end

      _(e.inspect).must_equal <<~ERR.strip
        #<QuickPay::API::Error::Conflict: status=409, body="Conflict", headers={"foo"=>"bar"} \
        request=#<struct QuickPay::API::Client::Request method=:post, path="/upload", \
        body="<scrubbed for Content-Type image/png>", \
        headers={"User-Agent"=>"quickpay-ruby-client, v#{QuickPay::API::VERSION}", \
        "Accept-Version"=>"v10", "Content-Type"=>"image/png"}, query={"foo"=>"bar"}>>
      ERR
    end
  end
end
