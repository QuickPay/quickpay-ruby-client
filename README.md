quickpay-ruby-client
======================
[![Build Status](https://travis-ci.org/QuickPay/quickpay-ruby-client.svg)](https://travis-ci.org/QuickPay/quickpay-ruby-client)

`quickpay-ruby-client` is a official client for [QuickPay API](http://tech.quickpay.net/api). The Quickpay API enables you to accept payments in a secure and reliable manner. This gem currently support QuickPay `v10` api.

## Installation

Add to your Gemfile
  
    $ gem 'quickpay-ruby-client'

or install from Rubygems:
  
    $ gem install quickpay-ruby-client
  
It is currently tested with Ruby ( >= 2.1.x)

* MRI
* Rubinius (2.0)

## Usage

Before doing anything you should register yourself with QuickPay and get access credentials. If you haven't please [click](https://quickpay.net/) here to apply.

### Create a new client

First you should create a client instance that is anonymous or authorized with `api_key` or login credentials provided by QuickPay. 

To initialise an anonymous client:

```
require 'quickpay'
client = Quickpay::Client.new()
```

To initialise a client with QuickPay Api Key:

```
require 'quickpay'
client = Quickpay::Client.new(":#{ENV['QUICKPAY_API_KEY']")
```

Or you can provide login credentials like:

```
require 'quickpay'
client = Quickpay::Client.new("#{ENV['QUICKPAY_LOGIN']}:#{ENV['QUICKPAY_PASSWORD']")
```


### API Calls

You can afterwards call any method described in QuickPay api with corresponding http method and endpoint. These methods are supported currently: `get`, `post`, `put`, `patch` and `delete`.

```
client.get("/activities").each do |activity|
  puts activity.id
end

```

If you want raw http response, headers Please add `:raw => true` parameter:

```
status, body, headers = client.get("/activities", :raw => true)

if status == 200
  JSON.parse(body).each do |activity|
    puts activity.id
  end
else
  puts "Error: #{body}"
end

```

### Handling API exceptions

By default `(get|post|patch|put|delete)` will return JSON parsed body on success (i.e. `2xx` response code) otherwise it will raise appropriate error. Your code should handle the errors appropriately. Following error codes are supported currently:


Response status |  Error    |
----------------| ----------|
`400` | `Quickpay::BadRequest`
`401` | `Quickpay::Unauthorized` 
`402` | `Quickpay::PaymentRequired`
`403` | `Quickpay::Forbidden`
`404` | `Quickpay::NotFound`
`405` | `Quickpay::MethodNotAllowed`
`406` | `Quickpay::NotAcceptable`
`409` | `Quickpay::Conflict`
`500` | `Quickpay::ServerError`

All exceptions inherits `Quickpay::Error`, so you can listen for any api error like:

```
begin
  client.post("/payments", :currency => :DKK, :order_id => '1212')
  ... 
rescue Quickpay::Error => e
  puts e.body
end
```

You can read more about api responses at [http://tech.quickpay.net/api/](http://tech.quickpay.net/api).
