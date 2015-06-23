module QuickPay
  module API
    class Error < StandardError
      attr_reader :code, :status, :body

      def initialize(code, status, body)
        @code   = code
        @status = status
        @body   = body
      end
    end
  end  
end