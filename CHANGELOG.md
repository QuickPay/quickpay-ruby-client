# Changelog

## master

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
