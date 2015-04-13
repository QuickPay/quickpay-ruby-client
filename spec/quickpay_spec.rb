require 'spec_helper'

describe Quickpay do
  it 'has a version number' do
    expect(Quickpay::VERSION).not_to be_nil
  end

  it 'has an api version' do
    expect(Quickpay::API_VERSION).not_to be_nil      
  end
  
  it 'has base url' do
    expect(Quickpay::BASE_URI).not_to be_nil
  end

  context '.logger' do
    it 'has a logger' do
      expect(Quickpay.logger).not_to be_nil
    end
  end  
  
end
