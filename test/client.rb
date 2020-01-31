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

require "excon"
require "json"
require "minitest/autorun"
require "quickpay/api/client"

Excon.defaults[:mock] = true

# Excon expects two hashes
# rubocop:disable Style/BracesAroundHashParameters

describe QuickPay::API::Client do
  before do
    Excon.stub({}, { body: "Uknown Stub", status: 500 })
  end

  after do
    Excon.stubs.clear
  end

  it "set default headers" do
    Excon.stub(
      { path: "/ping" },
      lambda do |request_params|
        {
          headers: request_params[:headers],
          status: 200
        }
      end
    )

    client = QuickPay::API::Client.new
    _, _, headers = *client.get("/ping", raw: true)

    headers["Accept-Version"].must_equal "v10"
    headers["User-Agent"].must_equal "quickpay-ruby-client, v#{QuickPay::API::VERSION}"
  end

  it "handles authentication" do
    Excon.stub(
      { path: "/ping" },
      lambda do |request_params|
        {
          headers: request_params[:headers],
          status: 200
        }
      end
    )

    client = QuickPay::API::Client.new(password: "secret")
    _, _, headers = *client.get("/ping", raw: true)

    headers["Authorization"].must_equal "Basic OnNlY3JldA=="
  end

  it "handles convenient JSON <=> Hash conversion of body" do
    client = QuickPay::API::Client.new

    Excon.stub(
      { path: "/ping" },
      lambda do |request_params|
        {
          body: request_params[:body],
          status: 200
        }
      end
    )

    # client return JSON string
    client.post(
      "/ping",
      body: { "foo" => "bar" },
      headers: { "Content-Type" => "application/json" }
    ).tap do |response|
      JSON.parse(response).must_equal({ "foo" => "bar" })
    end

    Excon.stub(
      { path: "/ping" },
      lambda do |request_params|
        {
          body: request_params[:body],
          headers: { "Content-Type" => "application/json" },
          status: 200
        }
      end
    )

    # client returns Ruby Hash
    client.post(
      "/ping",
      body: { "foo" => "bar" },
      headers: { "Content-Type" => "application/json" }
    ).tap do |response|
      response.must_equal({ "foo" => "bar" })
    end

    # client returns symbolized Ruby Hash
    client.post(
      "/ping",
      body: { "foo" => "bar" },
      headers: { "Content-Type" => "application/json" },
      json_opts: { symbolize_names: true }
    ).tap do |response|
      response.must_equal({ :foo => "bar" })
    end

    client = QuickPay::API::Client.new(
      password: "secret",
      options: { json_opts: { symbolize_names: true } }
    )

    client.post(
      "/ping",
      body: { "foo" => "bar" },
      headers: { "Content-Type" => "application/json" }
    ).tap do |response|
      response.must_equal({ :foo => "bar" })
    end
  end

  it "raises predefined errors" do
    client = QuickPay::API::Client.new

    assert_raises QuickPay::API::Error::BadRequest do
      Excon.stub({ path: "/ping" }, { status: 400 })
      client.get("/ping")
    end

    assert_raises QuickPay::API::Error::Unauthorized do
      Excon.stub({ path: "/ping" }, { status: 401 })
      client.get("/ping")
    end

    assert_raises QuickPay::API::Error::PaymentRequired do
      Excon.stub({ path: "/ping" }, { status: 402 })
      client.get("/ping")
    end

    assert_raises QuickPay::API::Error::Forbidden do
      Excon.stub({ path: "/ping" }, { status: 403 })
      client.get("/ping")
    end

    assert_raises QuickPay::API::Error::NotFound do
      Excon.stub({ path: "/ping" }, { status: 404 })
      client.get("/ping")
    end

    assert_raises QuickPay::API::Error::MethodNotAllowed do
      Excon.stub({ path: "/ping" }, { status: 405 })
      client.get("/ping")
    end

    assert_raises QuickPay::API::Error::NotAcceptable do
      Excon.stub({ path: "/ping" }, { status: 406 })
      client.get("/ping")
    end

    assert_raises QuickPay::API::Error::Conflict do
      Excon.stub({ path: "/ping" }, { status: 409 })
      client.get("/ping")
    end

    assert_raises QuickPay::API::Error::TooManyRequest do
      Excon.stub({ path: "/ping" }, { status: 429 })
      client.get("/ping")
    end

    assert_raises QuickPay::API::Error::InternalServerError do
      Excon.stub({ path: "/ping" }, { status: 500 })
      client.get("/ping")
    end

    assert_raises QuickPay::API::Error::BadGateway do
      Excon.stub({ path: "/ping" }, { status: 502 })
      client.get("/ping")
    end

    assert_raises QuickPay::API::Error::ServiceUnavailable do
      Excon.stub({ path: "/ping" }, { status: 503 })
      client.get("/ping")
    end

    assert_raises QuickPay::API::Error::GatewayTimeout do
      Excon.stub({ path: "/ping" }, { status: 504 })
      client.get("/ping")
    end

    assert_raises QuickPay::API::Error do
      Excon.stub({ path: "/ping" }, { status: 418 })
      client.get("/ping")
    end
  end

  it "decorates predefined errors" do
    client = QuickPay::API::Client.new

    e = assert_raises QuickPay::API::Error do
      Excon.stub({ path: "/ping" }, { status: 409, body: "Conflict", headers: { "Foo" => "bar" } })
      client.get("/ping")
    end
    e.inspect.must_equal %(#<QuickPay::API::Error::Conflict: status=409, body="Conflict", headers={"Foo"=>"bar"}>)
  end
end
# rubocop:enable Style/BracesAroundHashParameters
