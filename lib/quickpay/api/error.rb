module QuickPay
  module API
    class Error < StandardError
      class BadRequest < Error; end

      class Unauthorized < Error; end

      class PaymentRequired < Error; end

      class Forbidden < Error; end

      class NotFound < Error; end

      class MethodNotAllowed < Error; end

      class NotAcceptable < Error; end

      class Conflict < Error; end

      class TooManyRequest < Error; end

      class InternalServerError < Error; end

      class BadGateway < Error; end

      class ServiceUnavailable < Error; end

      class GatewayTimeout < Error; end

      CLASS_MAP = {
        400 => BadRequest,
        401 => Unauthorized,
        402 => PaymentRequired,
        403 => Forbidden,
        404 => NotFound,
        405 => MethodNotAllowed,
        406 => NotAcceptable,
        409 => Conflict,
        429 => TooManyRequest,
        500 => InternalServerError,
        502 => BadGateway,
        503 => ServiceUnavailable,
        504 => GatewayTimeout
      }.freeze

      attr_reader :status, :body, :headers, :request

      def initialize(status, body, headers, request)
        @status  = status
        @body    = body
        @headers = headers
        @request = request
      end

      def to_s
        "#<#{self.class}: status=#{status}, body=#{body.inspect}, " \
        "headers=#{headers.inspect} request=#{request.inspect}>"
      end
      alias_method :inspect, :to_s

      def self.by_status_code(status, body, headers, request)
        return if (200..399).cover? status

        CLASS_MAP.fetch(status, QuickPay::API::Error).new(status, body, headers, request)
      end
    end
  end
end
