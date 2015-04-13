quickpay-ruby-client
======================

`quickpay-ruby-client` is a official client for [QuickPay API](http://tech.quickpay.net/api). The Quickpay API enables you to accept payments in a secure and reliable manner. This gem currently support QuickPay `v10` api.

## Installation

Add to your Gemfile
  
    $ gem 'quickpay-ruby-client'

or install from Rubygems:
  
    $ gem install quickpay-ruby-client
  
It is currently tested with Ruby 1.9

* MPI
* Rubinius

## Usage

Before doing anything you should register yourself with QuickPay and get access credentials. If you haven't please [click](https://quickpay.net/) here to apply.

### Create a new client

First you should create a client instance with `api_key` or login credentials provided by QuickPay. 

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

You can afterwards call any method described in QuickPay api with corresponding http method and endpoint. These methods are supported currently: `get`, `post`, `patch` and `delete`.

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

By default `(get|post|delete|patch)` will return JSON parsed body on success (i.e. non `4xx` response code) otherwise it will raise appropriate error. Your code should handle the errors appropriately. Following error codes are supported currently:


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

You can more about api responses at: [Link](http://tech.quickpay.net/api/)
