require 'spec_helper'

describe QuickPay do
  it 'has a version number' do
    expect(QuickPay::VERSION).not_to be_nil
  end

  it 'has an api version' do
    expect(QuickPay::API_VERSION).not_to be_nil      
  end
  
  it 'has base url' do
    expect(QuickPay::BASE_URI).not_to be_nil
  end

  context '.logger' do
    it 'has a logger' do
      expect(QuickPay.logger).not_to be_nil
    end
  end  
  
end
