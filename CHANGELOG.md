# Changelog

## 3.0.0

### Breaking changes

The interface has been changed to (https://github.com/QuickPay/quickpay-ruby-client/pull/36):

- always return an array for all request types (incl. when adding the `raw: true` option)
- order the array as `[body, status, headers]` (was `[status, body, headers]`
- always parse JSON body unless the `raw: true` option is set

The reasoning is that we almost always want the `body`, but in some case we want `status`and/or `headers` as well. Before we had to set the `raw: true` option, but then a JSON body would not be parsed.

```ruby
body, = client.get("/ping")
body, status, = client.get("/ping")
body, status, headers = client.get("/ping")
body, status, headers = client.get("/ping", raw: true)
```

### New features

#### Blocks

You can now pass a block to a request (https://github.com/QuickPay/quickpay-ruby-client/pull/32):

```ruby
msg = client.get("/ping") do |body, status, headers, error|
  case error
  when nil
    body["msg"]
  when QuickPay::API::NotFound
    nil
  else
    raise error
  end
end
```

#### Verbose errors

The `QuickPay::API::Error` now includes the request that yielded the error - for example:

```
#<QuickPay::API::Error::NotFound:
  status=404,
  body="404 Not Found",
  headers={"Server"=>"nginx", "Date"=>"Sun, 21 Mar 2021 09:10:12 GMT", "Connection"=>"keep-alive", "X-Cascade"=>"pass", "Vary"=>"Origin"}
  request=#<struct QuickPay::API::Client::Request
    method=:post,
    path="/payments",
    body="{\"currency\":\"DKK\",\"order_id\":\"1212\"}",
    headers={"User-Agent"=>"quickpay-ruby-client, v2.0.3", "Accept-Version"=>"v10", "Content-Type"=>"application/json"},
    query=nil>>
```

## v2.0.3

* Add the possibility of settins options for JSON parser

## v2.0.2

* Update excon dependency for CVE-2019-16779 (prognostikos)

## v2.0.1

* More verbose `#to_s`/`#inspect` on errors

## v2.0.0

* This is a total rewrite and while the code is cleaner, simpler and faster, it does present some **breaking changes compared to v1.X.X**:
    * The client now accepts arguements `username` instead of `password` and `api_key` has been removed. To authenticate with an API key, simply set `password: <key>` and omit username.
    * The request methods now accepts request body as an named option (`client.post(<endpoint>, body: { amount: 100 })`) rather than a hash of body params (`client.post(<endpoint>, amount: 100)`).
* Replace the following dependencies - which reduces the total number of dependencies to 5 (was 27):
    * HTTParty => Excon (https://github.com/excon/excon) - which luckily means no more partying hard.
    * Rspec => Minitest

## v1.2.0 (2016-10-25)

* Can now HEAD (https://github.com/QuickPay/quickpay-ruby-client/pull/21)

## v1.1.0 (2016-01-11)

* Send options to the underlaying HTTParty (https://github.com/QuickPay/quickpay-ruby-client/pull/16)
* Be able to upload files (https://github.com/QuickPay/quickpay-ruby-client/pull/17<Paste>)
