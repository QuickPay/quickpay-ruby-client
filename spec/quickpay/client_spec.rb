require 'spec_helper'

describe QuickPay::API::Client do
  let(:secret){ { email: 'test', password: 'test' } }
  let(:client) { QuickPay::API::Client.new(secret) }
  
  it 'has credentials' do
    expect(client.options[:secret]).to eq('test:test')  
  end

  context 'with api_key' do
    let!(:secret) { { api_key: 'secret'} }

    it 'has credentials' do
      expect(client.options[:secret]).to eq(':secret')  
    end
  end

  it 'has not credentials' do
    expect(QuickPay::API::Client.new.options[:secret]).to be_nil
  end
  
  it 'should proxy get' do
    allow_any_instance_of(QuickPay::API::Request).to receive(:request).with(:get, '/dummy')
    client.get("/dummy")
  end

  it 'should proxy head' do
    allow_any_instance_of(QuickPay::API::Request).to receive(:request).with(:head, '/dummy')
    client.head("/dummy")
  end

  it 'should proxy post' do
    allow_any_instance_of(QuickPay::API::Request).to receive(:request).with(:post, '/dummy', { :foo => 'bar' })
    client.post("/dummy", { foo: 'bar'})
  end

  it 'should proxy patch' do
    allow_any_instance_of(QuickPay::API::Request).to receive(:request).with(:patch, '/dummy', { :foo => 'bar' })
    client.patch("/dummy", { foo: 'bar'})
  end

  it 'should proxy delete' do
    allow_any_instance_of(QuickPay::API::Request).to receive(:request).with(:delete, '/dummy')
    client.delete("/dummy")
  end
  
end
