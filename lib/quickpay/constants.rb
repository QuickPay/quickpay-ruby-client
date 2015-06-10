
module QuickPay
  BASE_URI    = 'https://api.quickpay.net'
  API_VERSION = 10
  
  API_STATUS_CODES = {
    200 => :ok,
    201 => :created,
    202 => :accepted,
    400 => :bad_request,
    401 => :unauthorized,
    402 => :payment_required,
    403 => :forbidden,
    404 => :not_found,
    405 => :method_not_allowed,
    406 => :not_acceptable,
    409 => :conflict,
    500 => :server_error
  }  
end

