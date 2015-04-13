
[:quickpay_error, :bad_request, :unauthorized, :payment_required, 
 :forbidden, :not_found, :method_not_allowed, :not_acceptable, 
 :conflict, :server_error].each do |err_code|   
    require "quickpay/errors/#{err_code}"
end




