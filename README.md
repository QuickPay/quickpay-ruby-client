# QuickPay::API::Client

[![Build Status](https://travis-ci.org/QuickPay/quickpay-ruby-client.svg)](https://travis-ci.org/QuickPay/quickpay-ruby-client)

The `quickpay-ruby-client` gem is a official client for [QuickPay API](https://learn.quickpay.net/tech-talk/api). The Quickpay API enables you to accept payments in a secure and reliable manner.

This gem currently support QuickPay `v10` api.

## Installation

Add to your Gemfile

```ruby
gem "quickpay-ruby-client"
```

or install from Rubygems:

```
$ gem install quickpay-ruby-client
```

It is currently tested with Ruby ( >= 2.5.x)

* MRI
* Rubinius (2.0)

## Usage

Before doing anything you should register yourself with QuickPay and get access credentials. If you haven't please [click](https://quickpay.net/) here to apply.

### Create a new API client

First you should create a client instance that is anonymous or authorized with your API key or login credentials provided by QuickPay.

To initialise an anonymous client:

```ruby
require "quickpay/api/client"
client = QuickPay::API::Client.new
```

To initialise a client with QuickPay API Key:

```ruby
require "quickpay/api/client"
client = QuickPay::API::Client.new(password: ENV["QUICKPAY_API_KEY"])
```

Or you can provide login credentials like:

```ruby
require "quickpay/api/client"
client = QuickPay::API::Client.new(username: ENV["QUICKPAY_LOGIN"], password: ENV["QUICKPAY_PASSWORD"])
```

You can also set some connection specific options (default values shown):

```ruby
client = QuickPay::API::Client.new(
  options: {
    read_timeout: 60,
    write_timeout: 60,
    connect_timeout: 60,
    json_opts: { symbolize_names: true }
  }
)
```

### Sending request

You can afterwards call any method described in QuickPay API with corresponding http method and endpoint. These methods are supported currently: `get`, `post`, `put`, `patch`, `delete` and `head`.

```ruby
client.get("/activity").each do |activity|
  puts activity["id"]
end
```

Beyond the endpoint, the client accepts the following options (default values shown):

  * `body: ""`
  * `headers: {}`
  * `query: {}`
  * `raw: false`
  * `json_opts: nil`

```ruby
response = client.post(
  "/payments/1/capture",
  body: { amount: 100 }.to_json,
  headers: { "Content-Type" => "application/json" },
  query: { "synchronized" => "" },
  raw: false,
  json_opts: { symbolize_names: true }
)

```

If you want raw http response, headers Please add `:raw => true` parameter:

```ruby
status, body, headers = client.get("/activity", raw: true)

if status == 200
  JSON.parse(body).each do |activity|
    puts activity["id"]
  end
else
  # do something else
end

```

### Handling API exceptions

By default `(get|post|patch|put|delete)` will return JSON parsed body on success (i.e. `2xx` response code) otherwise it will raise appropriate error. Your code should handle the errors appropriately. Following error codes are supported currently:


Response status |  Error    |
----------------| ----------|
`400` | `QuickPay::API::BadRequest`
`401` | `QuickPay::API::Unauthorized`
`402` | `QuickPay::API::PaymentRequired`
`403` | `QuickPay::API::Forbidden`
`404` | `QuickPay::API::NotFound`
`405` | `QuickPay::API::MethodNotAllowed`
`406` | `QuickPay::API::NotAcceptable`
`409` | `QuickPay::API::Conflict`
`500` | `QuickPay::API::ServerError`
`502` | `QuickPay::API::BadGateway`
`503` | `QuickPay::API::ServiceUnavailable`
`504` | `QuickPay::API::GatewayTimeout`

All exceptions inherits `QuickPay::API::Error`, so you can listen for any api error like:

```ruby
begin
  client.post("/payments", body: { currency: "DKK", order_id: "1212" })
rescue QuickPay::API::Error => e
  puts e.body
end
```

You can read more about QuickPay API responses at [https://learn.quickpay.net/tech-talk/api](https://learn.quickpay.net/tech-talk/api).

### Using block form

Sometimes when you want to look at status or headers `raw` isn't the best option,
since it also prevents for example the automatic parsing of a JSON body.

In this case it is possible to call `(get|post|patch|put|delete)` with a block.

In this mode, the block is called with status, body and headers of the request,
while also automatically parsing the body as JSON if the content-type header is present.

The return value when used in this form is the return value of the block

```ruby
payments = client.get("/payments/") do |status, body, headers|
  case status
  when 403
    []
  when 200
    body
  end
end
```

It is also possible to give the block a 4th parameter to
catch the error that _would_ have been raised if no block was given.

This parameter is nil when the response is a success

```ruby
payment = client.get("/payments/#{payment_id}") do |status, body, headers, error|
  break nil if status == 404

  if error
    raise error
  else
    body
  end
end
```

If you don't care about all of the fields `status`, `body`, `headers` and `error`
you can just get the specific fields you care about by using named parameters

```ruby
payments = client.get("/payments/#{payment_id}") do |body:, error:|
  case error
  when nil
    body
  when QuickPay::API::NotFound
    nil
  else
    raise error
  end
end
```

## Contributions

To contribute:

1. Write a test that fails
2. Fix test by adding/changing code
3. Add feature or bugfix to changelog in the "Unreleased" section
4. Submit a pull request
5. World is now a better place! :)

### Running the specs

```
$ bundle exec rake test
```
