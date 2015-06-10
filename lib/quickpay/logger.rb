require 'logger'

module QuickPay
  class << self
    attr_writer :logger
    
    def logger
      @logger ||= lambda {
        logger = Logger.new($stdout)
        logger.level = Logger::INFO
        logger  
      }.call 
    end
    
  end
end