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

### Create a new API client

First you should create a client instance that is anonymous or authorized with `api_key` or login credentials provided by QuickPay. 

To initialise an anonymous client:

```
require 'quickpay/api/client'
client = QuickPay::API::Client.new
```

To initialise a client with QuickPay Api Key:

```
require 'quickpay/api/client'
client = QuickPay::API::Client.new(api_key: ENV['QUICKPAY_API_KEY'])
```

Or you can provide login credentials like:

```
require 'quickpay/api/client'
client = QuickPay::API::Client.new(email: ENV['QUICKPAY_LOGIN'], password: ENV['QUICKPAY_PASSWORD'])
```

To pass request specific headers:

```
client = Quickpay::API::Client.new({ email: ENV['QUICKPAY_LOGIN'], password: ENV['QUICKPAY_PASSWORD'] }, 
                                   :headers => { 'QuickPay-Callback-URL' => 'https://webshop.com' }) 
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
`400` | `QuickPay::API::BadRequest`
`401` | `QuickPay::API::Unauthorized` 
`402` | `QuickPay::API::PaymentRequired`
`403` | `QuickPay::API::Forbidden`
`404` | `QuickPay::API::NotFound`
`405` | `QuickPay::API::MethodNotAllowed`
`406` | `QuickPay::API::NotAcceptable`
`409` | `QuickPay::API::Conflict`
`500` | `QuickPay::API::ServerError`

All exceptions inherits `QuickPay::API::Error`, so you can listen for any api error like:

```
begin
  client.post("/payments", :currency => :DKK, :order_id => '1212')
  ... 
rescue QuickPay::API::Error => e
  puts e.body
end
```

You can read more about api responses at [http://tech.quickpay.net/api/](http://tech.quickpay.net/api).
